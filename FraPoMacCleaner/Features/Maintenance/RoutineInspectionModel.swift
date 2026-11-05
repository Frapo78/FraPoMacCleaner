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

    /// One-click scan of the fixed account directory for this category.
    /// Never broadens access to a user-supplied arbitrary path.
    func inspect(area: RoutineArea) {
        guard let folder = engine.allowedRoots[area] else {
            cancel()
            report = nil
            message = "Impossibile individuare la cartella personale del Mac."
            state = .failed
            return
        }
        inspect(area: area, folder: folder)
    }

    private func inspect(area: RoutineArea, folder: URL) {
        cancel()
        report = nil
        message = nil
        state = .loading
        generation += 1
        let ticket = generation
        let engine = self.engine

        // Filesystem enumeration is synchronous: do not inherit MainActor.
        running = Task.detached(priority: .utility) { [weak self] in
            do {
                let result = try engine.inspect(
                    area: area, selectedURL: folder,
                    isCancelled: { Task.isCancelled }
                )
                await self?.finish(report: result, ticket: ticket)
            } catch {
                let cancelled = error is CancellationError
                    || (error as? RoutineInspectionError) == .cancelled
                await self?.fail(
                    message: cancelled ? nil : error.localizedDescription,
                    cancelled: cancelled,
                    ticket: ticket
                )
            }
        }
    }

    private func finish(report: RoutineReport, ticket: Int) {
        guard generation == ticket, state == .loading else { return }
        self.report = report
        state = .complete
        running = nil
    }

    private func fail(message: String?, cancelled: Bool, ticket: Int) {
        guard generation == ticket else { return }
        self.message = message
        state = cancelled ? .cancelled : .failed
        running = nil
    }

    func cancel() {
        generation += 1
        running?.cancel()
        running = nil
        if state == .loading { state = .cancelled }
    }
}
