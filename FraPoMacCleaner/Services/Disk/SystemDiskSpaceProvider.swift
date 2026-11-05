import Foundation

enum DiskSpaceProviderError: LocalizedError {
    case unavailable

    var errorDescription: String? {
        "Non è stato possibile leggere i dati del volume."
    }
}

/// Osserva il volume home; non modifica file o impostazioni.
struct SystemDiskSpaceProvider: DiskSpaceProviding {
    func snapshot() throws -> DiskSpaceSnapshot {
        let home = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        let info = try home.resourceValues(
            forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey]
        )
        guard let total = info.volumeTotalCapacity,
              let available = info.volumeAvailableCapacity else {
            throw DiskSpaceProviderError.unavailable
        }
        return DiskSpaceSnapshot(
            totalBytes: Int64(total),
            availableBytes: Int64(available)
        )
    }
}
