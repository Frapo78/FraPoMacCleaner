import Foundation

/// Metadata for review, never an authorization to delete or free space.
struct ScanFinding: Identifiable, Hashable, Sendable {
    let id: UUID
    let fileURL: URL
    let logicalSizeBytes: Int64
    let modifiedAt: Date?
    let explanation: String

    init(
        id: UUID = UUID(),
        fileURL: URL,
        logicalSizeBytes: Int64,
        modifiedAt: Date? = nil,
        explanation: String
    ) {
        self.id = id
        self.fileURL = fileURL
        self.logicalSizeBytes = logicalSizeBytes
        self.modifiedAt = modifiedAt
        self.explanation = explanation
    }
}
