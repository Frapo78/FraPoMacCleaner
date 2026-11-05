# ADR-0002 — Scansione di sola lettura e pulizia confermata

**Stato:** accettata come vincolo di sicurezza progettuale.  
**Data:** 2026-11-05.

## Contesto

Le utility di pulizia possono provocare perdita dati, falsi positivi e degrado operativo se eliminano file solo perché sembrano temporanei. La scansione può essere soggetta a symlink, file mutati e autorizzazioni variabili.

## Decisione

- Due fasi non confondibili: **scansione read-only → piano d'azione e consenso**.
- Ogni candidato espone percorso, dimensione, giustificazione, grado di rischio e stima non garantita.
- I percorsi protetti non sono selezionabili.
- La pulizia avviene soltanto dopo **revalidazione** immediata, con gestione prudente delle race.
- Il percorso ordinario usa il **Cestino**, mai `removeItem` o comandi shell distruttivi come soluzione predefinita.
- Gli errori sono per-file e non attivano tentativi con privilegi superiori.
- Nessuna cancellazione silenziosa di cache/app data o suggerimenti basati su sole estensioni.

## Conseguenze

**Pro:** minori sorprese, recuperabilità quando possibile, migliore auditabilità.  
**Contro:** UX meno «un click», stime prudenti, alcune categorie non verranno mai pulite.

## Alternative scartate

Pulizia completa automatica, regole a blacklist senza whitelist di candidati, elevazione amministrativa indiscriminata, forzatura di file in uso.

## Riferimenti

`docs/SECURITY.md`, `docs/TESTING.md` e API `FileManager.trashItem`.
