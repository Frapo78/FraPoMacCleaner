import Combine
import Foundation

/// Owns a single, explicitly started scan session and its scope access.
@MainActor
final class ScanSessionModel: ObservableObject {
    enum Phase: Equatable {
        case idle, scanning, finished, cancelled, failed
    }

    @Published private(set) var selectedFolder: URL?
    @Published private(set) var phase: Phase = .idle
    @Published private(set) var report: ScanReport?
    @Published private(set) var progress: ScanProgress?
    @Published private(set) var errorMessage: String?

    private let scanner: any ScanEngine
    private var currentTask: Task<Void, Never>?
    private var generation = 0

    init(scanner: any ScanEngine) {
        self.scanner = scanner
    }

    func selectFolder(_ url: URL) {
        cancel()
        selectedFolder = url
        report = nil
        progress = nil
        errorMessage = nil
        phase = .idle
    }

    func start(
        minimumSizeBytes: Int64? = nil,
        minimumAgeDays: Int? = nil
    ) {
        guard let folder = selectedFolder, phase != .scanning else { return }
        cancel()
        report = nil
        progress = nil
        errorMessage = nil
        phase = .scanning
        generation += 1
        let runID = generation
        let engine = scanner
        let scope = ScanScope(
            folderURL: folder,
            minimumLargeFileBytes: minimumSizeBytes,
            minimumAgeDays: minimumAgeDays
        )
        currentTask = Task(priority: .utility) {
            let granted = folder.startAccessingSecurityScopedResource()
            defer {
                if granted { folder.stopAccessingSecurityScopedResource() }
            }
            do {
                let result = try await engine.scan(
                    in: scope,
                    progress: { [weak self] snapshot in
                        Task { @MainActor [weak self] in
                            guard let self, self.generation == runID,
                                  self.phase == .scanning else { return }
                            self.progress = snapshot
                        }
                    }
                )
                guard generation == runID, !Task.isCancelled else { return }
                report = result
                phase = .finished
                currentTask = nil
            } catch is CancellationError {
                guard generation == runID else { return }
                phase = .cancelled
                currentTask = nil
            } catch {
                guard generation == runID, !Task.isCancelled else { return }
                errorMessage = error.localizedDescription
                phase = .failed
                currentTask = nil
            }
        }
    }

    func cancel() {
        generation += 1
        currentTask?.cancel()
        currentTask = nil
        if phase == .scanning { phase = .cancelled }
    }
}
