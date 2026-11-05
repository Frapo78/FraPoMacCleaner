import Darwin
import Foundation

/// A narrowly scoped, read-only inventory. Findings never mean a file may be removed.
enum RoutineArea: String, CaseIterable, Hashable, Sendable {
    case userLogs
    case xcodeDerivedData
    case userLaunchAgents

    var label: String {
        switch self {
        case .userLogs: "Log e diagnosi utente"
        case .xcodeDerivedData: "Build temporanee Xcode"
        case .userLaunchAgents: "Agenti di avvio utente"
        }
    }

    var relativePath: String {
        switch self {
        case .userLogs: "Library/Logs"
        case .xcodeDerivedData: "Library/Developer/Xcode/DerivedData"
        case .userLaunchAgents: "Library/LaunchAgents"
        }
    }

    var explanation: String {
        switch self {
        case .userLogs:
            "Solo file di log e diagnostica datati. Un log vecchio può essere ancora necessario."
        case .xcodeDerivedData:
            "Dimensioni logiche di artefatti di compilazione per progetto. Una build può essere ancora in uso."
        case .userLaunchAgents:
            "Solo nomi dei file .plist. La presenza non prova che l'agente sia attivo."
        }
    }
}

struct RoutineEntry: Identifiable, Sendable {
    let url: URL
    let label: String
    let description: String
    let logicalSizeBytes: Int64?
    let modifiedAt: Date?
    var id: String { url.path }
}

struct RoutineReport: Sendable {
    let area: RoutineArea
    let entries: [RoutineEntry]
    let inspectedItemCount: Int
    let skippedItemCount: Int
    let errorCount: Int
    let reachedLimit: Bool
    let observedLogicalBytes: Int64
}

enum RoutineInspectionError: LocalizedError {
    case outsideAllowlist
    case notDirectory
    case cancelled

    var errorDescription: String? {
        switch self {
        case .outsideAllowlist: "La cartella non coincide con la posizione utente consentita."
        case .notDirectory: "La cartella scelta non è una directory reale accessibile."
        case .cancelled: "Ispezione annullata."
        }
    }
}

/// Production roots are fixed to three documented locations under the current user's home.
/// Synthetic roots can be injected by XCTest, without accessing the user's real Library.
struct RoutineInspectionEngine: Sendable {
    let allowedRoots: [RoutineArea: URL]
    let referenceDate: Date
    let maximumVisited: Int
    let maximumDisplayed: Int
    let minimumLogAgeDays: Int

    // Sandboxed apps may see the container as their "home"; the account home
    // is derived from the current user record. This does not grant file access.
    private static var productionRoots: [RoutineArea: URL] {
        guard let account = getpwuid(getuid()), let directory = account.pointee.pw_dir else {
            return [:] // Fail closed if the account home cannot be resolved.
        }
        let home = URL(fileURLWithPath: String(cString: directory), isDirectory: true)
        return Dictionary(uniqueKeysWithValues: RoutineArea.allCases.map { area in
            (area, home.appendingPathComponent(area.relativePath, isDirectory: true))
        })
    }

    init(
        allowedRoots: [RoutineArea: URL] = RoutineInspectionEngine.productionRoots,
        referenceDate: Date = Date(),
        maximumVisited: Int = 20_000,
        maximumDisplayed: Int = 200,
        minimumLogAgeDays: Int = 30
    ) {
        self.allowedRoots = allowedRoots
        self.referenceDate = referenceDate
        self.maximumVisited = max(1, maximumVisited)
        self.maximumDisplayed = max(1, maximumDisplayed)
        self.minimumLogAgeDays = max(1, minimumLogAgeDays)
    }

    private struct FileIdentity: Hashable {
        let device: UInt64
        let inode: UInt64

        init(_ metadata: stat) {
            device = UInt64(bitPattern: Int64(metadata.st_dev))
            inode = UInt64(metadata.st_ino)
        }
    }

    private static func matchingLogName(_ name: String) -> Bool {
        let lower = name.lowercased()
        let exactSuffixes = [".log", ".ips", ".crash", ".hang", ".spin", ".diag"]
        if exactSuffixes.contains(where: { lower.hasSuffix($0) }) { return true }
        // Rotated logs, not arbitrary files containing "log".
        return [".log.0", ".log.1", ".log.2", ".log.3", ".log.0.gz", ".log.1.gz",
                ".log.2.gz", ".log.3.gz"].contains(where: { lower.hasSuffix($0) })
    }

    private static func excluded(_ url: URL) -> Bool {
        let forbiddenNames: Set<String> = [
            ".git", ".ssh", ".gnupg", ".aws", ".config", "keychains",
            "cloudstorage", "mobile documents", "mail", "messages", ".trash"
        ]
        let forbiddenExtensions: Set<String> = [
            "app", "framework", "bundle", "photoslibrary", "sparsebundle",
            "xcodeproj", "xcworkspace", "xcarchive", "key", "p12", "pem",
            "mobileprovision", "sqlite", "db"
        ]
        return url.pathComponents.contains { component in
            let name = component.lowercased()
            return forbiddenNames.contains(name)
                || forbiddenExtensions.contains((name as NSString).pathExtension)
        }
    }

    private static func add(_ lhs: Int64, _ rhs: Int64) -> Int64 {
        let (sum, overflow) = lhs.addingReportingOverflow(rhs)
        return overflow ? Int64.max : sum
    }

    /// Uses metadata only; never reads plist/log contents or changes an item.
    /// The selected URL must match the precise preapproved root for its category.
    func inspect(
        area: RoutineArea,
        selectedURL: URL,
        isCancelled: () -> Bool = { false }
    ) throws -> RoutineReport {
        let root = selectedURL.standardizedFileURL
        guard root.isFileURL,
              let expected = allowedRoots[area]?.standardizedFileURL,
              root.path == expected.path,
              root.resolvingSymlinksInPath().path == root.path,
              !Self.excluded(root)
        else { throw RoutineInspectionError.outsideAllowlist }

        var rootInfo = stat()
        guard lstat(root.path, &rootInfo) == 0,
              (rootInfo.st_mode & mode_t(S_IFMT)) == mode_t(S_IFDIR)
        else { throw RoutineInspectionError.notDirectory }

        let rootDevice = FileIdentity(rootInfo).device
        let rootParts = root.pathComponents.count
        let depthLimit = area == .userLogs ? 4 : (area == .xcodeDerivedData ? 6 : 0)

        var stack: [(url: URL, depth: Int)] = [(root, 0)]
        var visited = 0
        var skipped = 0
        var errors = 0
        var entries: [RoutineEntry] = []
        var total: Int64 = 0
        var reachedLimit = false
        var counted = Set<FileIdentity>()
        var projectGroups: [String: (count: Int, bytes: Int64, latest: Date?)] = [:]
        let manager = FileManager.default

        scan: while let next = stack.popLast() {
            let directory = next.url
            if isCancelled() { throw RoutineInspectionError.cancelled }
            var dirInfo = stat()
            guard lstat(directory.path, &dirInfo) == 0,
                  (dirInfo.st_mode & mode_t(S_IFMT)) == mode_t(S_IFDIR),
                  FileIdentity(dirInfo).device == rootDevice
            else {
                errors += 1
                continue
            }
            let children: [URL]
            do {
                children = try manager.contentsOfDirectory(
                    at: directory,
                    includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey],
                    options: []
                )
            } catch {
                errors += 1
                continue
            }

            for item in children {
                if isCancelled() { throw RoutineInspectionError.cancelled }
                if visited >= maximumVisited {
                    reachedLimit = true
                    break scan
                }
                visited += 1
                if Self.excluded(item) {
                    skipped += 1
                    continue
                }
                var metadata = stat()
                guard lstat(item.path, &metadata) == 0 else {
                    errors += 1
                    continue
                }
                let identity = FileIdentity(metadata)
                guard identity.device == rootDevice,
                      (metadata.st_mode & mode_t(S_IFMT)) != mode_t(S_IFLNK)
                else {
                    skipped += 1
                    continue
                }
                if (metadata.st_mode & mode_t(S_IFMT)) == mode_t(S_IFDIR) {
                    if area != .userLaunchAgents && directory != item && stack.count < maximumVisited {
                        if item.pathComponents.count - rootParts <= depthLimit {
                            stack.append((item, item.pathComponents.count - rootParts))
                        } else {
                            skipped += 1
                        }
                    } else { skipped += 1 }
                    continue
                }
                guard (metadata.st_mode & mode_t(S_IFMT)) == mode_t(S_IFREG),
                      metadata.st_uid == getuid(),
                      metadata.st_nlink == 1
                else {
                    skipped += 1
                    continue
                }
                let size = max(0, Int64(metadata.st_size))
                let date = try? item.resourceValues(
                    forKeys: [.contentModificationDateKey]
                ).contentModificationDate

                switch area {
                case .userLogs:
                    guard Self.matchingLogName(item.lastPathComponent),
                          let modified = date,
                          referenceDate.timeIntervalSince(modified) >=
                            Double(minimumLogAgeDays) * 86_400
                    else { skipped += 1; continue }
                    if !counted.insert(identity).inserted { skipped += 1; continue }
                    total = Self.add(total, size)
                    entries.append(RoutineEntry(
                        url: item,
                        label: item.lastPathComponent,
                        description: "Log o diagnostica utente datato · protetto",
                        logicalSizeBytes: size,
                        modifiedAt: modified
                    ))
                case .xcodeDerivedData:
                    let parts = item.pathComponents
                    guard parts.count > rootParts + 1 else { skipped += 1; continue }
                    if !counted.insert(identity).inserted { skipped += 1; continue }
                    let name = parts[rootParts]
                    let existing = projectGroups[name]
                    projectGroups[name] = (
                        count: (existing?.count ?? 0) + 1,
                        bytes: Self.add(existing?.bytes ?? 0, size),
                        latest: max(existing?.latest ?? .distantPast, date ?? .distantPast)
                    )
                    total = Self.add(total, size)
                case .userLaunchAgents:
                    guard directory == root,
                          item.pathExtension.lowercased() == "plist"
                    else { skipped += 1; continue }
                    entries.append(RoutineEntry(
                        url: item,
                        label: item.deletingPathExtension().lastPathComponent,
                        description: "Agente registrato su disco · attività non verificata · protetto",
                        logicalSizeBytes: size,
                        modifiedAt: date
                    ))
                }
            }
        }

        if area == .xcodeDerivedData {
            entries = projectGroups.map { name, value in
                RoutineEntry(
                    url: root.appendingPathComponent(name, isDirectory: true),
                    label: name,
                    description: "\(value.count) file di build osservati · cartella protetta",
                    logicalSizeBytes: value.bytes,
                    modifiedAt: value.latest == .distantPast ? nil : value.latest
                )
            }
        }

        entries.sort {
            if ($0.logicalSizeBytes ?? 0) != ($1.logicalSizeBytes ?? 0) {
                return ($0.logicalSizeBytes ?? 0) > ($1.logicalSizeBytes ?? 0)
            }
            return $0.label < $1.label
        }
        if entries.count > maximumDisplayed {
            reachedLimit = true
            entries = Array(entries.prefix(maximumDisplayed))
        }
        return RoutineReport(
            area: area,
            entries: entries,
            inspectedItemCount: visited,
            skippedItemCount: skipped,
            errorCount: errors,
            reachedLimit: reachedLimit,
            observedLogicalBytes: total
        )
    }
}
