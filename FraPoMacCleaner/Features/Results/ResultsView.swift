import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct ResultsView: View {
    @ObservedObject var model: ScanSessionModel
    @State private var searchText = ""
    @State private var reasonFilter: ScanResultReasonFilter = .all
    @State private var categoryFilter: ScanFileCategory?
    @State private var sortOrder: ScanResultSort = .largest
    @State private var exportError = ""
    @State private var showingExportError = false
    @State private var showingScanDetails = false

    var body: some View {
        Group {
            if let report = model.report {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Risultati").font(.largeTitle.bold())
                    Text("\(report.candidateCount) file da verificare · \(report.inspectedFileCount) esaminati")
                        .foregroundStyle(.secondary)
                    HStack {
                        Label("Tutti protetti dalla rimozione", systemImage: "lock.shield")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer(minLength: 8)
                        Button("Esporta riepilogo anonimo…") { exportSummary(report) }
                            .help("Esporta soltanto conteggi e categorie: nessun nome o percorso")
                    }

                    if report.reachedLimit || report.candidateCount > report.findings.count {
                        Text("Elenco parziale: vengono mostrati al massimo i 500 candidati più grandi.")
                            .foregroundStyle(.orange)
                    }
                    if report.errorCount > 0 {
                        Text("\(report.errorCount) elementi non accessibili o con metadati mancanti.")
                            .foregroundStyle(.orange)
                    }
                    if report.hardLinkedEntryCount > 0 {
                        Text("\(report.hardLinkedEntryCount) percorsi con più hard link: non considerarli copie eliminabili.")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                    if report.inspectedFileCount > 0 || report.skippedItemCount > 0 || report.errorCount > 0 {
                        DisclosureGroup(isExpanded: $showingScanDetails) {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 10) {
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
                                Divider()
                                Text("Dimensione logica (tutti i percorsi): \(ByteCountFormatter.string(fromByteCount: report.observedLogicalBytes, countStyle: .file))")
                                Text("Dimensione logica (inode distinti): \(ByteCountFormatter.string(fromByteCount: report.observedUniqueLogicalBytes, countStyle: .file))")
                                Text("Blocchi allocati osservati (inode distinti): \(ByteCountFormatter.string(fromByteCount: report.observedAllocatedBytes, countStyle: .file))")
                                if report.repeatedHardLinkEntryCount > 0 {
                                    Text("\(report.repeatedHardLinkEntryCount) collegamenti aggiuntivi dello stesso inode")
                                }
                                Text("Valori osservati, non spazio recuperabile. Cloni APFS, compressione, snapshot e file esclusi possono condividere blocchi o alterare i totali.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(6)
                        }
                    }
                                }
                            }
                            .frame(maxHeight: 225)
                        } label: {
                            Label("Riepilogo spazio ed esclusioni", systemImage: "chart.bar.xaxis")
                                .font(.headline)
                        }
                    }
                    if report.findings.isEmpty {
                        ContentUnavailableView(
                            "Nessun file segnalato",
                            systemImage: "checkmark.shield",
                            description: Text("Non sono stati trovati file oltre le soglie di dimensione o anzianità.")
                        )
                    } else {
                        HStack(spacing: 12) {
                            TextField("Cerca nome o percorso", text: $searchText)
                                .textFieldStyle(.roundedBorder)
                                .accessibilityLabel("Cerca risultati")
                            Picker("Motivo", selection: $reasonFilter) {
                                ForEach(ScanResultReasonFilter.allCases) { option in
                                    Text(option.label).tag(option)
                                }
                            }
                            .pickerStyle(.menu)
                            Picker("Tipo", selection: $categoryFilter) {
                                Text("Tutti i tipi").tag(nil as ScanFileCategory?)
                                ForEach(ScanFileCategory.allCases, id: \.self) { kind in
                                    Text(kind.label).tag(kind as ScanFileCategory?)
                                }
                            }
                            .pickerStyle(.menu)
                            Picker("Ordina", selection: $sortOrder) {
                                ForEach(ScanResultSort.allCases) { option in
                                    Text(option.label).tag(option)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        Text("\(visibleFindings(report).count) di \(report.findings.count) risultati visualizzati (massimo 500 conservati per scansione)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if visibleFindings(report).isEmpty {
                            ContentUnavailableView(
                                "Nessun risultato corrispondente",
                                systemImage: "line.3.horizontal.decrease.circle",
                                description: Text("Modifica i filtri o la ricerca.")
                            )
                        } else {
                            List(visibleFindings(report)) { item in
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
                                    if item.hasMultipleHardLinks {
                                        Label("Hard link", systemImage: "link")
                                            .foregroundStyle(.orange)
                                    }
                                }
                                .font(.caption)
                                if let allocated = item.allocatedSizeBytes {
                                    Text("Blocchi allocati osservati: \(ByteCountFormatter.string(fromByteCount: allocated, countStyle: .file))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Text(item.explanation)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Label(
                                    "Protetto: una segnalazione non prova che il file sia superfluo",
                                    systemImage: "shield.lefthalf.filled"
                                )
                                .font(.caption2)
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
        .alert("Esportazione non riuscita", isPresented: $showingExportError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(exportError)
        }
    }

    private func visibleFindings(_ report: ScanReport) -> [ScanFinding] {
        ScanResultExplorer.apply(
            report.findings,
            search: searchText,
            reason: reasonFilter,
            category: categoryFilter,
            sort: sortOrder
        )
    }

    @MainActor
    private func exportSummary(_ report: ScanReport) {
        let panel = NSSavePanel()
        panel.title = "Esporta riepilogo anonimo"
        panel.nameFieldStringValue = "FraPoMacCleaner-riepilogo.json"
        panel.canCreateDirectories = true
        panel.allowedContentTypes = [.json]
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try ScanSummaryExporter.encode(report).write(to: url, options: .atomic)
        } catch {
            exportError = error.localizedDescription
            showingExportError = true
        }
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
