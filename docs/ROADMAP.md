# Roadmap — FraPoMacCleaner

**Bozza orientativa.** Le versioni sono traguardi logici, non date promesse. Nessun punto è da considerarsi completato prima che esistano build e test verificati.

## Fase 0 — Fondamenta di progetto (documentazione)

- [x] Visione, principi e limiti.
- [x] Architettura iniziale, sicurezza e privacy.
- [x] Specifiche MVP, UX e criteri di test.
- [ ] Confermare target macOS, toolchain Xcode e scelte di signing/sandbox.
- [ ] Rivedere le regole per accessi e percorsi con test sul Mac Apple Silicon.

## Fase 1 — v0.1a, solo lettura

- [ ] Progetto Xcode SwiftUI arm64, avvio e navigazione.
- [ ] Selezione cartella con permessi coerenti.
- [ ] Dashboard capacità disco attendibile.
- [ ] Enumerazione cancellabile, senza seguire symlink.
- [ ] Analisi metadati file grandi/vecchi.
- [ ] Risultati con rischio, motivazione, esclusioni ed errori.
- [ ] Test automatici su filesystem sintetico e verifica manuale sul Mac.

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

## Fase 5 — prima release pubblica

- [ ] Revisione sicurezza indipendente e privacy.
- [ ] Build arm64 riproducibile (nei limiti di signing Apple).
- [ ] Firma Developer ID, notarizzazione, verifica Gatekeeper.
- [ ] Release note, changelog, installazione e disinstallazione documentate.
- [ ] Pacchetto scaricabile con checksum.

## Non-obiettivi fino a rivalutazione formale

«RAM boost», pulizia automatica integrale, cancellazione di cache di sistema, servizi root generici e scansioni in background senza consenso.
