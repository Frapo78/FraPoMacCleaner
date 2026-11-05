import Foundation

/// User-authorized folder and optional conservative per-scan thresholds.
/// These values never grant permissions or authorize a cleanup operation.
struct ScanScope: Hashable, Sendable {
    let folderURL: URL
    let minimumLargeFileBytes: Int64?
    let minimumAgeDays: Int?

    init(
        folderURL: URL,
        minimumLargeFileBytes: Int64? = nil,
        minimumAgeDays: Int? = nil
    ) {
        self.folderURL = folderURL
        self.minimumLargeFileBytes = minimumLargeFileBytes
        self.minimumAgeDays = minimumAgeDays
    }
}
