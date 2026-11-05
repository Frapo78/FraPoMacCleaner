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
            VStack(spacing: 0) {
                Image("BrandLogo")
                .interpolation(.high)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 182, maxHeight: 46)
                    .padding(8)
                    .background(.white, in: RoundedRectangle(cornerRadius: 10))
                    .accessibilityLabel("FraPoMacCleaner")
                    .padding(.horizontal, 12)
                    .padding(.top, 18)
                    .padding(.bottom, 12)

                List(SectionPage.allCases, selection: $selection) { item in
                    Label(item.label, systemImage: item.symbol).tag(item)
                }
            }
            .navigationTitle("FraPoMacCleaner")
            .frame(minWidth: 200)
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
