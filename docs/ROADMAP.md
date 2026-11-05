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
- [x] Ripartizione delle dimensioni logiche per tipo e sottocartella (XCTest CI); senza stime di spazio recuperabile.
- [x] Avanzamento non percentuale con contatori e diagnostica di esclusioni/errori per categoria (XCTest CI).
- [x] Esploratore con ricerca e filtri per motivo/tipo, ordinamento multiplo e riepilogo espandibile (XCTest + CI).
- [x] Esportazione manuale JSON di soli aggregati, priva di inventario, nomi e percorsi (test di riservatezza).
- [x] Soglie di scansione modificabili per ogni esecuzione, con valori applicati conservati nel rapporto e nell'export.
- [x] Conteggio inode unici/hard link e blocchi allocati osservati, con avviso esplicito sull'incertezza APFS.
- [x] Esclusione read-only dei percorsi su device diverso, con test della regola di confine.
- [ ] Risultati con rischio, motivazione, esclusioni ed errori (in alpha.8 motivi tipizzati, avviso di protezione e diagnostica; restano da progettare una classificazione differenziata e test di permessi).
- [x] Test automatici su filesystem sintetico e prova manuale iniziale sul Mac (file grande e file datato).

**Stato di v0.1.0-alpha.9:** 23 test XCTest superati, scanner di soli metadati attivo. Verificata anche su Mac la prima scansione di una cartella di fixture con due candidati (314,6 MB e file datato al 2020), entrambi elencati nella schermata Risultati. Restano **aperti** test manuali su soglie, hard link, App Sandbox/revoca e prestazioni 10k–100k elementi. La separazione di inode è implementata, ma stime affidabili di spazio recuperabile APFS/cloni/snapshot e classificazione del rischio differenziata richiedono sviluppo ulteriore; il gate della Fase 1 non è ancora chiuso.

**Exit gate:** nessuna API di mutazione nel percorso di scansione; test dei casi avversi e prestazioni accettabili.

## Priorità P0 — Pulizia ordinaria sicura e avvii indesiderati

**Nuova priorità di prodotto, da sviluppare prima di duplicati, monitor e manutenzione avanzata.** Obiettivo: recuperare spazio da residui *effettivamente verificati* dell'utente e identificare avvii in background non desiderati. Nessuna promessa generica di accelerazione; eliminare log non riduce automaticamente i processi attivi. **Stato: pianificata, non implementata.**

### P0-A — Diagnosi read-only (prossima milestone)

- [ ] Inventario mirato, con regole a whitelist versionate e testate, di **vecchi log e rapporti diagnostici utente** (es. sotto `~/Library/Logs` e `~/Library/Logs/DiagnosticReports` quando effettivamente accessibili); classificazione per app, data, dimensione, motivo e rischio, senza leggere i contenuti.
- [ ] Rilevamento di **cache utente non attive e residui temporanei** soltanto per directory e formati esplicitamente approvati per caso d'uso; niente ricerca globale per estensioni o cancellazione indiscriminata di `~/Library/Caches`.
- [ ] Vista separata **Avvio e attività in background**, in sola lettura: mostrare elementi di login, agenti utente e loro origine quando identificabile; distinguere stato verificato da stato sconosciuto, senza dichiarare che ogni agente sia superfluo.
- [ ] Anteprima per ciascuna categoria con titolarità, ragioni della segnalazione, esclusioni, dimensioni logiche/allocate *osservate* e avviso su incertezza APFS; nessun file preselezionato.

### P0-B — Pulizia controllata (primo incremento della Fase 2, solo dopo gate di sicurezza)

- [ ] Abilitare **soltanto** categorie allowlist di residui utente dimostrati non necessari, con finestra di inattività e controlli di ownership, permessi, identità e confinamento dell'ambito. I casi ambigui o non verificabili restano `protected`.
- [ ] Mostrare piano dettagliato per singolo elemento, consenso esplicito e nuova validazione immediatamente prima di un eventuale **spostamento nel Cestino**; nessuna eliminazione permanente, automatica o pianificata.
- [ ] Per elementi che avviano processi: offrire spiegazione e collegamento alle **Impostazioni di sistema → Elementi login ed estensioni** o alle API Apple supportate, **senza** eliminare `.plist`, terminare processi o alterare servizi di terze parti automaticamente.
- [ ] Riportare esiti per-file e byte realmente osservabili *dopo* l'azione, senza definire il totale selezionato come spazio recuperato; consentire annullamento e gestione sicura di errori parziali.

**Esclusioni inderogabili per il primo rilascio:** `/System`, `/Library`, `/private/var/log`, log unificati gestiti da macOS, `/var/db`, snapshot, LaunchDaemons di sistema, dati applicativi attivi, backup, credenziali, database, browser, contenuti cloud, applicazioni installate. Non utilizzare `sudo`, privilegi elevati, bypass di SIP/TCC o comandi di svuotamento forzato. Se una categoria richiede questi interventi, resta **solo informativa o fuori ambito**.

**Gate di accettazione:** test su fixture sintetiche per allowlist/denylist, log attivi e in rotazione, symlink/hard link, file cambiati nel frattempo, permessi revocati, elementi di altre app, errori del Cestino, annullamento, volumi diversi e stime APFS; prova manuale su Mac Apple Silicon e revisione della sicurezza. La modalità di diagnosi può essere rilasciata prima della pulizia; nessuna azione distruttiva senza superare il gate.

## Fase 2 — v0.1b, pulizia controllata

**Primo caso d'uso:** esclusivamente i residui utente approvati in P0-B, non una pulizia generale del sistema.

- [ ] Piano d'azione con preview e consenso.
- [ ] Revalidazione identità/ambito/permessi prima dell'esecuzione.
- [ ] Spostamento nel Cestino per file ammissibili.
- [ ] Log locale essenziale con risultati parziali ed errori.
- [ ] Test di sicurezza e crash/cancel/revoke.

**Exit gate:** nessuna cancellazione definitiva nel flusso standard; esiti reali verificati su fixture.

## Fase 3 — v0.2, analisi avanzata

- [ ] Raggruppamento duplicati affidabile con SHA-256 e protezione hard link.
- [ ] Gestione accurata stime APFS e dati non conteggiabili (alpha.9 misura inode e blocchi allocati; cloni/snapshot, byte esclusivi e spazio recuperabile restano sconosciuti).
- [ ] Ampliare i cataloghi di log/cache **utente** oltre l'allowlist prioritaria P0, solo con nuove regole revisionate per singolo caso d'uso.
- [ ] Miglioramento filtri, export e prestazioni.

## Fase 4 — v0.3, manutenzione informativa

- [ ] Inventario app/residui con spiegazione delle associazioni.
- [ ] Estendere l'inventario prioritario P0-A di login item e agenti utente con diagnostica più completa, sempre attraverso API e impostazioni supportate.
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
