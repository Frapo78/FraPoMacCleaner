import SwiftUI

struct DashboardView: View {
    @StateObject private var model: DashboardViewModel

    init(provider: any DiskSpaceProviding) {
        _model = StateObject(wrappedValue: DashboardViewModel(provider: provider))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Panoramica").font(.largeTitle.bold())
            Text("Informazioni locali. Nessuna operazione automatica.")
                .foregroundStyle(.secondary)

            GroupBox("Spazio disco") {
                VStack(alignment: .leading, spacing: 12) {
                    if let data = model.snapshot {
                        ProgressView(value: data.usedFraction)
                            .accessibilityLabel("Spazio del volume utilizzato")
                        Text("\(size(data.usedBytes)) utilizzati su \(size(data.totalBytes))")
                        Text("\(size(data.availableBytes)) disponibili")
                            .foregroundStyle(.secondary)
                    } else if let error = model.errorMessage {
                        Text(error).foregroundStyle(.secondary)
                    } else {
                        ProgressView("Caricamento…")
                    }
                    Button("Aggiorna") { model.refresh() }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
            }

            GroupBox("Sicurezza") {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Scanner: non ancora disponibile", systemImage: "clock")
                    Label("Pulizia e cancellazione: non implementate", systemImage: "lock.shield")
                    Label("Nessuna telemetria", systemImage: "hand.raised")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
            }
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .task { model.refresh() }
    }

    private func size(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
}
