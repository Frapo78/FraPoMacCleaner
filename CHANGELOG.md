# Changelog

Le versioni seguono [Semantic Versioning](https://semver.org/lang/it/).

## v0.1.0-alpha.5 (2026-11-05) — prima scansione di sola lettura

- Selezione esplicita di una cartella e scansione ricorsiva **solo metadati**, cancellabile; nessun file aperto, spostato o eliminato.
- Individuazione informativa di file con dimensione logica almeno **250 MiB** o non modificati da almeno **180 giorni**.
- Nuove schermate Scansione e Risultati collegate da una sessione condivisa; file consultabili e apertura nel Finder.
- Esclusione conservativa di symlink, pacchetti applicativi, aree di sistema, directory sensibili, contenuti cloud e file di credenziali.
- Analisi limitata a **100.000 elementi** e visualizzazione di **500 candidati** al massimo; conteggi di elementi ignorati, errori e risultati parziali.
- **9 test XCTest superati su macOS 15 / Xcode 16.4**: file grandi/vecchi, esclusioni, integrità, link simbolici, cancel e limiti. Nessuna operazione di pulizia disponibile.
- Riorganizzate le ADR in `docs/DECISIONS` per evitare conflitti tra maiuscole e minuscole nei clone macOS.
- Eliminata una risorsa icona orfana che generava avvisi nella compilazione.
- Build firmata Apple Development disponibile soltanto come artefatto di workflow di sviluppo; prerelease pubblica non notarizzata.
- Prima prova manuale completata il 5 novembre 2026 su Mac: 2 file sintetici analizzati e 2 risultati corretti nella UI. Restano da verificare revoca autorizzazioni, grandi alberi e limiti della sandbox.

## v0.1.0-alpha.4 (2026-11-05) — ripristino asset originali

- Logo trasparente sostituito con il PNG originale **1460×285**, senza ingrandimenti di miniature.
- Icona macOS sostituita con il PNG originale **1024×1024**; varianti piccole rigenerate per riduzione.
- Interpolazione SwiftUI impostata su qualità alta per il logo.
- Aggiunta la verifica automatica di SHA-256 e dimensioni dei PNG in CI e release.
- Non sono state abilitate operazioni di scansione o pulizia.

## v0.1.0-alpha.3 (2026-11-05) — identità visiva nativa

- Catalogo AppIcon macOS con varianti 16–1024 px integrate in Xcode e nella build.
- Logo orizzontale disponibile in `Assets.xcassets` e mostrato nella dashboard e nella barra laterale.
- Versione bundle incrementata, build ZIP ARM64 e test automatici.
- Le risorse attuali derivano da un'anteprima ridimensionata: sostituire con gli originali ad alta risoluzione in un prossimo aggiornamento per la massima nitidezza.
- Scanner e pulizia restano deliberatamente inattivi.

## v0.1.0-alpha.2 (2026-11-05) — primo ZIP di prova

Il precedente tentativo di pubblicazione non è riuscito per una configurazione errata dei test Release; non ha prodotto alcuna release. È stata separata l'esecuzione XCTest Debug dalla compilazione finale Release.

Release sperimentale per il solo sviluppo: interfaccia navigabile, provider disco di sola lettura, struttura modulare e CI ARM64. La pulizia dei file è disabilitata. Il pacchetto prerelease non è firmato per distribuzione pubblica né notarizzato.

## Unreleased

### Added
- Scheletro macOS arm64 SwiftUI con navigazione e provider dei metadati disco.
- Contratti di scansione di sola lettura e policy `fail-closed`.
- Test XCTest iniziali.
- Infrastruttura CI, build ZIP e release semantiche con notarizzazione obbligatoria per release stabili.

### Security
- Nessuna API di cancellazione o manutenzione attiva nel prototipo.

La prima build e i test XCTest risultano superati nel workflow CI del 2026-11-05. La funzionalità di pulizia rimane assente.
