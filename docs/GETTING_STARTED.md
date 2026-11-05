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
- Selezione di cartella e scanner di metadati read-only con annullamento; 9 test XCTest superati in CI.
- Motore Swift per scansione di file grandi/datati ed elenco risultati, senza accesso ai contenuti.
- Risk policy `fail-closed`: nessun finding può essere rimosso.
- Test XCTest di policy e formattazione dei dati.

## Non ancora implementato

Analisi dei contenuti, hashing, duplicati, cancellazione, spostamento nel Cestino, bookmark persistenti, report esportabili, disinstallazione e monitor sistema. Sono attivi soltanto rilevamento dei metadati e revisione informativa.

La scansione richiede la selezione esplicita di una cartella. `ScanSessionModel` avvia e termina l'accesso security-scoped per la durata del job. Questo comportamento richiede ancora prove manuali su Mac con App Sandbox e verifica della revoca dei permessi.

## Primo test dello scanner (milestone in validazione)

Aprire l'app, scegliere **Scansione**, selezionare una cartella contenente solo file sintetici, premere **Avvia scansione**, poi aprire **Risultati**. Lo scanner usa le soglie iniziali di 250 MiB o 180 giorni, limita l'analisi a 100.000 elementi e presenta al massimo 500 candidati. I file non vengono aperti né modificati e nessun elemento è cancellabile. Il codice dello scanner ha superato 9 test XCTest nel [workflow macOS ARM64](https://github.com/Frapo78/FraPoMacCleaner/actions/runs/42058024473). La scansione di una cartella sintetica è stata verificata visivamente su Mac il 5 novembre 2026: 2 file esaminati e 2 candidati correttamente motivati (314,6 MB per dimensione, file del 1 gennaio 2020 per anzianità). Restano da eseguire prove di revoca permessi, errori reali e comportamento App Sandbox su altri ambiti.

## Build scaricabili

GitHub Actions crea un **artefatto ZIP temporaneo** ad ogni push verificato su `main`. Le GitHub Release ufficiali sono generate mediante tag di versione (vedi [RELEASING.md](RELEASING.md)).

## Build Apple Development firmata tramite GitHub Actions

Per avviare la build di test firmata sul runner GitHub (solo `main`), utilizzare:

```sh
gh workflow run development-sign.yml --ref main -R Frapo78/FraPoMacCleaner
gh run list --workflow development-sign.yml -R Frapo78/FraPoMacCleaner --limit 5
```

L'artefatto della run è uno ZIP ARM64 firmato con l'identità di **sviluppo**. Non è notarizzato e non sostituisce la release ufficiale. I secret rimangono protetti da GitHub Actions e il certificato non viene committato.

## Verifica ripartizione spazio (alpha.6)

Aprire **Scansione**, selezionare una cartella sintetica con file di più tipi ed eseguire l'analisi. In **Risultati** devono apparire i riepiloghi **Per tipo di file** e **Per sottocartella**. I totali comprendono anche file piccoli non segnalati come candidati. Verificare che siano definiti esplicitamente come dimensioni logiche, non spazio fisico liberabile, e che l'app non proponga cancellazioni.
