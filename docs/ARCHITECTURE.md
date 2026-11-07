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

## Avanzamento e diagnostica strutturata (alpha.7)

`ScanEngine` accetta un callback `@Sendable` di `ScanProgress` per emettere soltanto snapshot dei contatori; l'overload preesistente `scan(in:)` rimane disponibile mediante extension. `ReadOnlyScanEngine` pubblica l'istantanea iniziale, una ogni 128 voci visitate e quella finale. Questo modello evita una percentuale non verificabile, dal momento che il numero totale degli elementi non è noto.

`ScanSessionModel` trasferisce gli aggiornamenti sul MainActor e li scarta se appartengono a una scansione annullata o superata da una nuova sessione. Il report riassume esclusioni e problemi con un enum tipizzato e conteggi limitati: **non memorizza percorsi dei file esclusi, errori completi o contenuti**. L'enumerazione rimane di sola lettura e continua a ignorare symlink, pacchetti e aree sensibili. I messaggi del report non autorizzano la cancellazione.

## Esploratore e export opt-in (alpha.8)

`ScanFinding` conserva motivazioni tipizzate (`largeFile`, `oldFile`) oltre alla spiegazione leggibile. `ScanResultExplorer` è una trasformazione pura in memoria: cerca e ordina soltanto l'elenco limitato dei candidati; **non apre file** né richiede nuovi permessi. Il modello di rischio `ConservativeRiskPolicy` continua a classificare tutti i candidati come `protected`, indipendentemente dai filtri.

`ScanSummaryExporter.encode` produce JSON con una **schema whitelist esplicita** (versione, conteggi, categorie note, errori/esclusioni aggregate). Non serializza `ScanFinding`, URL, timestamp, nomi di sottocartella o dettagli errori. La vista mostra un `NSSavePanel` per ogni esportazione: nessun file è scritto senza scelta del percorso e nessun dato viene trasmesso. La diagnostica aggregata resta indicativa, non equivale a spazio recuperabile.

Per mantenere l'elenco accessibile, i riepiloghi sono inizialmente chiusi e, se aperti, scorrono in un'area a dimensione limitata. Restano necessari test manuali su finestre ridotte, App Sandbox e accessibilità.

## Contabilità inode, sicurezza volumi e soglie (alpha.9)

Il motore conserva soltanto metadati ottenuti da URLResourceValues e `Darwin.lstat`; non apre mai il contenuto. La coppia **device/inode** identifica un oggetto del filesystem *durante la scansione corrente*. I totali separano:

- `observedLogicalBytes`: somma logica di tutti i percorsi esaminati (può ripetere hard link).
- `observedUniqueLogicalBytes`: somma logica di una sola voce per coppia device/inode osservata.
- `observedAllocatedBytes`: somma dei blocchi `st_blocks × 512` per inode osservato una sola volta. **Non equivale a spazio fisico esclusivo né a spazio recuperabile** per cloni APFS, snapshot, compressione, sparse file, dati purgeable e file esclusi.
- `hardLinkedEntryCount`: percorsi con `st_nlink > 1`; `repeatedHardLinkEntryCount`: percorsi dello stesso inode già osservato in questa scansione.

L'insieme delle identità è limitato dai **100.000 elementi massimi** già previsti dalla scansione. I device diversi da quello della radice selezionata sono saltati senza attraversarli. `lstat` su ogni directory prima dell'enumerazione limita l'attraversamento di symlink sostituiti; **non è una difesa completa da race TOCTOU**, né identifica mount alias sullo stesso device. Ogni futura mutazione richiederà un controllo file-descriptor-based separato.

`ScanScope` registra le soglie facoltative per la singola esecuzione; `ScanReport` conserva le soglie realmente applicate. La UI offre preset da 50 MiB a 1 GiB e 30–365 giorni. L'assenza di valori usa il default del motore, mentre zero o valori negativi sono respinti. Non vengono introdotti privilegi o accessi in background.

## Modulo Manutenzione P0-A (alpha.10)

`RoutineInspectionEngine` è un enumeratore nativo dedicato e **separato dal motore generalista**. Per ciascuna area ammette esclusivamente la cartella precisa sotto la home dell'account corrente: `Library/Logs`, `Library/Developer/Xcode/DerivedData`, `Library/LaunchAgents`. Una selezione di directory differente è respinta, non interpretata come nuova radice generica. Da **alpha.11** la UI passa direttamente il percorso predefinito al motore: non c'è più un file importer per le tre aree. La allowlist continua a bloccare ogni altra posizione.

Per evitare di risolvere accidentalmente la home del container App Sandbox, la posizione dell'account è ricavata tramite `getpwuid(getuid())`, e la firma App Sandbox include eccezioni Apple di **sola lettura e ambito preciso** per quelle tre cartelle. POSIX/TCC e gli altri controlli macOS rimangono comunque applicabili. `lstat` consente di escludere symlink, hard link e device diversi; i dati sono metadati, senza lettura dei log o del contenuto dei plist. Come per lo scanner generale, il controllo non è una soluzione contro tutte le race TOCTOU. Le ispezioni hanno limite 20k elementi, 200 risultati, profondità limitata e supporto all'annullamento.

La UI `RoutineMaintenanceView` è riusata in due sezioni, mentre `RoutineInspectionModel` esegue l'enumerazione in un task `detached` a priorità ridotta, mantenendo lo stato aggiornato sul `MainActor`. Le sessioni annullate non possono sostituire il risultato della nuova sessione. Il modulo Avvii legge **solo i nomi** dei plist in `LaunchAgents`; gli elementi moderni non rappresentati da file sono consultabili nelle Impostazioni con `SMAppService.openSystemSettingsLoginItems()`.

Non esistono componenti di pulizia per queste aree; ogni voce rimane `protected`. Il rapporto conserva URL solo in memoria per la navigazione manuale nel Finder. La nuova funzione non cambia le condizioni di firma o i permessi dell'app.

## Accesso diretto alle categorie previste (alpha.11)

`RoutineMaintenanceView` non mostra più un selettore di directory. I pulsanti invocano `RoutineInspectionModel.inspect(area:)`, che risolve la **sola** destinazione predefinita di `RoutineInspectionEngine.allowedRoots`. Le API di enumerazione verificano nuovamente l'esatta allowlist e l'identità della directory. Non esiste un accesso a percorsi arbitrari in questo flusso.

Il bundle resta sandboxed e firma un entitlement `com.apple.security.temporary-exception.files.home-relative-path.read-only` con tre directory: `/Library/Logs/`, `/Library/Developer/Xcode/DerivedData/`, `/Library/LaunchAgents/`, relative alla home dell'account. È una **eccezione temporanea documentata Apple** per il caso di test, non un'abilitazione generica alla lettura dell'intero disco. Può incidere sull'idoneità a distribuzione App Store: riesaminare la scelta prima di release stabili. La conferma runtime è da eseguire su Mac firmato.

Non serve `startAccessingSecurityScopedResource()` per i normali URL costruiti dai percorsi fissi; il motore gestisce errori di autorizzazione e di directory inesistente. I percorsi restano invarianti e il nuovo comportamento **non modifica** la schermata generalista Scansione, che continua a usare cartelle selezionate.

## Valutazione informativa dei residui (alpha.12)

`RoutineReviewPolicy` separa la diagnosi dal futuro coordinatore di pulizia. I soli valori sono `protected` e `needsReview`, entrambi **privi di autorizzazione alla rimozione** (`RoutineEntry.canRemove == false`).

La policy segnala solo rapporti diagnostici `.ips/.crash/.hang/.spin/.diag`, log ruotati compressi (`.log.N.gz`, N=0..3) o gruppi di build Xcode la cui **ultima data osservata** abbia almeno 90 giorni. I log `.log` ordinari, gli agenti `.plist`, i file senza data e tutti i risultati di scansioni parziali o con errori restano `protected`. Il motore non può attestare l'assenza di file in uso: «da approfondire» non significa inattivo, superfluo o recuperabile.

Il campo `origin` rappresenta la sottocartella di primo livello (indicazione non verificata), senza leggere l'identità dell'app o i contenuti. `st_blocks * 512` fornisce i blocchi allocati osservati, con somma saturante; con APFS, cloni e snapshot possono condividere spazio. `observedAllocatedBytes` non è una stima di spazio liberabile. I campi restano in memoria e non sono trasmessi.

## Confronto tra ispezioni in memoria (alpha.13)

`RoutineMetadataSignature` contiene metadati POSIX read-only (percorso relativo, device, inode, owner, tipo, link count, dimensione, mtime/ctime in nanosecondi) per gli elementi che il motore riesce a visitare. Ogni `RoutineEntry` contiene un insieme di firme: una firma per log o plist, più firme per ogni progetto DerivedData, incluse le directory attraversate. Il limite dell'enumeratore rimane **20.000 elementi visitati** e 200 voci mostrate.

`RoutineChangeInspector.compare` è una trasformazione pura in memoria che richiede due report dello stesso ambito, senza errori e senza limiti raggiunti. Non riapre i file né legge contenuti. `RoutineInspectionModel` mantiene solo il report precedente per la durata del ricontrollo e non lo salva sul disco. Le differenze derivano dalle firme osservate; il fatto che nessuna firma sia cambiata **non prova assenza di file aperti o inutilizzo**. Ogni futura pulizia dovrà ricontrollare i file in modo transazionale e non può riutilizzare questa classificazione come autorizzazione.

Per le build Xcode la presenza di qualunque figlio escluso o non verificabile rende il **gruppo protetto**, anche se i file visibili risultano vecchi. La protezione evita che un sottoinsieme parziale sembri un progetto completo e inattivo. Il controllo di utilizzo reale da parte dei processi rimane un requisito indipendente.
