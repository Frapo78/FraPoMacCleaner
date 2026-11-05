# Changelog

Le versioni seguono [Semantic Versioning](https://semver.org/lang/it/).

## v0.1.0-alpha.7 (2026-11-05) — avanzamento e diagnostica

- Avanzamento della scansione con contatori reali di elementi visitati, file esaminati, candidati, esclusioni e problemi di lettura.
- Snapshot di progresso iniziale, finale e ogni 128 elementi per ridurre l'impatto sulla UI; nessuna percentuale inventata.
- Diagnostica sintetica raggruppata per motivo: percorsi protetti, symlink, pacchetti, cloud, tipi non supportati, problemi di accesso e metadati mancanti.
- Nessuna registrazione di percorsi esclusi, contenuti dei file o dettagli sensibili di accesso. Le directory escluse non vengono esplorate.
- Progressi di sessioni annullate o sostituite ignorati dalla UI.
- **13 XCTest superati** su GitHub Actions macOS ARM64 / Xcode 16.4: [risultati CI](https://github.com/Frapo78/FraPoMacCleaner/actions/runs/42063148205).
- Pulizia, disinstallazione e cancellazione restano disabilitate; test manuale di accessi e progressi ancora da completare.

## v0.1.0-alpha.6 (2026-11-05) — distribuzione dello spazio e categorie

- Analisi **read-only** della dimensione logica per categoria di file e per sottocartella di primo livello nella cartella scelta.
- Raggruppamenti calcolati su tutti i file regolari accessibili, non solo sui candidati segnalati per dimensione o anzianità.
- Interfaccia Risultati con riepiloghi, barre proporzionali e legenda che distingue dimensione logica, occupazione effettiva e spazio recuperabile.
- Classificazione tramite estensione, senza leggere o trasmettere i contenuti; esclusioni e annullamento mantenuti.
- Due test aggiuntivi per classificazione e aggregazione, **11 XCTest superati** su macOS ARM64 / Xcode 16.4: [build CI](https://github.com/Frapo78/FraPoMacCleaner/actions/runs/42060620420).
- Revisione di architetture e funzionalità di progetti pubblici: nessun codice esterno copiato o dipendenza introdotta.
- Pulizia, disinstallazione e manutenzione attiva restano **disabilitate**.

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
