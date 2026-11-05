import Foundation

/// A scan is descriptive only. No finding grants permission to change a file.
protocol ScanEngine: Sendable {
    func scan(in scope: ScanScope) async throws -> ScanReport
}

struct ScanReport: Sendable {
    let findings: [ScanFinding]
    let inspectedFileCount: Int
    let candidateCount: Int
    let skippedItemCount: Int
    let errorCount: Int
    let reachedLimit: Bool
}
