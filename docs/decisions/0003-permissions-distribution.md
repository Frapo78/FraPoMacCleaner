# ADR-0003 — Permessi, sandbox e distribuzione: decisione aperta

- **Stato:** proposta / da validare
- **Data:** 2026-11-05

## Contesto

Un'utility filesystem richiede accessi non sempre disponibili in sandbox. La distribuzione fuori dal Mac App Store permette modelli diversi, ma non disabilita TCC/SIP o il controllo dei permessi.

## Ipotesi

Preparare la distribuzione diretta, firmata e notarizzata, mantenendo la scansione limitata agli scope scelti dall'utente. Verificare con un prototipo se la sandbox e i security-scoped bookmarks soddisfano tutti i casi di uso dell'MVP; non scegliere *a priori* un helper privilegiato.

## Esperimenti obbligatori

1. Accesso a cartella scelta tramite pannello macOS; revoke e riavvio.
2. Ricorsione contenuta, symlink fuori scope e messaggi di permesso negato.
3. Spostamento nel Cestino di un file sintetico in scope.
4. Confronto build sandboxed/non-sandboxed con permessi minimi.
5. Distribuzione di test e impatto di Gatekeeper/firma/notarizzazione.

## Criterio decisionale

Scegliere il modello che permetta il MVP con **minor accesso necessario**, maggiore comprensibilità e test ripetibili. Registrare i risultati qui prima di implementare funzioni avanzate.

## Conseguenze

L'architettura deve astrarre le autorizzazioni e non presumere accesso a tutto il disco. Nessuna funzione MVP deve richiedere root.

