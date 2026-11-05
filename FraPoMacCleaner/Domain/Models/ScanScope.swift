import Foundation

/// Una cartella selezionata non garantisce permessi persistenti.
struct ScanScope: Hashable, Sendable {
    let folderURL: URL
}
