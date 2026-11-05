# Contribuire a FraPoMacCleaner

Grazie per l'interesse. Il progetto è in fase di definizione dei requisiti: le proposte sono più utili se descrivono un **problema reale**, il comportamento desiderato e i rischi.

## Prima di proporre modifiche

1. Leggere `README.md`, `AGENTS.md` e i documenti in `docs/`.
2. Aprire una issue descrivendo scenario, versione macOS, livello di rischio e proposta.
3. Per cambiamenti di architettura o privacy, proporre un ADR prima dell'implementazione.
4. Scrivere documentazione e test insieme al futuro codice.

## Pull request

- Modifiche piccole, motivate, coerenti con gli obiettivi del milestone.
- Descrizione con: **cosa cambia**, **perché**, **rischi**, **come è stato verificato**.
- Se interviene sui file, includere casi negativi: permessi negati, symlink, file scomparsi, cancellazione annullata, volumi scollegati.
- Non caricare log con nomi utente, percorsi personali, file reali o informazioni riservate.
- Nessuna dipendenza nuova senza motivazione e verifica di licenza.

## Convenzioni

- Documentazione in italiano, termini di API in inglese quando utili.
- Swift/SwiftUI per il codice applicativo futuro.
- Nessun codice copiato da applicazioni proprietarie.
- Discussioni rispettose e segnalazioni di problemi di sicurezza con dettagli minimi necessari, evitando dati personali.

## Licenza

Le contribuzioni vengono fornite sotto i termini della GNU GPL v3 presente in `LICENSE`.

