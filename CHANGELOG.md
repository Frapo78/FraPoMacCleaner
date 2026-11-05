# Changelog

Le versioni seguono [Semantic Versioning](https://semver.org/lang/it/).

## v0.1.0-alpha.1 (2026-11-05) — scheletro compilabile, test preliminari

Release sperimentale per il solo sviluppo: interfaccia navigabile, provider disco di sola lettura, struttura modulare e CI ARM64. La pulizia dei file è disabilitata. Il pacchetto prerelease non è firmato per distribuzione pubblica né notarizzato.

## Unreleased

### Added
- Scheletro macOS arm64 SwiftUI con navigazione e provider dei metadati disco.
- Contratti di scansione di sola lettura e policy `fail-closed`.
- Test XCTest iniziali.
- Infrastruttura CI, build ZIP e release semantiche con notarizzazione obbligatoria per release stabili.

### Security
- Nessuna API di cancellazione o manutenzione attiva nel prototipo.

La prima build e i test XCTest risultano superati nel workflow CI del 2026-11-05. La funzionalità di pulizia rimane assente.
