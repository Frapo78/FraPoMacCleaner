import Foundation

/// A scan is descriptive only. No finding grants permission to change a file.
protocol ScanEngine: Sendable {
    func scan(
        in scope: ScanScope,
        progress: @escaping @Sendable (ScanProgress) -> Void
    ) async throws -> ScanReport
}

extension ScanEngine {
    func scan(in scope: ScanScope) async throws -> ScanReport {
        try await scan(in: scope, progress: { _ in })
    }
}

/// Counts are snapshots of work already inspected, not a percentage of the folder.
struct ScanProgress: Sendable {
    let visitedItemCount: Int
    let inspectedFileCount: Int
    let candidateCount: Int
    let skippedItemCount: Int
    let errorCount: Int
}

enum ScanExclusionReason: String, CaseIterable, Sendable {
    case protectedPath, symbolicLink, package, cloudItem, unsupportedItem, otherVolume

    var label: String {
        switch self {
        case .protectedPath: "Percorso protetto"
        case .symbolicLink: "Collegamento simbolico"
        case .package: "Pacchetto applicativo o libreria"
        case .cloudItem: "Elemento gestito dal cloud"
        case .unsupportedItem: "Tipo di elemento non supportato"
        case .otherVolume: "Altro volume o punto di montaggio"
        }
    }
}

struct ScanExclusionSummary: Identifiable, Sendable {
    let reason: ScanExclusionReason
    let count: Int
    var id: String { reason.rawValue }
}

enum ScanAccessIssue: String, CaseIterable, Sendable {
    case unreadableDirectory, unreadableMetadata, missingSize

    var label: String {
        switch self {
        case .unreadableDirectory: "Cartella non accessibile"
        case .unreadableMetadata: "Metadati non accessibili"
        case .missingSize: "Dimensione non disponibile"
        }
    }
}

struct ScanIssueSummary: Identifiable, Sendable {
    let issue: ScanAccessIssue
    let count: Int
    var id: String { issue.rawValue }
}

/// Logical size of regular files whose metadata could be read, not disk space freed.
struct ScanSizeGroup: Identifiable, Sendable {
    let label: String
    let fileCount: Int
    let logicalSizeBytes: Int64
    var id: String { label }
}

/// File type from the extension only: no content sniffing or disk reads.
enum ScanFileCategory: String, CaseIterable, Sendable {
    case video, images, audio, documents, archives, sourceCode, other

    var label: String {
        switch self {
        case .video: "Video"
        case .images: "Immagini"
        case .audio: "Audio"
        case .documents: "Documenti"
        case .archives: "Archivi"
        case .sourceCode: "Sviluppo"
        case .other: "Altro"
        }
    }

    static func classify(_ fileURL: URL) -> ScanFileCategory {
        let ext = fileURL.pathExtension.lowercased()
        switch ext {
        case "mp4", "mov", "m4v", "mkv", "avi", "webm", "wmv", "mpeg":
            return .video
        case "jpg", "jpeg", "png", "heic", "heif", "gif", "webp", "tif", "tiff", "svg":
            return .images
        case "mp3", "m4a", "flac", "wav", "aiff", "aac", "ogg", "opus":
            return .audio
        case "pdf", "txt", "rtf", "doc", "docx", "odt", "xls", "xlsx", "csv", "ppt", "pptx", "epub", "pages", "numbers":
            return .documents
        case "zip", "7z", "rar", "tar", "gz", "bz2", "xz", "zst", "iso":
            return .archives
        case "swift", "c", "h", "cpp", "hpp", "m", "mm", "py", "js", "ts", "tsx", "jsx", "php", "html", "css", "json", "xml", "sql", "sh", "go", "rs", "java":
            return .sourceCode
        default:
            return .other
        }
    }
}

struct ScanReport: Sendable {
    let findings: [ScanFinding]
    let inspectedFileCount: Int
    let candidateCount: Int
    let skippedItemCount: Int
    let errorCount: Int
    let reachedLimit: Bool

    /// Bounded summaries with no file paths or file contents.
    let exclusionSummary: [ScanExclusionSummary]
    let issueSummary: [ScanIssueSummary]

    /// These aggregates cover only regular, accessible files, including files below the alert thresholds.
    /// Sizes are logical and may double-count hard links or APFS clones.
    let observedLogicalBytes: Int64
    /// Logical size counted once for each observed (device, inode) pair.
    let observedUniqueLogicalBytes: Int64
    /// Allocated bytes for distinct observed inodes; APFS clones can share blocks.
    let observedAllocatedBytes: Int64
    /// Paths pointing to inodes whose link count is greater than one.
    let hardLinkedEntryCount: Int
    /// Paths that refer to an inode already counted in this scan.
    let repeatedHardLinkEntryCount: Int
    let fileCategories: [ScanSizeGroup]
    let firstLevelFolders: [ScanSizeGroup]
}
