import Foundation

/// Metadati descrittivi; non concede alcun diritto di rimozione.
struct ScanFinding: Identifiable, Hashable, Sendable {
    let id: UUID
    let fileURL: URL
    let logicalSizeBytes: Int64
    let explanation: String

    init(
        id: UUID = UUID(),
        fileURL: URL,
        logicalSizeBytes: Int64,
        explanation: String
    ) {
        self.id = id
        self.fileURL = fileURL
        self.logicalSizeBytes = logicalSizeBytes
        self.explanation = explanation
    }
}
