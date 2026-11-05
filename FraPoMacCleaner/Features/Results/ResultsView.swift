import AppKit
import SwiftUI

struct ResultsView: View {
    @ObservedObject var model: ScanSessionModel

    var body: some View {
        Group {
            if let report = model.report {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Risultati").font(.largeTitle.bold())
                    Text("\(report.candidateCount) file da verificare · \(report.inspectedFileCount) esaminati")
                        .foregroundStyle(.secondary)
                    if report.reachedLimit || report.candidateCount > report.findings.count {
                        Text("Elenco parziale: vengono mostrati al massimo i 500 candidati più grandi.")
                            .foregroundStyle(.orange)
                    }
                    if report.errorCount > 0 {
                        Text("\(report.errorCount) elementi non accessibili o con metadati mancanti.")
                            .foregroundStyle(.orange)
                    }
                    if report.findings.isEmpty {
                        ContentUnavailableView(
                            "Nessun file segnalato",
                            systemImage: "checkmark.shield",
                            description: Text("Non sono stati trovati file oltre le soglie di dimensione o anzianità.")
                        )
                    } else {
                        List(report.findings) { item in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(item.fileURL.lastPathComponent)
                                    .font(.headline)
                                    .textSelection(.enabled)
                                Text(item.fileURL.deletingLastPathComponent().path)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .textSelection(.enabled)
                                HStack(spacing: 16) {
                                    Text(ByteCountFormatter.string(
                                        fromByteCount: item.logicalSizeBytes,
                                        countStyle: .file
                                    ))
                                    if let date = item.modifiedAt {
                                        Text(date.formatted(date: .abbreviated, time: .omitted))
                                    }
                                    Label("Solo lettura", systemImage: "lock.shield")
                                        .foregroundStyle(.secondary)
                                }
                                .font(.caption)
                                Text(item.explanation)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Button("Mostra nel Finder") {
                                    NSWorkspace.shared.activateFileViewerSelecting([item.fileURL])
                                }
                                .buttonStyle(.link)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                .padding(24)
            } else if model.phase == .scanning {
                ProgressView("Analisi in corso…")
            } else {
                ContentUnavailableView(
                    "Nessun risultato",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text("Seleziona una cartella e avvia la scansione di sola lettura.")
                )
            }
        }
        .navigationTitle("Risultati")
    }
}
