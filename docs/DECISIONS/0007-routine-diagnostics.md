# ADR-0007 — Primo modulo read-only di manutenzione ordinaria

**Stato:** accettata per alpha.10.  
**Data:** 2026-11-05.

## Decisione

- Due sezioni distinte: Manutenzione (log/rapporti utente e build Xcode) e Avvii automatici (file utente `LaunchAgents` e link alle Impostazioni).
- Accesso solo dopo file importer e controllo della corrispondenza esatta con tre cartelle della home dell'account.
- Nessuna lettura di contenuti: per log soltanto suffissi approvati e anzianità di almeno 30 giorni; per Xcode solo totali per cartella di progetto; per startup solo nomi dei plist. Le informazioni sullo stato effettivo degli agenti rimangono sconosciute.
- Escludere symlink, file hard link, device diversi, oggetti non dell'utente e nomi protetti; porre limiti su elementi visitati, risultati e profondità. L'accesso security-scoped dura la sola scansione.
- Nessuna disabilitazione, cancellazione o mutazione: tutta l'area resta `protected`. Le stime non indicano spazio recuperabile.

## Alternative escluse

Pulizia indiscriminata di `/Library`, `/private/var/log`, log unificati macOS o cache di tutte le app; uso di `sudo`, `launchctl` per mutazioni, plist editing e disinstallazione automatica di servizi.

## Rischi e lavori aperti

Revisione delle regole per-app, test manuali di permessi/TOCTOU/file in uso, catalogo degli avvii moderni attraverso API consentite e reale identificazione dei processi attivi. Non utilizzare questa fase read-only come prova di ammissibilità al Cestino.
