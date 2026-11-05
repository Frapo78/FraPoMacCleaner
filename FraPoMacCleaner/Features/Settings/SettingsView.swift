import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section("Autorizzazioni") {
                Text("Le cartelle saranno accessibili solo con consenso esplicito.")
                    .foregroundStyle(.secondary)
            }
            Section("Sicurezza") {
                LabeledContent("Pulizia", value: "Disabilitata")
                LabeledContent("Telemetria", value: "Assente")
            }
            Section("Informazioni") {
                LabeledContent("App", value: "FraPoMacCleaner")
                LabeledContent("Versione", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0")
                LabeledContent("Canale", value: "Alpha")
            }
        }
        .formStyle(.grouped)
        .padding(12)
        .frame(minWidth: 480, minHeight: 300)
        .navigationTitle("Impostazioni")
    }
}
