import SwiftUI

enum SectionPage: String, CaseIterable, Identifiable {
    case overview, scan, results, settings
    var id: Self { self }

    var label: String {
        switch self {
        case .overview: "Panoramica"
        case .scan: "Scansione"
        case .results: "Risultati"
        case .settings: "Impostazioni"
        }
    }

    var symbol: String {
        switch self {
        case .overview: "square.grid.2x2"
        case .scan: "magnifyingglass"
        case .results: "doc.text.magnifyingglass"
        case .settings: "gearshape"
        }
    }
}

struct RootView: View {
    let dependencies: AppDependencies
    @State private var selection: SectionPage? = .overview

    var body: some View {
        NavigationSplitView {
            List(SectionPage.allCases, selection: $selection) { item in
                Label(item.label, systemImage: item.symbol).tag(item)
            }
            .navigationTitle("FraPoMacCleaner")
            .frame(minWidth: 180)
        } detail: {
            switch selection ?? .overview {
            case .overview: DashboardView(provider: dependencies.disk)
            case .scan: ScanView()
            case .results: ResultsView()
            case .settings: SettingsView()
            }
        }
        .frame(minWidth: 760, minHeight: 480)
    }
}
