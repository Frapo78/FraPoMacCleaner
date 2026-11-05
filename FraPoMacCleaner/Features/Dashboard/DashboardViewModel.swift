import Combine
import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published private(set) var snapshot: DiskSpaceSnapshot?
    @Published private(set) var errorMessage: String?

    private let provider: any DiskSpaceProviding

    init(provider: any DiskSpaceProviding) {
        self.provider = provider
    }

    func refresh() {
        do {
            snapshot = try provider.snapshot()
            errorMessage = nil
        } catch {
            snapshot = nil
            errorMessage = error.localizedDescription
        }
    }
}
