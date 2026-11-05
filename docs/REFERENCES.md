# Riferimenti tecnici (fonti primarie Apple)

Questi collegamenti guidano la progettazione; verificare disponibilità e comportamento delle API rispetto alla versione minima effettiva di macOS al momento dell'implementazione.

- [Apple — FileManager.trashItem(at:resultingItemURL:)](https://developer.apple.com/documentation/foundation/filemanager/trashitem(at:resultingitemurl:)) — API nativa per spostare nel Cestino, con risultato per elemento.
- [Apple — Accessing files from the macOS App Sandbox](https://developer.apple.com/documentation/security/accessing-files-from-the-macos-app-sandbox) — selezione file, scope e security-scoped bookmarks.
- [Apple — SMAppService](https://developer.apple.com/documentation/servicemanagement/smappservice) — stato/gestione di servizi e helper appartenenti alla propria app. **Non** è una API generica per disabilitare qualunque login item di terzi.
- [Apple — App Sandbox](https://developer.apple.com/documentation/security/app-sandbox) — vincoli di accesso e modello di autorizzazione.
- [Apple — FileManager](https://developer.apple.com/documentation/foundation/filemanager) — enumerazione, risorse e operazioni filesystem.
- [Apple — CryptoKit](https://developer.apple.com/documentation/cryptokit) — hashing per la futura fase duplicati.
- [Apple — Notarizing macOS software before distribution](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution) — distribuzione firmata/notarizzata.

## Questioni da verificare sperimentalmente

1. Differenze nel comportamento di `trashItem` per volumi locali, esterni e permessi.
2. Possibilità e limiti dei security-scoped bookmarks nel modello distributivo scelto.
3. Accesso a metadati dei file senza scaricare placeholder cloud.
4. Stime affidabili della reale occupazione APFS con cloni/snapshot e file sparsi.
5. Capacità informative delle API pubbliche per login items di app terze.

Non inferire dal semplice nome di un'API capacità che non documenta.

