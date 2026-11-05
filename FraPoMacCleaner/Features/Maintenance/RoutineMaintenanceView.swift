import AppKit
import ServiceManagement
import SwiftUI
import UniformTypeIdentifiers

struct RoutineMaintenanceView: View {
    @StateObject private var model = RoutineInspectionModel()
    @State private var showingPicker = false
    @State private var requestedArea: RoutineArea = .userLogs

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
                Text("La gestione di tutti gli elementi di login è disponibile nelle Impostazioni di sistema. L'inventario qui riguarda soltanto i file .plist della cartella utente selezionata.")
                    .font(.callout)
                Button("Apri Elementi login nelle Impostazioni") {
                    SMAppService.openSystemSettingsLoginItems()
                }
                Button("Ispeziona ~/Library/LaunchAgents…") {
                    requestedArea = .userLaunchAgents
                    showingPicker = true
                }
            } else {
                GroupBox("Diagnosi guidata") {
                    VStack(alignment: .leading, spacing: 10) {
                        Button("Analizza ~/Library/Logs…") {
                            requestedArea = .userLogs
                            showingPicker = true
                        }
                        Text("Solo log e rapporti diagnostici dell'utente non modificati da almeno 30 giorni.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Button("Analizza build Xcode (DerivedData)…") {
                            requestedArea = .xcodeDerivedData
                            showingPicker = true
                        }
                        Text("Raggruppa per progetto i file di compilazione osservabili; anche le build vecchie possono servire.")
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
                Text(message).foregroundStyle(.red)
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
        .fileImporter(isPresented: $showingPicker, allowedContentTypes: [.folder],
                      allowsMultipleSelection: false) { result in
            if case .success(let urls) = result, let first = urls.first {
                model.inspect(area: requestedArea, folder: first)
            }
        }
    }
}
