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

## Verifica avanzamento e diagnostica (alpha.7)

Dopo una scansione avviata esplicitamente, la sezione **Scansione** mostra il numero di elementi visitati, i file esaminati, i candidati, gli elementi esclusi e i problemi di lettura. Il totale di elementi non è noto prima della fine: il progresso è **indeterminato**, non una percentuale di spazio recuperabile. Aggiornamenti ogni 128 elementi più snapshot iniziale e finale.

La sezione **Risultati** presenta i conteggi per causa: percorsi protetti, symlink, pacchetti, elementi cloud, tipi non supportati; inoltre problemi di accesso a cartelle e metadati mancanti. I conteggi non includono i contenuti delle directory escluse, che non vengono attraversate. Nessun percorso di file escluso o errore viene salvato nella diagnostica.

Prova manuale: selezionare una cartella sintetica con almeno 300 file piccoli, alcuni elementi di prova esclusi e sottocartelle; osservare l'incremento dei contatori. Annullare una scansione più ampia e verificare che non vengano visualizzati risultati nuovi dalla scansione annullata. Restano da testare la revoca dei permessi, gli errori di accesso e la responsività su directory reali molto grandi.

## Esploratore e rapporto anonimo (alpha.8)

Dopo una scansione di fixture, aprire **Risultati**. Usare il campo di ricerca (nome o percorso), il filtro **Motivo** (tutti/grandi/datati), il filtro **Tipo** e l'ordinamento **Dimensione / Più vecchi / Più recenti / Nome**. I filtri agiscono soltanto sui candidati mantenuti in memoria (massimo 500), non interrogano nuovamente il filesystem. Il pannello **Riepilogo spazio ed esclusioni** è espandibile.

Il pulsante **Esporta riepilogo anonimo…** apre il pannello di salvataggio macOS e genera su richiesta un JSON locale. Il documento contiene solo conteggi complessivi, tipologie note ed esclusioni/errori aggregati: **nessun nome, percorso, elenco dei file o etichetta delle sottocartelle**. Non includere mai il rapporto nei log pubblici senza averlo prima letto: anche i conteggi possono essere considerati informazioni private. L'app non salva il report automaticamente.

Test manuale: creare una cartella sintetica contenente file di almeno due tipologie, sia grandi sia datati. Verificare filtri, ordinamenti, ricerca case-insensitive, azzeramento dei filtri e apertura nel Finder. Esportare il JSON e verificarne l'assenza di nomi e percorsi specifici. Nessuna funzione di cancellazione deve comparire.

## Test manuale inode e soglie (alpha.9)

Per una cartella di prova distinta dai dati reali, su macOS:

```sh
mkdir -p "$HOME/Downloads/FraPoAlpha9Fixture"
mkfile -n 600m "$HOME/Downloads/FraPoAlpha9Fixture/sparse.mov"
ln "$HOME/Downloads/FraPoAlpha9Fixture/sparse.mov" "$HOME/Downloads/FraPoAlpha9Fixture/hardlink.mov"
touch -t 202001010000 "$HOME/Downloads/FraPoAlpha9Fixture/old.txt"
```

Se i file esistono già, **non eseguire nuovamente questi comandi** sulla stessa cartella: usare una nuova directory di prova per evitare errori o sovrascritture.

Scegliere la cartella dalla sezione **Scansione**, selezionare le soglie desiderate e avviare. In **Risultati** i due `.mov` devono risultare percorsi distinti con indicazione *Hard link*, ma con un solo inode nel conteggio univoco. La somma logica per percorsi può essere più alta del totale per inode; i blocchi allocati osservati possono essere molto inferiori per il file sparse. Cambiare le soglie e ripetere la scansione. Verificare che il riepilogo JSON contenga solo aggregati e soglie, senza nomi o identificatori inode.

I valori non costituiscono spazio recuperabile. Non testare su cartelle di lavoro o dati personali.

## Prima diagnosi ordinaria (alpha.10)

Aprire **Manutenzione** per analizzare, solo su richiesta:

- `~/Library/Logs` — file di log e diagnostica non modificati da almeno 30 giorni;
- `~/Library/Developer/Xcode/DerivedData` — riepilogo dei file di build osservati per progetto.

Aprire **Avvii automatici** per scegliere `~/Library/LaunchAgents` (solo nomi `.plist`) oppure aprire **Elementi login** nelle Impostazioni di sistema.

In ciascun caso usare il selettore cartelle per concedere accesso in lettura. Per raggiungere `~/Library` nel dialogo, premere **⌘⇧G** e digitare il percorso indicato, usando `~` come home dell'utente. Se la directory manca, non crearla con privilegi elevati: quella categoria non ha dati disponibili. La selezione di una directory diversa viene rifiutata.

Tutte le voci risultano **protette**: nessuna cancellazione di log/cache, rimozione di file plist o terminazione di processi. Un file in LaunchAgents non dimostra che l'agente sia in esecuzione. Il totale Xcode è una somma logica parziale, non spazio liberabile. Testare prima con dati non sensibili; la verifica manuale sulle cartelle reali è ancora aperta.
