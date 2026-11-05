import SwiftUI

struct ResultsView: View {
    var body: some View {
        ContentUnavailableView(
            "Nessun risultato",
            systemImage: "doc.text.magnifyingglass",
            description: Text("I risultati saranno disponibili dopo l'introduzione della scansione di sola lettura.")
        )
        .navigationTitle("Risultati")
    }
}
