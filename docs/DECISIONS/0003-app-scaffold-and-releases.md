# ADR-0003 — Infrastruttura SwiftUI, build e release ZIP

**Stato:** adottata come base tecnica, da validare con la prima build CI.  
**Data:** 2026-11-05.

## Decisione

Un unico progetto `FraPoMacCleaner.xcodeproj`, con target applicazione macOS e test XCTest. Nessuna dipendenza di build esterna. Struttura:

- `App/`: entrypoint, composizione dipendenze e navigazione.
- `Features/`: UI e view model suddivisi per funzione.
- `Domain/`: modelli e politiche indipendenti dai servizi.
- `Services/`: protocolli e adapter delle API Apple.
- `Resources/`: risorse grafiche/localizzazione future.
- `Configuration/`: configurazioni ed entitlements.
- `FraPoMacCleanerTests/`: test non distruttivi.

`UnavailableScanEngine` è deliberatamente inerte; `ConservativeRiskPolicy` classifica ogni elemento come protetto. Nessun componente che elimina file.

## Build e distribuzione

GitHub Actions sul runner `macos-15` ARM64 per compilazione e test. Ogni push riuscito produce artefatti ZIP di sviluppo; tag SemVer generano GitHub Releases. Le release stabili richiedono firma **Developer ID Application**, notarizzazione `notarytool`, stapling e checksum. Le prerelease ZIP non firmate sono solo per test.

## Perché

Bassa complessità iniziale, responsabilità chiare, separazione della superficie distruttiva, sviluppo rapido e distribuzione riproducibile. Non introdurre pacchetti Swift, helper privilegiati o runtime aggiuntivi finché non sono necessari.

## Debiti espliciti

Verifica Xcode effettiva, valutazione sandbox, test APFS/permessi, applicazione dell'identità del file e primo scenario scanner read-only. Il progetto iniziale non va presentato come completa utility di manutenzione.
