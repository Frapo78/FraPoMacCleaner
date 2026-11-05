# FraPoMacCleaner

**Pulizia, analisi dello spazio e manutenzione consapevole per macOS su Apple Silicon.**

> **Stato: pre-alpha, scanner di metadati in validazione.** Progetto Xcode nativo SwiftUI con dashboard disco, selezione cartella e scanner ricorsivo read-only. Il nuovo codice e i test sono stati aggiunti; la relativa CI e la prova manuale sono ancora da confermare. Non esistono operazioni di pulizia o cancellazione.

FraPoMacCleaner è un progetto **open source, nativo e orientato alla sicurezza**, sviluppato con codice e interfaccia originali.

## Obiettivi

- Aiutare a **capire** cosa occupa spazio sul Mac e perché.
- Individuare **file grandi, vecchi, duplicati**, cache e log dell'utente.
- Consentire **azioni selettive e spiegate**, preferibilmente tramite Cestino.
- Fornire informazioni verificabili su disco, CPU, memoria e processi, senza inventare un indice di «salute» del Mac.
- Restare **leggero, trasparente, locale**, senza pubblicità o abbonamenti obbligatori.

## Principi non negoziabili

1. **Analizza prima, modifica solo su richiesta:** la scansione è di sola lettura.
2. **Nessuna cancellazione silenziosa:** anteprima, percorso, dimensione, motivazione e livello di rischio.
3. **Cestino come impostazione predefinita:** nessuna eliminazione definitiva nel percorso ordinario.
4. **Protezione del sistema:** rispetto di SIP, TCC, permessi, FileVault e dei confini delle applicazioni.
5. **Consumo controllato:** scansioni cancellabili, limite di concorrenza e niente monitoraggio continuo invasivo.
6. **Trasparenza:** errori e stime reali, mai «GB recuperati» prima della verifica.
7. **Privacy:** analisi in locale; nessun caricamento del contenuto dei file.

> Cancellare cache o «liberare RAM» non equivale automaticamente ad accelerare macOS. Il progetto privilegia il recupero di spazio **effettivamente sicuro** e la diagnostica utile, non interventi cosmetici.

## Funzioni in programma

| Area | Idea | Fase |
| --- | --- | --- |
| Dashboard | Dischi, spazio disponibile e stato scansioni | MVP |
| Smart Scan | Esplorazione di cartelle autorizzate con risultati classificati | MVP |
| Pulizia controllata | Anteprima, selezione e spostamento nel Cestino | MVP |
| File ingombranti | Ordinamento per dimensione, età e percorso | MVP |
| Cache e log utente | Identificazione con regole conservative | v0.2 |
| Duplicati | Confronto a più stadi, verifica crittografica | v0.2 |
| App e residui | Analisi e disinstallazione guidata | v0.3 |
| Elementi di avvio | Visibilità e gestione solo tramite API supportate | v0.3 |
| Monitor | CPU, memoria, processi e attività disco | v0.3 |
| Scansioni pianificate | Solo con consenso e impatto limitato | Futuro |

**Stato attuale:** logo originale 1460×285 e icona 1024×1024 verificati. Il primo scanner esamina metadati di cartelle scelte dall'utente, segnala file grandi o datati, offre annullamento ed esclude symlink e aree sensibili. La nuova implementazione attende la verifica CI; la pulizia rimane completamente assente.

## Direzione tecnologica

- **Swift + SwiftUI**, app macOS realmente nativa.
- **Apple Silicon (arm64)** come piattaforma prioritaria.
- Foundation, AppKit e framework di sistema **documentati e pubblici**.
- Componenti separati per scansione, valutazione del rischio, autorizzazioni e operazioni sui file.
- Distribuzione fuori dal Mac App Store **da valutare**, con firma e notarizzazione quando si distribuiranno binari.
- Versione minima configurata inizialmente: **macOS 14+**, soggetta a revisione dopo test reali.

## Documentazione

- [Visione e limiti](docs/VISION.md)
- [Requisiti e ambito MVP](docs/REQUIREMENTS.md)
- [Architettura iniziale](docs/ARCHITECTURE.md)
- [Politica di sicurezza](docs/SECURITY.md)
- [Esperienza utente](docs/UX.md)
- [Roadmap](docs/ROADMAP.md)
- [Strategia di test](docs/TESTING.md)
- [Privacy](docs/PRIVACY.md)
- [Riferimenti tecnici Apple](docs/REFERENCES.md)
- [Decisioni architetturali](docs/DECISIONS/0001-native-macos.md)
- [Contribuire](CONTRIBUTING.md)
- [Istruzioni per agenti di sviluppo](AGENTS.md)
- [Come compilare](docs/GETTING_STARTED.md)
- [Politica delle release](docs/RELEASING.md)

## Avvio e distribuzione

- [Aprire e compilare in Xcode](docs/GETTING_STARTED.md)
- [Pipeline CI e release ZIP](docs/RELEASING.md)
- [GitHub Actions](.github/workflows/ci.yml)
- **[Prerelease attuale: v0.1.0-alpha.4](https://github.com/Frapo78/FraPoMacCleaner/releases/tag/v0.1.0-alpha.4)** (ZIP ARM64, senza firma/notarizzazione)
- [Tutte le GitHub Releases](https://github.com/Frapo78/FraPoMacCleaner/releases)
- [Identità visiva e icona macOS](docs/BRANDING.md)

Ogni versione significativa dovrà aggiornare `RELEASE_VERSION`, `MARKETING_VERSION` e changelog: GitHub Actions compilerà e creerà automaticamente una **GitHub Release** con tag semantico. I build di sviluppo saranno disponibili come artefatti CI. Le release stabili richiederanno firma Developer ID e notarizzazione; le prerelease sono esplicitamente indicate come test non firmati.

**Prossima milestone:** verificare scanner read-only con XCTest e prove manuali su Mac; completare rapporto degli errori, rischi e verifica permessi. La pulizia rimane fuori scope.

## Licenza

Il repository include la licenza [GNU GPL v3](LICENSE). FraPoMacCleaner è un progetto autonomo e indipendente.

## English summary

FraPoMacCleaner is a **native, open-source Apple Silicon macOS disk-analysis and cleaning utility**. The Xcode/SwiftUI app now includes an initial read-only folder metadata scanner awaiting CI and manual validation; cleanup is not implemented. Safety, explicit consent, clear previews, on-device processing, and recoverable operations take priority over aggressive «optimization».
