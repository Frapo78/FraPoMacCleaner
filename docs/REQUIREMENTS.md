# Requisiti funzionali — bozza iniziale

Le priorità sono **P0** (necessarie per il primo MVP), **P1** (iterazione successiva) e **P2** (estensioni). Dashboard e primo scanner di metadati read-only sono stati implementati, con 9 test CI superati e test manuale App Sandbox ancora da confermare. Le operazioni di pulizia restano da implementare.

## P0 — MVP: diagnosi e gestione prudente

| ID | Requisito | Criterio di accettazione |
| --- | --- | --- |
| R-001 | Selezione ambito | L'utente sceglie cartelle da analizzare; accessi negati sono riportati e non aggirati. |
| R-002 | Scansione di sola lettura | Avvio/pausa logica tramite annullamento; nessuna modifica al filesystem durante l'analisi. |
| R-003 | File grandi e datati | Dimensione, date disponibili, percorso, tipo e motivo della segnalazione. |
| R-004 | Dashboard spazio disco | Dati provenienti da sistema/volumi, con definizioni corrette e stato aggiornamento. |
| R-005 | Risultati selezionabili | Nessuna preselezione di voci a rischio; filtri e anteprima apribile in Finder. |
| R-006 | Classificazione del rischio | `safe-review`, `caution`, `protected` con motivazione, non semplice colore. |
| R-007 | Piano d'azione | Riepilogo per-file, dimensioni stimate, destinazione Cestino, conferma. |
| R-008 | Trasferimento nel Cestino | Solo file idonei e confermati; validazione immediatamente prima dell'azione. |
| R-009 | Esiti e errori | Successo/parziale/errore per ogni elemento, con motivo e possibilità di consultare il rapporto. |
| R-010 | Esclusioni | Mai toccare per impostazione predefinita cartelle protette e ambiti sensibili. |

**Sequenza P0:** prima consegna solo **R-001–R-006 in modalità read-only**; R-007–R-010 soltanto dopo test di sicurezza.

## P0 prioritario — Residui utente e processi di avvio

La funzione *Pulizia ordinaria sicura* è una priorità del prodotto, **non ancora implementata**. Si sviluppa in due milestone indipendenti:

| ID | Requisito | Criterio di accettazione |
| --- | --- | --- |
| R-011 | Diagnosi log e report obsoleti dell'utente | Inventario read-only limitato ad allowlist di directory autorizzate (fra cui `~/Library/Logs` e sottodirectory diagnostiche pertinenti), policy per-app e motivo concreto; zero letture di contenuti. |
| R-012 | Cache/residui specifici | Solo voci approvate mediante regole versionate; nessun `~/Library/Caches` indiscriminato, nessuna associazione per sola estensione. |
| R-013 | Diagnosi avvio in background | Origine e stato degli elementi di login/agenti utente solo se verificabili; per modifiche rimando alle impostazioni o API pubbliche consentite. |
| R-014 | Piano di pulizia prudentissimo | Nessuna preselezione; candidati inizialmente `protected`, promossi solo con policy esplicita, inattività dimostrabile, revisione e conferma. |
| R-015 | Spostamento nel Cestino | Solo file utente approvati, revalidati immediatamente prima dell'azione; mai cancellazione permanente o privilegi elevati. |
| R-016 | Report effettivo e limiti | Esiti reali per-file; nessuna promessa di accelerazione o recupero dei byte da stime di scansione. |

**Vincoli:** directory di sistema, log unificati macOS, `/private/var/log`, snapshot, LaunchDaemons, servizi di altri software, log attivi/in rotazione, database, backup e file cloud restano esclusi finché una specifica revisione di sicurezza non stabilisca diversamente. Rimuovere un log *non* equivale a interrompere un processo: sono operazioni distinte.

## P1 — Ricerca avanzata

- Duplicati: grouping dimensione → hash preliminare → SHA-256 completo + confronto di conferma, quando necessario; verificare symlink e hard link.
- Ampliamento delle regole di diagnosi **utente** prioritarie R-011/R-012, sempre specifiche per app e mai basate soltanto sull'estensione.
- Navigazione avanzata dello spazio: raggruppamento per percorso/tipo/età.
- Export report locale privo di contenuti file e con percorsi oscurabili.

## P2 — Moduli da valutare separatamente

- Ispezione delle applicazioni installate e di possibili residui, con mappatura motivata per bundle.
- Ampliamento della diagnostica R-013 sugli elementi di login e background, tramite le sole API e impostazioni supportate.
- Monitor prestazioni CPU/RAM/disco e processi, con overhead misurato.
- Scansioni programmate e notifiche solo su esplicita attivazione.

## Vincoli trasversali

- **Piattaforma:** macOS Apple Silicon arm64; versione minima definita dopo spike tecnico.
- **Tecnologia:** Swift/SwiftUI e framework Apple pubblici; niente Electron.
- **Conservazione dati:** calcoli locali; archivi di scansione a conservazione limitata e cancellabili.
- **Prestazioni:** coda con priorità bassa, limiti di I/O/concorrenza, cancellazione tempestiva.
- **Affidabilità:** interruzioni o permessi revocati non devono causare cancellazioni.
- **Accessibilità:** VoiceOver, riduzione movimento, Dynamic Type nei limiti di macOS e piena navigazione da tastiera.
- **Distribuzione:** app firmata e notarizzata al momento delle release; possibilità di App Sandbox oggetto di decisione esplicita.

## Definizioni

- **Dimensione logica:** dimensione apparente del file, non necessariamente byte fisici esclusivi sul disco.
- **Spazio recuperabile stimato:** valore non garantito; può differire per APFS, hard link, cloni, snapshot e file purgeable.
- **Rimozione recuperabile:** spostamento nel Cestino; recupero possibile solo finché il file rimane lì e il filesystem supporta l'operazione.
- **File sicuro:** nel contesto dell'app vuol dire «candidato a revisione a basso rischio», **non** garanzia assoluta di eliminabilità.

## Ripartizione delle dimensioni logiche (v0.1.0-alpha.6)

- Conteggi e somme per categorie di estensione, senza apertura del contenuto.
- Riepilogo delle sottocartelle dirette della cartella selezionata.
- Il totale include file regolari piccoli, anche se non segnalati fra i candidati.
- I totali **non** sono bytes fisici esclusivi né una stima dello spazio recuperabile: hard link, cloni APFS e file esclusi richiedono un trattamento distinto.
- Nessun import di codice di terze parti: implementazione nativa e originale con Foundation/SwiftUI.

## Avanzamento e report diagnostico (alpha.7)

- Visualizzare in scansione i **conteggi reali** (elementi visitati, file esaminati, candidati, esclusioni ed errori) senza inventare una percentuale o una stima temporale.
- I progressi non devono sopravvivere a scansioni annullate o alla selezione di un'altra cartella.
- Raggruppare le esclusioni per motivo e i problemi per categoria, esponendo solo contatori. I contenuti delle directory escluse non vengono visitati né conteggiati.
- Mantenere gli stessi limiti di I/O, il numero massimo di elementi e l'assenza completa di azioni di modifica/cancellazione.

## Esplorazione dei candidati e export privato (alpha.8)

- Ricerca locale su nome/percorso, filtri motivazione/categoria, ordinamento con parità deterministica e date mancanti in fondo.
- I filtri non devono cambiare i dati della scansione, modificare file o navigare fuori dall'ambito autorizzato.
- La visualizzazione distingue **segnalazione informativa** e **ammissibilità alla pulizia**, che rimane sempre `protected`.
- Export manuale JSON con soli aggregati esplicitamente autorizzati: escludere filename, percorso, timestamp per-file, elenco findings e titoli delle sottocartelle.
- Non generare report in background e non trasmetterli automaticamente.

## Primo incremento della priorità P0 (alpha.10)

- Diagnosi read-only opt-in di `~/Library/Logs`: solo file con estensioni di log/diagnostica esplicitamente riconosciute e ultima modifica di almeno 30 giorni fa. Nessun file viene considerato automaticamente eliminabile.
- Analisi per cartella di progetto di `~/Library/Developer/Xcode/DerivedData`; serve a capire l'entità delle build, non a dichiararne l'inattività.
- Elenco informativo dei soli `.plist` direttamente sotto `~/Library/LaunchAgents` e pulsante di accesso alle Impostazioni di sistema via `SMAppService`. Non equivale all'inventario di tutti i login item o processi.
- Il selettore cartelle deve autorizzare espressamente la **posizione esatta** prevista per la categoria; differenze, symlink, altri device e permessi negati bloccano o escludono l'ispezione.
- Massimo 20.000 voci visitate e 200 risultati, nessuna lettura contenuto, nessuna azione che modifichi file, agenti o impostazioni.
