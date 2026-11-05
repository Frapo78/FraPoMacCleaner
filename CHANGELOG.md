# Changelog

Le versioni seguono [Semantic Versioning](https://semver.org/lang/it/).

## v0.1.0-alpha.10 (2026-11-05) — diagnosi ordinaria e avvii utente

- Nuove sezioni **Manutenzione** e **Avvii automatici** nella navigazione SwiftUI.
- **Log utente:** ispezione solo dopo selezione esplicita di `~/Library/Logs`; individuazione metadati di `.log`, log ruotati e rapporti `.ips/.crash/.hang/.spin/.diag` non modificati da almeno 30 giorni. Nessuna lettura del contenuto.
- **Residui Xcode:** ispezione opt-in di `~/Library/Developer/Xcode/DerivedData`, raggruppata per cartella progetto. Nessuna inferenza che una build sia inutilizzata.
- **Avvii in background:** inventario dei file `.plist` di `~/Library/LaunchAgents` selezionata dall'utente; lo stato attivo/non attivo non è deducibile dal file. Collegamento ufficiale `SMAppService.openSystemSettingsLoginItems()` alle Impostazioni macOS.
- Policy di cartelle strettamente consentite, validazione di directory reali, divieto di attraversare symlink o device diversi, esclusione di file con hard link e di file non appartenenti all'utente. Limite di 20.000 elementi e 200 risultati visualizzabili; scansioni annullabili.
- Attivazione dell'accesso security-scoped soltanto durante il lavoro. Il percorso home è ricavato dall'account dell'utente, non dalla home del container sandbox.
- Tutti i risultati restano **protetti**: nessun Cestino, cancellazione, comando privilegiato, modifica di `.plist`, terminazione processi o gestione diretta di servizi.
- **30 test XCTest superati** su macOS ARM64 / Xcode 16.4, incluso il nuovo inventario sintetico: [CI](https://github.com/Frapo78/FraPoMacCleaner/actions/runs/42105807359).
- Da verificare manualmente selezione delle cartelle reali in App Sandbox, permessi/revoca e prestazioni. Questa versione non dichiara spazio recuperabile né miglioramento automatico delle prestazioni.

## v0.1.0-alpha.9 (2026-11-05) — contabilità filesystem e filtri scansione

- Nuovi preset **dimensione minima 50/250/500/1024 MiB** e **anzianità 30/90/180/365 giorni**, applicati alla singola scansione. Il report mostra e conserva le soglie effettive.
- Lettura di metadati POSIX con `lstat` senza aprire i contenuti; la scansione salta elementi su **device diverso** dalla radice selezionata.
- Riconoscimento dei file con più hard link: conteggi di percorsi, inode distinti e riferimenti ripetuti, senza confonderli con duplicati eliminabili.
- Nuova misurazione dei **blocchi allocati osservati** per inode distinto, separata dalla somma delle dimensioni logiche per percorso. Le statistiche **non** sono una stima di spazio recuperabile, per limiti APFS/cloni/snapshot/file sparse.
- La schermata Risultati segnala gli hard link e la dimensione allocata osservata per i candidati, oltre ai totali di analisi; l'export JSON privato include soltanto aggregati e soglie, senza nomi, percorsi o identità inode.
- **23 test XCTest superati** su macOS ARM64, compresi hard link reali, file sparse, regola dei volumi e soglie invalide: [CI](https://github.com/Frapo78/FraPoMacCleaner/actions/runs/42100723365).
- Aggiornati roadmap, documentazione tecnica, test, sicurezza, privacy e ADR-0006.
- Rimangono aperti test manuali di volume montato, permessi/revoca, prestazioni su 10k–100k file, cloni APFS e snapshot. Nessuna API di cancellazione o operazione di pulizia disponibile.

## v0.1.0-alpha.8 (2026-11-05) — esploratore dei risultati e report privato

- Esploratore risultati con ricerca locale per nome e percorso, filtri per file grandi/datati e tipo, quattro ordinamenti (dimensione, anzianità, modifica più recente, nome).
- Distinzione tipizzata del motivo della segnalazione, senza dedurre eliminabilità o sicurezza da dimensione e data.
- Riepiloghi delle categorie ed esclusioni espandibili e scorrevoli, per mantenere la lista utilizzabile su finestre compatte.
- Esportazione facoltativa di **JSON anonimo** con conteggi e categorie aggregate tramite dialogo di salvataggio di macOS. Esclusi intenzionalmente nomi file, percorsi, etichette delle cartelle e inventari.
- Tutte le voci rimangono protette: nessuna selezione per la pulizia o API distruttiva.
- **18 test XCTest superati** su macOS ARM64 / Xcode 16.4, inclusi ricerca, filtri, ordinamenti, protezione e riservatezza dell'export. [CI](https://github.com/Frapo78/FraPoMacCleaner/actions/runs/42066402117).
- Esclusi i casi di revoca dei permessi e test manuali di UI/export, ancora da validare sul Mac prima di chiudere la Fase 1.

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
