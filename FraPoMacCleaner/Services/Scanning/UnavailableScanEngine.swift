import Foundation

enum ScanEngineError: LocalizedError {
    case notImplemented

    var errorDescription: String? {
        "La scansione non è ancora disponibile."
    }
}

/// Fallback: it never reads files and cannot change them.
struct UnavailableScanEngine: ScanEngine {
    func scan(
        in scope: ScanScope,
        progress: @escaping @Sendable (ScanProgress) -> Void
    ) async throws -> ScanReport {
        throw ScanEngineError.notImplemented
    }
}
