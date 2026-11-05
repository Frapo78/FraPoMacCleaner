# AGENTS.md — Contratto di lavoro per FraPoMacCleaner

Questo documento orienta contributori umani e agenti software. Si applica a tutto il repository, salvo regole locali più restrittive.

## Fase attuale

**Documentation-first**: prima di aggiungere implementazioni eseguibili, mantenere allineati visione, architettura, sicurezza, roadmap e piano di test. Non presentare mai piani o pseudocodice come funzionalità esistenti.

## Priorità vincolanti

1. Proteggere i dati dell'utente prima di ottimizzare spazio o velocità.
2. Non bypassare SIP, TCC, Gatekeeper, sandbox o altre protezioni di macOS.
3. Non richiedere root, `sudo`, privilegi amministrativi o helper privilegiati per le funzioni MVP.
4. Nessuna pulizia silenziosa, ricorsiva o permanente. Ogni elemento deve essere comprensibile, controllabile e confermato.
5. Usare percorsi selezionati dall'utente e autorizzazioni documentate; non presumere accesso a tutto il filesystem.
6. Non inserire telemetria, account, rete o raccolta di dati personali senza decisione architetturale e consenso.
7. Mantenere identità visiva, implementazione, testi e risorse originali; non importare asset proprietari da concorrenti.
8. Separare analisi in sola lettura e mutazione; le API distruttive non devono essere raggiungibili dalla pipeline di scansione.
9. Prima di ogni azione sui file, rivalidare tipo, permessi, percorso, policy ed eventuale cambiamento d'identità fra scansione e azione.
10. Considerare symlink, hard link, pacchetti, volumi esterni, iCloud, APFS clone/snapshot e app in esecuzione.
11. Ogni PR con operazioni sui file deve includere test di sicurezza/errore e percorso di annullamento ove possibile.
12. Non dichiarare “build riuscita”, test passati o compatibilità verificata senza output effettivo.

## Procedura per le modifiche

- Leggere `README.md`, `docs/ARCHITECTURE.md`, `docs/SAFETY.md` e `docs/ROADMAP.md`.
- Eseguire piccoli cambiamenti verificabili; evitare grandi riscritture estranee al compito.
- Per una scelta tecnica trasversale, aggiungere un ADR in `docs/decisions/` con contesto, opzioni, decisione e conseguenze.
- Aggiornare checklist e test pertinenti nello stesso cambiamento.
- In caso di dubbio sulla sicurezza: **non eliminare**, registrare l'incertezza e richiedere decisione esplicita.
- Conservare la licenza GPL-3.0 e rispettare le licenze delle dipendenze.
- Linguaggio dei documenti: italiano; nomi tecnici/API possono restare in inglese.

## Definition of Done per la futura implementazione

Una funzione può essere chiamata “implementata” solo dopo: compilazione su macOS Apple Silicon, test pertinenti superati, comportamento su errori validato, documentazione aggiornata e nessuna regressione delle regole di sicurezza.

