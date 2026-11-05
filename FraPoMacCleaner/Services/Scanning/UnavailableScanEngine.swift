import Foundation

enum ScanEngineError: LocalizedError {
    case notImplemented

    var errorDescription: String? {
        "La scansione non è ancora disponibile."
    }
}

/// Segnaposto: non legge il filesystem e non avvia alcun job.
struct UnavailableScanEngine: ScanEngine {
    func scan(in scope: ScanScope) async throws -> [ScanFinding] {
        throw ScanEngineError.notImplemented
    }
}
