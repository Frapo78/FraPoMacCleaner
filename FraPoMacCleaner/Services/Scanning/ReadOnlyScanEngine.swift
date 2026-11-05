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

    func scan(in scope: ScanScope) async throws -> ScanReport {
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
        var findings: [ScanFinding] = []

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
                reachedLimit: limit
            )
        }

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
                errors += 1
                continue
            }

            for item in entries {
                try Task.checkCancellation()
                if visited >= maximumEntries { return report(limit: true) }
                visited += 1

                // Deny by path first; then inspect type before traversing.
                if Self.isExcluded(item) {
                    excluded += 1
                    continue
                }
                let properties: URLResourceValues
                do {
                    properties = try item.resourceValues(forKeys: keys)
                } catch {
                    errors += 1
                    continue
                }
                if properties.isSymbolicLink == true ||
                   properties.isPackage == true ||
                   properties.isUbiquitousItem == true {
                    excluded += 1
                    continue
                }
                if properties.isDirectory == true {
                    directories.append(item)
                    continue
                }
                guard properties.isRegularFile == true else {
                    excluded += 1
                    continue
                }
                inspected += 1

                guard let bytes = properties.fileSize, bytes >= 0 else {
                    errors += 1
                    continue
                }
                let size = Int64(bytes)
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
            "utm", "vbox", "mailbundle"
        ]
        return url.standardizedFileURL.pathComponents.contains {
            let name = $0.lowercased()
            let ext = (name as NSString).pathExtension
            return names.contains(name) || protectedExtensions.contains(ext)
        }
    }
}
