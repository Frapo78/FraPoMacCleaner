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
                    if report.skippedItemCount > 0 || report.errorCount > 0 {
                        GroupBox("Esclusioni e problemi di lettura") {
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(report.exclusionSummary) { entry in
                                    HStack {
                                        Text(entry.reason.label)
                                        Spacer()
                                        Text(entry.count.formatted())
                                            .monospacedDigit()
                                    }
                                }
                                ForEach(report.issueSummary) { entry in
                                    HStack {
                                        Label(entry.issue.label, systemImage: "exclamationmark.triangle")
                                        Spacer()
                                        Text(entry.count.formatted())
                                            .monospacedDigit()
                                    }
                                }
                                Text("Le cartelle escluse non vengono esplorate e i loro contenuti non sono conteggiati. Nessun permesso viene aggirato.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(6)
                        }
                    }
                    if report.inspectedFileCount > 0 {
                        GroupBox("Dove si concentra lo spazio analizzato") {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(alignment: .top, spacing: 16) {
                                    summaryColumn(
                                        "Per tipo di file",
                                        groups: report.fileCategories,
                                        total: report.observedLogicalBytes
                                    )
                                    summaryColumn(
                                        "Per sottocartella",
                                        groups: report.firstLevelFolders,
                                        total: report.observedLogicalBytes
                                    )
                                }
                                Text("Somma delle dimensioni logiche dei soli file esaminati: non è lo spazio fisico occupato né recuperabile. Hard link, cloni APFS ed elementi esclusi possono alterare il confronto con il disco.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(6)
                        }
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

    private func summaryColumn(
        _ title: String,
        groups: [ScanSizeGroup],
        total: Int64
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            ForEach(Array(groups.prefix(4))) { group in
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(group.label)
                            .lineLimit(1)
                        Spacer(minLength: 6)
                        Text(ByteCountFormatter.string(
                            fromByteCount: group.logicalSizeBytes,
                            countStyle: .file
                        ))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    }
                    .font(.caption)
                    ProgressView(value: total > 0
                        ? Double(group.logicalSizeBytes) / Double(total)
                        : 0)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
