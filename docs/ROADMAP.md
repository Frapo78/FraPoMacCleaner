# Roadmap — FraPoMacCleaner

**Bozza orientativa.** Le versioni sono traguardi logici, non date promesse. Nessun punto è da considerarsi completato prima che esistano build e test verificati.

## Fase 0 — Fondamenta di progetto (documentazione)

- [x] Visione, principi e limiti.
- [x] Architettura iniziale, sicurezza e privacy.
- [x] Specifiche MVP, UX e criteri di test.
- [ ] Confermare target macOS, toolchain Xcode e scelte di signing/sandbox.
- [ ] Rivedere le regole per accessi e percorsi con test sul Mac Apple Silicon.

## Fase 1 — v0.1a, solo lettura

- [x] Progetto Xcode SwiftUI arm64 e struttura di navigazione, verificati in CI.
- [ ] Selezione cartella con permessi coerenti.
- [x] Provider di lettura dei metadati disco e dashboard iniziale, verificati in CI.
- [x] Enumerazione cancellabile, senza seguire symlink (test su fixture CI).
- [x] Analisi metadati file grandi/vecchi (test su fixture CI).
- [ ] Risultati con rischio, motivazione, esclusioni ed errori.
- [x] Test automatici su filesystem sintetico e prova manuale iniziale sul Mac (file grande e file datato).

**Stato di v0.1.0-alpha.5:** 9 test XCTest superati, scanner di soli metadati attivo. Verificata anche su Mac la prima scansione di una cartella di fixture con due candidati (314,6 MB e file datato al 2020), entrambi elencati nella schermata Risultati. Restano **aperti** i test di autorizzazioni/revoca App Sandbox, le prove di prestazione su alberi grandi e un report di errori/rischi più dettagliato; il gate della Fase 1 non è ancora chiuso.

**Exit gate:** nessuna API di mutazione nel percorso di scansione; test dei casi avversi e prestazioni accettabili.

## Fase 2 — v0.1b, pulizia controllata

- [ ] Piano d'azione con preview e consenso.
- [ ] Revalidazione identità/ambito/permessi prima dell'esecuzione.
- [ ] Spostamento nel Cestino per file ammissibili.
- [ ] Log locale essenziale con risultati parziali ed errori.
- [ ] Test di sicurezza e crash/cancel/revoke.

**Exit gate:** nessuna cancellazione definitiva nel flusso standard; esiti reali verificati su fixture.

## Fase 3 — v0.2, analisi avanzata

- [ ] Raggruppamento duplicati affidabile con SHA-256 e protezione hard link.
- [ ] Gestione accurata stime APFS e dati non conteggiabili.
- [ ] Cache/log **utente** attraverso regole revisionate per caso d'uso.
- [ ] Miglioramento filtri, export e prestazioni.

## Fase 4 — v0.3, manutenzione informativa

- [ ] Inventario app/residui con spiegazione delle associazioni.
- [ ] Login item: visione e collegamento alle impostazioni (per terze parti).
- [ ] Monitor CPU/RAM/disco con impatto misurato.
- [ ] Accessibility audit e localizzazione.

## Automazione build e release

- [x] Definizione di CI per build/test ARM64 e artefatti ZIP di sviluppo.
- [x] Workflow di GitHub Release su tag semantico.
- [x] Prima esecuzione CI verde e test verificati su macOS ARM64 (GitHub Actions).
- [ ] Credenziali Apple Developer ID + notarizzazione configurate per versioni stabili.
- [x] Prima **prerelease compilata e testata** v0.1.0-alpha.2 con ZIP scaricabile.
- [ ] Prima release **stabile**, completa delle funzioni previste per il rilascio e notarizzata.

## Fase 5 — prima release pubblica

- [ ] Revisione sicurezza indipendente e privacy.
- [ ] Build arm64 riproducibile (nei limiti di signing Apple).
- [ ] Firma Developer ID, notarizzazione, verifica Gatekeeper.
- [ ] Release note, changelog, installazione e disinstallazione documentate.
- [ ] Pacchetto scaricabile con checksum.

## Non-obiettivi fino a rivalutazione formale

«RAM boost», pulizia automatica integrale, cancellazione di cache di sistema, servizi root generici e scansioni in background senza consenso.
