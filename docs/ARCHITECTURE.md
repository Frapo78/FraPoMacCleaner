# Architettura iniziale (proposta)

## Scelte di base

App desktop **SwiftUI**, nativa ARM64, Swift 6, organizzazione pragmatica **MVVM + Domain Services + Infrastructure Adapters**. Non usare Electron, server locali o servizi remoti per il nucleo dell'app.

**Stato:** architettura da implementare; nessuna cartella sorgente descritta sotto esiste ancora.

## Schema logico

```text
SwiftUI Views / Accessibility
          |
      ViewModels
          |
   Application Use Cases
   Scan | Review | Cleanup | Report
          |
  Domain Models & Policies
          |
  Protocol-based Adapters
  FileSystem | Storage | Metrics
          |
  macOS APIs (Foundation / Darwin)
```

La UI non chiama direttamente `removeItem`, `trashItem` o comandi di shell. La sola componente autorizzata a modificare file è l'adapter di pulizia, invocato da un use case che applica i controlli.

## Organizzazione futura del progetto

```text
FraPoMacCleaner/
  App/                         # Entrypoint, navigazione e dependency wiring
  Presentation/
    Dashboard/
    Scan/
    Review/
    History/
    Settings/
  Domain/
    Models/                    # ScanItem, ScanSession, SafetyAssessment, CleanupResult
    Policies/                  # Scope, Exclusions, Risk, Eligibility
    Protocols/                 # FileInventory, TrashService, MetricsProvider
  Application/
    ScanUseCase/
    ReviewUseCase/
    CleanupUseCase/
  Infrastructure/
    FileSystem/
    Persistence/
    SystemMetrics/
  Resources/                   # Asset originali, stringhe, localizzazioni
FraPoMacCleanerTests/
  Unit/
  Integration/
  Fixtures/
docs/
```

Directory rappresentative: il layout potrà essere semplificato dopo il primo prototipo, purché rimangano separati scanner e mutazioni.

## Entità di dominio proposte

- **ScanScope:** radice autorizzata, volume, origine del permesso, esclusioni applicabili.
- **ScanSession:** identificatore locale, orari, configurazione, statistiche ed errori.
- **ScanItem:** identificatore opaco, URL, metadati necessari, dimensione logica, stato della risorsa, motivazione del suggerimento.
- **SafetyAssessment:** stato `protected / review / eligible`, spiegazione e versione della policy.
- **CleanupPlan:** insieme esplicito di elementi selezionati, snapshot del controllo preliminare, stima del totale.
- **CleanupResult:** esito per file (cestinato, saltato, cambiato, accesso negato, fallito), destinazione del Cestino se disponibile.

Non archiviare hash o contenuto dei file senza necessità funzionale esplicita.

## Pipeline

1. **Authorization:** acquisire solo scope e permessi necessari.
2. **Inventory (read-only):** enumerare senza seguire link fuori scope, con cancellazione cooperativa e memoria limitata.
3. **Classify:** policy conservative, esclusioni ed etichette di rischio.
4. **Review:** filtrare/ordinare e selezionare; non mutare il filesystem.
5. **Preflight:** rivalidare file, identità, path canonico, eventuale mount, stato corrente e autorizzazione.
6. **Execute:** spostare un elemento alla volta nel Cestino mediante API appropriate.
7. **Audit:** riportare ogni esito, compresi i fallimenti parziali, senza asserire recupero immediato dello spazio.

## Concorrenza e prestazioni

- Structured concurrency di Swift con task cancellabili; UI sempre sul main actor, I/O fuori.
- Scansione streaming e limiti configurabili a parallelismo, memoria e accessi al disco.
- Hash per duplicati solo in P1 e in modalità progressiva; prima filtrare con dimensioni e caratteristiche.
- Nessuna scansione continua in background nell'MVP.

## Error handling

I problemi su un file non devono abortire l'intera sessione. Distinguere *permission denied*, file scomparso, file modificato, risorsa cloud non locale, volume disconnesso e errore I/O. I candidati sconosciuti si **saltano**.

## Persistenza e privacy

Solo impostazioni e riepiloghi essenziali locali. Non salvare contenuti, percorsi personali o inventari completi per impostazione predefinita; eventuali preferenze di accesso persistente richiederanno bookmarks e revisione della sicurezza.

## Decisioni ancora aperte

- App Sandbox abilitata o meno nella prima distribuzione esterna: valutare con un prototipo di permessi.
- Scelta minima effettiva macOS/Xcode; da validare compilando su Apple Silicon.
- Trattamento delle cartelle package e dei file APFS clone per stime più fedeli.
- Localizzazione e formato esportazione report.

Consultare `docs/decisions/` per le scelte registrate.

