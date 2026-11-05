# ADR-0001 — Applicazione nativa Swift/SwiftUI

**Stato:** proposta accettata a livello progettuale; da validare con il prototipo.  
**Data:** 2026-11-05.

## Contesto

L'app deve leggere metadati del filesystem, mostrare dashboard macOS e gestire operazioni sensibili in modo coerente con API Apple. È prioritario minimizzare dipendenze, consumo energetico, overhead e complessità distributiva.

## Decisione

- Sviluppo **Swift e SwiftUI**, con AppKit dove serve.
- Apple Silicon `arm64` è target prioritario.
- Foundation + framework Apple pubblici per filesystem e integrazione.
- Preferire architettura modulare leggera e separare UI, dominio e I/O.
- Non usare Electron o runtime web per l'interfaccia principale.
- Per il MVP **nessun helper privilegiato**.
- Scegliere versione minima macOS solo dopo confronto API e prova su ambiente reale.

## Conseguenze

**Vantaggi:** integrazione nativa, basso overhead potenziale, strumenti ufficiali, accessibilità.  
**Costi:** conoscenza Swift/macOS, test su versioni OS specifiche, gestione attenta di sandbox/permessi.

## Alternative scartate per il MVP

Electron, Python con GUI, C++/Qt e helper root permanente. Le alternative possono essere rivalutate solo a fronte di requisiti documentati.

## Riferimenti

Vedi `docs/ARCHITECTURE.md` e `docs/REFERENCES.md`.
