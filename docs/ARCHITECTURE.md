# Architettura tecnica iniziale

**Stato: struttura Xcode e primo scanner read-only implementati; scanner verificato da 9 test CI su macOS ARM64, test manuale App Sandbox ancora da eseguire.** Cleanup non implementato. Permessi e packaging richiedono verifiche continuative.

## Stack

- Swift 6 (con adozione graduale della strict concurrency), SwiftUI + AppKit dove necessario.
- Foundation, UniformTypeIdentifiers, CryptoKit, OSLog, framework pubblici.
- Elaborazione asincrona e cancellabile (`async/await`, `actor` per stato condiviso).
- Nessun servizio cloud necessario al funzionamento; nessun helper privilegiato per il primo MVP.

## Componenti logici

~~~text
┌──────────────────────── SwiftUI / AppKit ──────────────────────────┐
│ Dashboard · Scansione · Risultati · Piano azione · Impostazioni     │
└────────────────────────────┬──────────────────────────────────────┘
                             │ ViewModels (stato UI)
┌────────────────────────────▼──────────────────────────────────────┐
│ Application Layer                                                  │
│ ScanCoordinator · PermissionCoordinator · CleanupCoordinator     │
│ Progress/Cancel · ReportCoordinator                               │
└───────────────┬──────────────────────────────┬────────────────────┘
                │                              │
┌───────────────▼──────────────────┐  ┌────────▼────────────────────┐
│ Domain / Policy                  │  │ Infrastructure / Adapters  │
│ ScanItem · Finding · RiskPolicy  │  │ FileEnumerator · Metadata  │
│ Eligibility · ActionPlan         │  │ VolumeInfo · TrashAdapter  │
│ ProtectedPaths · OperationResult │  │ ReportStore · SystemMetrics│
└──────────────────────────────────┘  └─────────────────────────────┘
~~~

**Regola chiave:** una vista o uno scanner non può chiamare direttamente una funzione distruttiva. Il coordinatore delle operazioni è l'unico punto di ingresso per azioni che mutano il filesystem.

## Flusso di scansione

1. L'utente seleziona ambiti; il PermissionCoordinator acquisisce/valida l'autorizzazione.
2. ScanCoordinator crea un'istanza di scansione cancellabile e un identificatore.
3. FileEnumerator elenca senza seguire link simbolici, ignora percorsi esclusi e raccoglie metadati disponibili.
4. Moduli di analisi producono `Finding` immutabili e motivati.
5. RiskPolicy valuta ogni candidato rispetto a denylist, tipo di file, accessibilità e informazioni disponibili.
6. UI mostra risultati **senza attivare azioni automaticamente**.
7. Il report indica anche errori, cartelle saltate, elementi non leggibili e limiti di accuratezza.

## Flusso di pulizia (fase successiva)

~~~text
Selezione esplicita
    ↓
ActionPlan immutabile + motivazione + stima
    ↓
Conferma utente
    ↓
Revalidate: identità/ambito/autorizzazione/tipo/sicurezza
    ↓
TrashAdapter (Cestino) per ciascun elemento approvato
    ↓
OperationResult per file + audit minimale + verifica spazio
~~~

L'esecuzione gestisce errori parziali; un errore su un file non autorizza a riprovare con permessi elevati. La validazione deve evitare errori TOCTOU: una verifica basata solo su stringa del percorso **non è sufficiente**. Se non si può garantire l'identità dell'oggetto in modo ragionevole, **non si esegue** l'operazione.

## Modelli concettuali

- `ScanScope`: cartella/volume, autorizzazione e filtri.
- `ScanSession`: identificatore, stato, data, progress e diagnostica.
- `FileIdentity`: URL, identificatore file/volume quando disponibile, metadati osservati (non persistenza garantita dopo riavvio).
- `Finding`: riferimento al file, categoria, dimensione apparente, spiegazione e prove.
- `RiskAssessment`: categoria, motivazione, eventuali blocchi.
- `ActionPlan`: elenco selezionato, consenso e versione dei finding.
- `OperationResult`: successo, errore, destinazione nel Cestino (quando disponibile), timestamp.

## Struttura attuale e separazione futura

~~~text
FraPoMacCleaner/
  App/                 # entrypoint e composizione dipendenze
  Features/
    Dashboard/
    Scan/
    Results/
    Cleanup/
    Settings/
  Domain/
    Models/
    Policies/
  Services/
    FileSystem/
    Volumes/
    Permissions/
    Reports/
    Metrics/
  Resources/
FraPoMacCleanerTests/
  Fixtures/
  Policy/
  Integration/
docs/
  DECISIONS/
~~~

Lo scheletro reale contiene `FraPoMacCleaner/App`, `Features`, `Domain`, `Services`, `Resources`, `Configuration` e `FraPoMacCleanerTests/Domain`. I servizi più rischiosi (TrashAdapter, CleanupCoordinator) **non esistono ancora**, intenzionalmente. La struttura illustrata è un obiettivo di evoluzione; gli altri moduli saranno aggiunti solo quando necessari.

La composizione delle dipendenze si trova in `AppDependencies`. `ReadOnlyScanEngine` enumera solo metadati delle cartelle esplicitamente scelte, con limiti, annullamento e esclusione di pacchetti e symlink. `ScanSessionModel` mantiene l'accesso security-scoped durante la scansione. `ConservativeRiskPolicy` lascia ogni risultato protetto: non esistono azioni di pulizia. Il provider del volume legge metadati senza modifiche.

## Errori, osservabilità e performance

- `OSLog` con privacy dei percorsi come default.
- Report locali minimali; nessun invio remoto.
- Progresso «elementi esaminati» quando il totale non è conoscibile; evitare percentuali arbitrarie.
- Streaming durante hash e raccolta metadati, non mantenere in RAM interi file.
- Concorrenza limitata per disco e politiche di throttling per ridurre pressione sull'SSD.
- Supporto a cancellazione, permessi revocati, file rimossi o modificati durante la scansione.

## Decisioni ancora aperte

- Minimo macOS (candidato da verificare: macOS 14+).
- App Sandbox on/off per distribuzione diretta: decidere dopo prototipo e matrice permessi; no scorciatoie implicite.
- Format di persistenza dei report (eventuale JSON/SQLite solo se utile).
- Necessità di helper per feature future: **esclusa per l'MVP**.
- Politiche di firma e notarizzazione: vedi `docs/RELEASING.md`; ZIP è il formato di distribuzione scelto.

Vedi `docs/DECISIONS/` per le scelte registrate. Tutte le ADR usano una sola cartella con maiuscole coerenti, per evitare collisioni su filesystem macOS case-insensitive.

## Aggregazione dei metadati (alpha.6)

La scansione mantiene contatori limitati per estensioni raggruppate in categorie semantiche e per il primo livello di sottocartelle. `ScanReport` contiene `observedLogicalBytes`, `fileCategories` e `firstLevelFolders`. Si aggregano **tutti i file regolari che hanno metadati accessibili**, non soltanto i candidati alle soglie di dimensione/età. Le viste possono mostrare i gruppi senza accedere nuovamente ai file.

Non vengono letti contenuti, effettuati hash o trasferiti inventari. I byte aggregati sono **dimensioni logiche**: i file hard-link possono essere doppiamente contati, i cloni APFS condividono blocchi e file sparse hanno dimensione apparente maggiore dello spazio allocato. Il modello non dichiara spazio fisico recuperabile.
