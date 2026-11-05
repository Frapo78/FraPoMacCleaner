import Foundation

/// Observable reasons are informational only; neither reason authorizes cleanup.
enum ScanFindingReason: String, CaseIterable, Hashable, Sendable {
    case largeFile
    case oldFile

    var label: String {
        switch self {
        case .largeFile: "File grande"
        case .oldFile: "File datato"
        }
    }
}

/// Metadata for review, never an authorization to delete or free space.
struct ScanFinding: Identifiable, Hashable, Sendable {
    let id: UUID
    let fileURL: URL
    let logicalSizeBytes: Int64
    let modifiedAt: Date?
    let explanation: String
    let reasons: Set<ScanFindingReason>

    init(
        id: UUID = UUID(),
        fileURL: URL,
        logicalSizeBytes: Int64,
        modifiedAt: Date? = nil,
        explanation: String,
        reasons: Set<ScanFindingReason> = []
    ) {
        self.id = id
        self.fileURL = fileURL
        self.logicalSizeBytes = logicalSizeBytes
        self.modifiedAt = modifiedAt
        self.explanation = explanation
        self.reasons = reasons
    }
}
