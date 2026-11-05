import Foundation

enum ScanEngineError: LocalizedError {
    case notImplemented

    var errorDescription: String? {
        "La scansione non è ancora disponibile."
    }
}

/// Fallback: it never reads files and cannot change them.
struct UnavailableScanEngine: ScanEngine {
    func scan(in scope: ScanScope) async throws -> ScanReport {
        throw ScanEngineError.notImplemented
    }
}
