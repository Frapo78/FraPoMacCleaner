import Foundation

/// A scan is descriptive only. No finding grants permission to change a file.
protocol ScanEngine: Sendable {
    func scan(in scope: ScanScope) async throws -> ScanReport
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

    /// These aggregates cover only regular, accessible files, including files below the alert thresholds.
    /// Sizes are logical and may double-count hard links or APFS clones.
    let observedLogicalBytes: Int64
    let fileCategories: [ScanSizeGroup]
    let firstLevelFolders: [ScanSizeGroup]
}
