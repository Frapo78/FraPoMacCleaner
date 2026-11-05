import AppKit
import ServiceManagement
import SwiftUI

struct RoutineMaintenanceView: View {
    @StateObject private var model = RoutineInspectionModel()

    let startupOnly: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(startupOnly ? "Avvii in background" : "Manutenzione ordinaria")
                .font(.largeTitle.bold())
            Text(startupOnly
                ? "Inventario di agenti dell'utente, non dei processi attualmente attivi."
                : "Diagnosi prudente di log e residui di compilazione: nessun file viene modificato.")
                .foregroundStyle(.secondary)

            if startupOnly {
                Text("La gestione completa degli elementi di login è nelle Impostazioni di sistema. Qui controlli solo gli agenti configurati nella tua cartella personale.")
                    .font(.callout)
                Button("Gestisci gli avvii del Mac") {
                    SMAppService.openSystemSettingsLoginItems()
                }
                Button("Controlla gli avvii automatici") {
                    model.inspect(area: .userLaunchAgents)
                }
                .disabled(model.state == .loading)
            } else {
                GroupBox("Diagnosi guidata") {
                    VStack(alignment: .leading, spacing: 10) {
                        Button("Controlla i log") {
                            model.inspect(area: .userLogs)
                        }
                        .disabled(model.state == .loading)
                        Text("Solo log e rapporti diagnostici dell'utente non modificati da almeno 30 giorni.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Button("Controlla i file temporanei") {
                            model.inspect(area: .xcodeDerivedData)
                        }
                        .disabled(model.state == .loading)
                        Text("Cerca file creati da Xcode durante lo sviluppo. Anche quelli vecchi possono servire.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(4)
                }
            }

            if model.state == .loading {
                HStack {
                    ProgressView()
                    Text("Analisi dei soli metadati…")
                    Button("Annulla") { model.cancel() }
                }
            }
            if model.state == .cancelled {
                Text("Analisi annullata, senza modifiche.")
                    .foregroundStyle(.secondary)
            }
            if let message = model.message {
                Label(message, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let report = model.report {
                HStack {
                    Text(report.area.label).font(.headline)
                    Spacer()
                    Label("Solo lettura", systemImage: "lock.shield")
                        .foregroundStyle(.secondary)
                }
                Text("\(report.entries.count) voci mostrate · \(report.inspectedItemCount) elementi visitati · \(report.skippedItemCount) esclusi · \(report.errorCount) errori")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if report.area != .userLaunchAgents {
                    Text("Somma logica osservata: \(ByteCountFormatter.string(fromByteCount: report.observedLogicalBytes, countStyle: .file)). Non è spazio recuperabile.")
                        .font(.caption)
                }
                if report.reachedLimit {
                    Text("Limite di analisi o visualizzazione raggiunto: elenco parziale.")
                        .foregroundStyle(.orange)
                }
                if report.entries.isEmpty {
                    ContentUnavailableView("Nessuna voce rilevata", systemImage: "checkmark.shield",
                        description: Text("La cartella può essere vuota oppure gli elementi non rientrano nelle regole prudenti."))
                } else {
                    List(report.entries) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(item.label).font(.headline)
                                Spacer()
                                if let size = item.logicalSizeBytes {
                                    Text(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))
                                        .font(.caption).monospacedDigit()
                                }
                            }
                            Text(item.description).font(.caption).foregroundStyle(.secondary)
                            if let date = item.modifiedAt {
                                Text(date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Button("Mostra nel Finder") {
                                NSWorkspace.shared.activateFileViewerSelecting([item.url])
                            }
                            .buttonStyle(.link)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            Text("I file e gli agenti restano protetti: non è consentita alcuna cancellazione o disattivazione. Non vengono richiesti privilegi elevati.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
