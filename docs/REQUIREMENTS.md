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

## P1 — Ricerca avanzata

- Duplicati: grouping dimensione → hash preliminare → SHA-256 completo + confronto di conferma, quando necessario; verificare symlink e hard link.
- Cache e log **dell'utente**: analisi con regole specifiche per app, mai cancellazione automatica basata soltanto sull'estensione.
- Navigazione avanzata dello spazio: raggruppamento per percorso/tipo/età.
- Export report locale privo di contenuti file e con percorsi oscurabili.

## P2 — Moduli da valutare separatamente

- Ispezione delle applicazioni installate e di possibili residui, con mappatura motivata per bundle.
- Informazioni sui login item e collegamento alle Impostazioni di sistema; gestione limitata alle API consentite.
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
