# FraPoMacCleaner

**Utility open source, nativa per macOS Apple Silicon, per analizzare lo spazio occupato e proporre interventi di pulizia controllati.**

> **Stato: fase di progettazione (documentation-first).** Il repository contiene intenzioni, specifiche e decisioni iniziali. Non esistono ancora un'app compilabile, scanner funzionanti o una release. Le funzionalità descritte sono *pianificate*, non implementate.

## Visione

FraPoMacCleaner vuole essere un'alternativa **trasparente, leggera e rispettosa dei dati** alle utility commerciali di pulizia per macOS. Prende ispirazione dalla *categoria di prodotto* di app come CleanMyMac, senza copiarne marchi, grafica, risorse o codice e senza alcuna affiliazione.

L'obiettivo non è convincere l'utente che ogni cache sia un problema: macOS gestisce autonomamente molte operazioni di manutenzione. Il valore dell'app sta nel **mostrare cosa occupa spazio, spiegare rischi e conseguenze, e lasciare la decisione all'utente**.

## Principi non negoziabili

1. **Scansione prima, azione dopo.** Nessuna modifica durante l'analisi; la pulizia richiede selezione e conferma esplicite.
2. **Sicurezza per impostazione predefinita.** I file incerti non vengono suggeriti per la rimozione automatica; protezioni macOS e permessi sempre rispettati.
3. **Reversibilità quando tecnicamente possibile.** Preferire il Cestino; non svuotarlo mai automaticamente e non promettere un ripristino infallibile.
4. **Privacy locale.** Nessun account, telemetria o upload dei percorsi e dei contenuti dei file nell'MVP.
5. **Onestà sulle prestazioni.** Nessun falso “boost RAM”, nessuna promessa di velocizzazione o di spazio recuperabile garantito.
6. **Design originale e accessibile.** SwiftUI, interazione comprensibile, supporto VoiceOver e modalità chiara/scura.

## Obiettivo MVP (v0.1)

- Dashboard con spazio disco disponibile/occupato, chiarendo la differenza fra quantità logica e spazio effettivamente recuperabile.
- Scansione *read-only* delle cartelle selezionate dall'utente; prima categoria: file grandi e file vecchi.
- Risultati ordinabili con percorso, dimensione, data, categoria e motivazione.
- Esclusioni, anteprima, revisione della selezione e seconda conferma prima della pulizia.
- Spostamento nel Cestino dei soli file idonei, previa riconvalida, con resoconto ed errori per elemento.
- Test automatizzati su cartelle sintetiche, non sui dati personali.

**Non compresi nel primo MVP:** pulizia aggressiva di cache applicative, disinstallazione completa, cancellazione permanente, modifiche ai processi di avvio, interventi con privilegi elevati, pulizia dei file di sistema.

## Tecnologia prevista

| Area | Scelta iniziale |
| --- | --- |
| Piattaforma | macOS su Apple Silicon (ARM64) |
| Interfaccia | SwiftUI nativa |
| Linguaggio | Swift 6 (da validare in compilazione) |
| API | Foundation/FileManager, File System, CryptoKit per funzionalità successive |
| Versione minima macOS | Proposta: macOS 14+; da confermare nei primi test |
| Distribuzione | Inizialmente esterna al Mac App Store; firma/notarizzazione quando pronti |
| Licenza | GNU GPL v3, come da `LICENSE` |

Il modello sandbox/entitlement non è ancora fissato: sarà deciso dopo una prova tecnica dei flussi di accesso ai file e documentato esplicitamente. Distribuire fuori dallo Store **non** consente di aggirare TCC, SIP o permessi.

## Documentazione

- [Visione e confini del prodotto](docs/VISION.md)
- [Catalogo funzionalità e priorità](docs/FEATURES.md)
- [Architettura e moduli](docs/ARCHITECTURE.md)
- [Modello di sicurezza e operazioni sui file](docs/SAFETY.md)
- [Privacy e autorizzazioni](docs/PRIVACY.md)
- [Flussi di esperienza utente](docs/UX.md)
- [Roadmap e criteri di completamento](docs/ROADMAP.md)
- [Strategia di test](docs/TEST_PLAN.md)
- [Decisioni architetturali (ADR)](docs/decisions/0001-native-foundation.md)
- [Riferimenti Apple](docs/REFERENCES.md)
- [Contribuire](CONTRIBUTING.md)
- [Regole per contributori e agenti](AGENTS.md)

## Come contribuire

In questa fase sono graditi feedback sulle specifiche, segnalazioni di rischi di perdita dati, proposte di API Apple e casi di test. Prima del codice, leggere [CONTRIBUTING.md](CONTRIBUTING.md) e [AGENTS.md](AGENTS.md).

## Licenza e attribuzioni

Questo progetto è concesso in licenza GNU GPL v3; consultare [LICENSE](LICENSE). CleanMyMac è un prodotto e marchio di terzi, citato esclusivamente come riferimento generale di categoria. FraPoMacCleaner è un progetto indipendente.

---
*Ultimo aggiornamento della documentazione di progetto: 2026-11-05.*

