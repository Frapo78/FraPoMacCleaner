import SwiftUI
import UniformTypeIdentifiers

struct ScanView: View {
    @ObservedObject var model: ScanSessionModel
    let showResults: () -> Void
    @State private var showingPicker = false
    @State private var pickerError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Scansione").font(.largeTitle.bold())
            Text("Analisi di soli metadati: nessun file viene modificato.")
                .foregroundStyle(.secondary)

            GroupBox("Cartella autorizzata") {
                VStack(alignment: .leading, spacing: 12) {
                    Button("Seleziona una cartella…") { showingPicker = true }
                        .disabled(model.phase == .scanning)
                    if let folder = model.selectedFolder {
                        Text("Selezionata: \(folder.lastPathComponent)")
                            .textSelection(.enabled)
                    } else {
                        Text("Nessuna cartella selezionata")
                            .foregroundStyle(.secondary)
                    }
                    if let pickerError {
                        Text(pickerError).foregroundStyle(.red)
                    }

                    HStack {
                        Button("Avvia scansione") { model.start() }
                            .disabled(model.selectedFolder == nil || model.phase == .scanning)
                        if model.phase == .scanning {
                            Button("Annulla") { model.cancel() }
                        }
                        if model.phase == .finished {
                            Button("Visualizza risultati") { showResults() }
                        }
                    }
                    if model.phase == .scanning {
                        ProgressView("Scansione in corso…")
                        if let progress = model.progress {
                            Text("\(progress.visitedItemCount) elementi visitati · \(progress.inspectedFileCount) file · \(progress.candidateCount) segnalati")
                                .font(.callout)
                                .monospacedDigit()
                            Text("\(progress.skippedItemCount) esclusi · \(progress.errorCount) problemi di lettura")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        Text("Avanzamento per elementi visitati; il totale non è noto in anticipo.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if model.phase == .cancelled {
                        Text("Scansione annullata. Nessuna modifica ai file.")
                            .foregroundStyle(.secondary)
                    } else if let error = model.errorMessage {
                        Text(error).foregroundStyle(.red)
                    } else if let report = model.report {
                        Text("\(report.inspectedFileCount) file esaminati · \(report.candidateCount) da verificare · \(report.skippedItemCount) esclusi · \(report.errorCount) errori")
                        if report.reachedLimit {
                            Text("Limite di elementi raggiunto: risultati parziali.")
                                .foregroundStyle(.orange)
                        }
                    }
                    Text("Non segue collegamenti simbolici e ignora cartelle sensibili. I risultati non sono selezionabili per la pulizia.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
            }
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .fileImporter(
            isPresented: $showingPicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let folder = urls.first {
                    model.selectFolder(folder)
                }
                pickerError = nil
            case .failure(let error):
                pickerError = error.localizedDescription
            }
        }
    }
}
