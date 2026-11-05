# ADR-0001 — App nativa SwiftUI su Apple Silicon

- **Stato:** adottata come direzione progettuale (non ancora verificata con build)
- **Data:** 2026-11-05

## Contesto

La utility lavora intensamente con metadati filesystem e deve mantenere basso overhead, integrazione con macOS e interfaccia accessibile.

## Decisione

Usare **Swift + SwiftUI** in eseguibile nativo **ARM64**, framework Apple dove possibile, con ViewModels, use case e adapter testabili. macOS 14+ è il target minimo *proposto*, soggetto a validazione tecnica.

## Alternative considerate

Electron/web wrapper (più overhead e livello di integrazione), linguaggi interpretati come runtime dell'app (distribuzione più complessa), app cross-platform (nessun vantaggio iniziale).

## Conseguenze

Ottima integrazione e bundle più contenuto atteso; necessità di test reali su più versioni macOS e competenze Swift. Nessuna promessa di performance finché non saranno misurate.

