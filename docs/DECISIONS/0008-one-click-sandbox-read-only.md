# ADR-0008 — Controlli diretti con App Sandbox e percorsi read-only

**Stato:** accettata sperimentalmente per alpha.11; verifica manuale runtime ancora necessaria.  
**Data:** 2026-11-05.

## Problema

I tre controlli della manutenzione conoscono già la cartella bersaglio. Chiederne la selezione manuale ad ogni avvio complica inutilmente l'interfaccia.

## Decisione

- Un clic per avviare l'analisi, usando esclusivamente `~/Library/Logs`, `~/Library/Developer/Xcode/DerivedData` e `~/Library/LaunchAgents`. Nessuna scansione automatica all'apertura della vista.
- Mantenere App Sandbox e aggiungere `com.apple.security.temporary-exception.files.home-relative-path.read-only` per **sole tre directory** con slash finali. Apple documenta tale entitlement come eccezione temporanea: [riferimento Apple](https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/EntitlementKeyReference/Chapters/AppSandboxTemporaryExceptionEntitlements.html).
- Non introdurre `com.apple.security.app-sandbox=false`, Full Disk Access, helper privilegiati, autorizzazioni di scrittura o bypass.
- Continuare a validare la allowlist nel motore, senza fidarsi del solo entitlement; segnalare esplicitamente directory inesistenti o inaccessibili.
- La scansione generalista resta basata su cartelle scelte dall'utente.

## Vincoli e verifiche

Questa eccezione è sperimentale e può non essere idonea per distribuzione nello Store senza un'ulteriore motivazione/revisione Apple. TCC e permessi UNIX rimangono validi. Verificare il funzionamento reale della build firmata su Mac e il contenuto della firma prima di dichiarare l'esperienza completamente validata. Nessuna di queste scelte abilita la cancellazione.
