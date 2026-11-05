import Foundation

enum ReadOnlyScanError: LocalizedError {
    case invalidScope
    case protectedScope

    var errorDescription: String? {
        switch self {
        case .invalidScope:
            return "Seleziona una cartella reale e accessibile, non un collegamento."
        case .protectedScope:
            return "La cartella selezionata è esclusa per proteggere dati sensibili o di sistema."
        }
    }
}

/// Bounded, cancellable enumeration of metadata. Never opens file contents.
/// A finding means "worth reviewing", not "safe to remove".
struct ReadOnlyScanEngine: ScanEngine {
    let minimumLargeFileBytes: Int64
    let minimumAgeDays: Int
    let maximumEntries: Int
    let maximumFindings: Int
    let referenceDate: Date

    init(
        minimumLargeFileBytes: Int64 = 250 * 1_024 * 1_024,
        minimumAgeDays: Int = 180,
        maximumEntries: Int = 100_000,
        maximumFindings: Int = 500,
        referenceDate: Date = Date()
    ) {
        self.minimumLargeFileBytes = minimumLargeFileBytes
        self.minimumAgeDays = minimumAgeDays
        self.maximumEntries = maximumEntries
        self.maximumFindings = maximumFindings
        self.referenceDate = referenceDate
    }

    func scan(
        in scope: ScanScope,
        progress: @escaping @Sendable (ScanProgress) -> Void
    ) async throws -> ScanReport {
        try Task.checkCancellation()
        let root = scope.folderURL.standardizedFileURL
        guard root.isFileURL,
              root.path != "/",
              root.path != "/Users",
              root.path != "/Volumes",
              root.resolvingSymlinksInPath().path == root.path
        else { throw ReadOnlyScanError.invalidScope }

        guard !Self.isExcluded(root) else { throw ReadOnlyScanError.protectedScope }
        let rootProperties = try root.resourceValues(forKeys: [
            .isDirectoryKey, .isSymbolicLinkKey, .isPackageKey
        ])
        guard rootProperties.isDirectory == true,
              rootProperties.isSymbolicLink != true,
              rootProperties.isPackage != true
        else { throw ReadOnlyScanError.invalidScope }

        let keys: Set<URLResourceKey> = [
            .isDirectoryKey, .isRegularFileKey, .isSymbolicLinkKey,
            .isPackageKey, .isUbiquitousItemKey, .fileSizeKey,
            .contentModificationDateKey
        ]
        let fileManager = FileManager.default
        var directories = [root]
        var inspected = 0
        var visited = 0
        var candidates = 0
        var excluded = 0
        var errors = 0
        var exclusionCounts: [ScanExclusionReason: Int] = [:]
        var issueCounts: [ScanAccessIssue: Int] = [:]
        var findings: [ScanFinding] = []
        var observedLogicalBytes: Int64 = 0
        var categoryGroups: [String: ScanSizeGroup] = [:]
        var folderGroups: [String: ScanSizeGroup] = [:]
        let rootComponentCount = root.pathComponents.count

        func skip(_ reason: ScanExclusionReason) {
            excluded += 1
            exclusionCounts[reason, default: 0] += 1
        }

        func issue(_ kind: ScanAccessIssue) {
            errors += 1
            issueCounts[kind, default: 0] += 1
        }

        func publishProgress(force: Bool = false) {
            // Avoid flooding the UI on large trees. The maximum is unknown:
            // do not display a misleading percentage.
            guard force || visited % 128 == 0 else { return }
            progress(ScanProgress(
                visitedItemCount: visited,
                inspectedFileCount: inspected,
                candidateCount: candidates,
                skippedItemCount: excluded,
                errorCount: errors
            ))
        }

        func add(_ size: Int64, to label: String, in groups: inout [String: ScanSizeGroup]) {
            let previous = groups[label]
            let existingBytes = previous?.logicalSizeBytes ?? 0
            let totalBytes = existingBytes > Int64.max - size ? Int64.max : existingBytes + size
            groups[label] = ScanSizeGroup(
                label: label,
                fileCount: (previous?.fileCount ?? 0) + 1,
                logicalSizeBytes: totalBytes
            )
        }

        func orderedGroups(_ groups: [String: ScanSizeGroup]) -> [ScanSizeGroup] {
            groups.values.sorted {
                if $0.logicalSizeBytes != $1.logicalSizeBytes {
                    return $0.logicalSizeBytes > $1.logicalSizeBytes
                }
                return $0.label < $1.label
            }
        }

        func report(limit: Bool) -> ScanReport {
            ScanReport(
                findings: findings.sorted {
                    if $0.logicalSizeBytes != $1.logicalSizeBytes {
                        return $0.logicalSizeBytes > $1.logicalSizeBytes
                    }
                    return $0.fileURL.path < $1.fileURL.path
                },
                inspectedFileCount: inspected,
                candidateCount: candidates,
                skippedItemCount: excluded,
                errorCount: errors,
                reachedLimit: limit,
                exclusionSummary: ScanExclusionReason.allCases.compactMap { reason in
                    guard let count = exclusionCounts[reason], count > 0 else { return nil }
                    return ScanExclusionSummary(reason: reason, count: count)
                },
                issueSummary: ScanAccessIssue.allCases.compactMap { kind in
                    guard let count = issueCounts[kind], count > 0 else { return nil }
                    return ScanIssueSummary(issue: kind, count: count)
                },
                observedLogicalBytes: observedLogicalBytes,
                fileCategories: orderedGroups(categoryGroups),
                firstLevelFolders: orderedGroups(folderGroups)
            )
        }

        publishProgress(force: true)
        while let directory = directories.popLast() {
            try Task.checkCancellation()
            let entries: [URL]
            do {
                entries = try fileManager.contentsOfDirectory(
                    at: directory,
                    includingPropertiesForKeys: Array(keys),
                    options: []
                )
            } catch {
                if directory == root { throw error }
                issue(.unreadableDirectory)
                publishProgress(force: true)
                continue
            }

            for item in entries {
                try Task.checkCancellation()
                if visited >= maximumEntries {
                    publishProgress(force: true)
                    return report(limit: true)
                }
                visited += 1
                defer { publishProgress() }

                // Deny by path first; then inspect type before traversing.
                if Self.isExcluded(item) {
                    skip(.protectedPath)
                    continue
                }
                let properties: URLResourceValues
                do {
                    properties = try item.resourceValues(forKeys: keys)
                } catch {
                    issue(.unreadableMetadata)
                    continue
                }
                if properties.isSymbolicLink == true {
                    skip(.symbolicLink)
                    continue
                }
                if properties.isPackage == true {
                    skip(.package)
                    continue
                }
                if properties.isUbiquitousItem == true {
                    skip(.cloudItem)
                    continue
                }
                if properties.isDirectory == true {
                    directories.append(item)
                    continue
                }
                guard properties.isRegularFile == true else {
                    skip(.unsupportedItem)
                    continue
                }
                inspected += 1

                guard let bytes = properties.fileSize, bytes >= 0 else {
                    issue(.missingSize)
                    continue
                }
                let size = Int64(bytes)

                // Aggregate only successfully inspected regular-file metadata.
                // A sparse file or APFS clone can have a large logical size but little unique disk usage.
                observedLogicalBytes = observedLogicalBytes > Int64.max - size
                    ? Int64.max : observedLogicalBytes + size
                add(size, to: ScanFileCategory.classify(item).label, in: &categoryGroups)

                let components = item.standardizedFileURL.pathComponents
                let firstLevel = components.count > rootComponentCount + 1
                    ? components[rootComponentCount]
                    : "File nella cartella principale"
                add(size, to: firstLevel, in: &folderGroups)

                let isLarge = size >= minimumLargeFileBytes
                let modifiedAt = properties.contentModificationDate
                let isOld = modifiedAt.map {
                    referenceDate.timeIntervalSince($0) >= Double(minimumAgeDays) * 86_400
                } ?? false
                guard isLarge || isOld else { continue }

                candidates += 1
                let reasons = [
                    isLarge ? "Dimensione logica elevata" : nil,
                    isOld ? "Non modificato da almeno \(minimumAgeDays) giorni" : nil
                ].compactMap { $0 }
                findings.append(ScanFinding(
                    fileURL: item,
                    logicalSizeBytes: size,
                    modifiedAt: modifiedAt,
                    explanation: reasons.joined(separator: " · ")
                ))
                if findings.count > maximumFindings {
                    findings.sort {
                        if $0.logicalSizeBytes != $1.logicalSizeBytes {
                            return $0.logicalSizeBytes > $1.logicalSizeBytes
                        }
                        return $0.fileURL.path < $1.fileURL.path
                    }
                    findings.removeLast()
                }
            }
        }

        try Task.checkCancellation()
        publishProgress(force: true)
        return report(limit: false)
    }

    /// Additional guardrail for the first read-only milestone.
    /// Real metadata (symlink/package) is checked independently.
    static func isExcluded(_ url: URL) -> Bool {
        let path = url.standardizedFileURL.path.lowercased()
        let systemRoots = [
            "/system", "/library", "/private", "/usr",
            "/bin", "/sbin", "/applications"
        ]
        if systemRoots.contains(where: { path == $0 || path.hasPrefix($0 + "/") }) {
            return true
        }
        let names: Set<String> = [
            "library", ".git", ".ssh", ".gnupg", ".aws",
            ".config", ".trash", ".trashes", "mobile documents",
            "cloudstorage", "keychains", "mail", "messages",
            "photos library.photoslibrary", "backups.backupdb"
        ]
        let protectedExtensions: Set<String> = [
            "app", "bundle", "framework", "photoslibrary", "aplibrary",
            "sparsebundle", "sparseimage", "dmg", "pkg",
            "xcodeproj", "xcworkspace", "xcarchive", "vmwarevm",
            "utm", "vbox", "mailbundle", "p12", "p8", "pem",
            "key", "keychain", "keychain-db", "mobileprovision",
            "provisionprofile"
        ]
        return url.standardizedFileURL.pathComponents.contains {
            let name = $0.lowercased()
            let ext = (name as NSString).pathExtension
            return names.contains(name) || protectedExtensions.contains(ext)
        }
    }
}
