protocol ScanEngine: Sendable {
    /// Implementazioni future: read-only, cancellabili, no symlink traversal.
    func scan(in scope: ScanScope) async throws -> [ScanFinding]
}
