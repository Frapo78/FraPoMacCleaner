# Primo avvio in Xcode

## Requisiti

- Mac Apple Silicon con Xcode aggiornato.
- SDK macOS compatibile con il deployment target provvisorio **macOS 14+**.
- Repository clonato; nessuna dipendenza esterna richiesta.

## Aprire e testare

```sh
git clone https://github.com/Frapo78/FraPoMacCleaner.git
cd FraPoMacCleaner
open FraPoMacCleaner.xcodeproj
```

Seleziona lo schema condiviso **FraPoMacCleaner** e la destinazione **My Mac**. Premi `⌘B` per compilare e `⌘R` per avviare.

Per verificare da terminale (Xcode completo, non solo Command Line Tools):

```sh
xcodebuild -list -project FraPoMacCleaner.xcodeproj
xcodebuild -project FraPoMacCleaner.xcodeproj \
  -scheme FraPoMacCleaner -configuration Debug \
  -destination 'platform=macOS,arch=arm64' \
  CODE_SIGNING_ALLOWED=NO build

xcodebuild -project FraPoMacCleaner.xcodeproj \
  -scheme FraPoMacCleaner -configuration Debug \
  -destination 'platform=macOS,arch=arm64' \
  CODE_SIGNING_ALLOWED=NO test
```

Le prove di build e test reali vanno registrate con ambiente e risultato; **La CI ARM64 è stata completata con successo il 5 novembre 2026**: [build/test workflow](https://github.com/Frapo78/FraPoMacCleaner/actions/runs/42024897794). La compilazione su un Mac locale va verificata separatamente.

## Funzionalità dello scheletro

- Navigazione SwiftUI tra Panoramica, Scansione, Risultati e Impostazioni.
- Lettura non distruttiva dei metadati di capacità del volume home.
- Selettore di cartella senza scansione.
- Contratti Swift per scanner, finding, scope e policy.
- Risk policy `fail-closed`: nessun finding può essere rimosso.
- Test XCTest di policy e formattazione dei dati.

## Non ancora implementato

Analisi dei file, hashing, duplicati, cancellazione, spostamento nel Cestino, bookmark persistenti, report, disinstallazione e monitor sistema. Il pulsante scansione è disabilitato, anche se si seleziona una cartella.

Gli URL restituiti dal selettore **non vengono letti dallo scanner**; l'accesso security-scoped verrà progettato e testato prima di implementare l'enumerazione.

## Build scaricabili

GitHub Actions crea un **artefatto ZIP temporaneo** ad ogni push verificato su `main`. Le GitHub Release ufficiali sono generate mediante tag di versione (vedi [RELEASING.md](RELEASING.md)).
