import Combine
import Foundation

@MainActor
final class RoutineInspectionModel: ObservableObject {
    enum State: Equatable {
        case idle, loading, complete, cancelled, failed
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var report: RoutineReport?
    @Published private(set) var message: String?

    private let engine: RoutineInspectionEngine
    private var running: Task<Void, Never>?
    private var generation = 0

    init(engine: RoutineInspectionEngine = RoutineInspectionEngine()) {
        self.engine = engine
    }

    func inspect(area: RoutineArea, folder: URL) {
        cancel()
        report = nil
        message = nil
        state = .loading
        generation += 1
        let ticket = generation
        let engine = self.engine

        // Filesystem enumeration is synchronous: do not inherit MainActor.
        running = Task.detached(priority: .utility) { [weak self] in
            let scope = folder.startAccessingSecurityScopedResource()
            defer {
                if scope { folder.stopAccessingSecurityScopedResource() }
            }
            do {
                let result = try engine.inspect(
                    area: area, selectedURL: folder,
                    isCancelled: { Task.isCancelled }
                )
                await MainActor.run {
                    guard let self, self.generation == ticket, self.state == .loading
                    else { return }
                    self.report = result
                    self.state = .complete
                    self.running = nil
                }
            } catch {
                let cancelled = error is CancellationError
                    || (error as? RoutineInspectionError) == .cancelled
                let description = error.localizedDescription
                await MainActor.run {
                    guard let self, self.generation == ticket else { return }
                    self.message = cancelled ? nil : description
                    self.state = cancelled ? .cancelled : .failed
                    self.running = nil
                }
            }
        }
    }

    func cancel() {
        generation += 1
        running?.cancel()
        running = nil
        if state == .loading { state = .cancelled }
    }
}
