# FraPoMacCleaner

**Pulizia, analisi dello spazio e manutenzione consapevole per macOS su Apple Silicon.**

> **Stato: progettazione (pre-alpha).** Questo repository contiene attualmente documentazione e decisioni architetturali. **Non esiste ancora un'app compilabile**, né sono implementate operazioni di scansione o pulizia.

FraPoMacCleaner è un progetto **open source, nativo e orientato alla sicurezza**, ispirato alla categoria di strumenti a cui appartiene CleanMyMac, ma sviluppato con design, codice e comportamento originali.

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

**Non implementato oggi:** tutto quanto elencato sopra. Le fasi sono obiettivi, non promesse di rilascio.

## Direzione tecnologica

- **Swift + SwiftUI**, app macOS realmente nativa.
- **Apple Silicon (arm64)** come piattaforma prioritaria.
- Foundation, AppKit e framework di sistema **documentati e pubblici**.
- Componenti separati per scansione, valutazione del rischio, autorizzazioni e operazioni sui file.
- Distribuzione fuori dal Mac App Store **da valutare**, con firma e notarizzazione quando si distribuiranno binari.
- Versione minima di macOS **da fissare dopo i primi test reali**.

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

## Stato e prossima milestone

La **prima milestone** è un progetto Xcode minimale con dashboard e una scansione **read-only** limitata a cartelle scelte dall'utente. Soltanto dopo test e revisione del sistema di protezione aggiungeremo il trasferimento nel Cestino.

Non installare script di pulizia di terze parti spacciati per questo progetto: **non sono previste release eseguibili in questa fase**.

## Licenza e marchi

Il repository include la licenza [GNU GPL v3](LICENSE). Il nome CleanMyMac è citato soltanto come riferimento funzionale: non esiste alcuna affiliazione con MacPaw o Apple. «FraPoMacCleaner» è il nome di lavoro del progetto.

## English summary

FraPoMacCleaner is a **planned, open-source, native Apple Silicon macOS cleaning and disk-analysis utility**. The project is documentation-only for now. Safety, explicit consent, clear previews, on-device processing, and recoverable operations take priority over aggressive «optimization».
