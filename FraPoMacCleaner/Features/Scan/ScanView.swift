import SwiftUI
import UniformTypeIdentifiers

/// La scelta di una cartella non innesca una scansione.
struct ScanView: View {
    @State private var showingPicker = false
    @State private var folder: URL?
    @State private var pickerError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Scansione").font(.largeTitle.bold())
            Text("Il motore di analisi è in preparazione: nessun file verrà letto.")
                .foregroundStyle(.secondary)

            GroupBox("Cartella") {
                VStack(alignment: .leading, spacing: 12) {
                    Button("Seleziona una cartella…") { showingPicker = true }
                    if let folder {
                        Text("Selezionata: \(folder.lastPathComponent)")
                    } else {
                        Text("Nessuna cartella selezionata")
                            .foregroundStyle(.secondary)
                    }
                    if let pickerError {
                        Text(pickerError).foregroundStyle(.red)
                    }
                    Button("Avvia scansione") {}
                        .disabled(true)
                    Text("Il pulsante sarà abilitato solo dopo i test del motore read-only.")
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
                folder = urls.first
                pickerError = nil
            case .failure(let error):
                pickerError = error.localizedDescription
            }
        }
    }
}
