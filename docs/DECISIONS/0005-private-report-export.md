# ADR-0005 — Export di riepilogo aggregato con whitelist

**Stato:** accettata per la fase read-only.  
**Data:** 2026-11-05.

## Contesto

L'inventario di una cartella contiene informazioni sensibili: percorsi con nomi utente, titoli di file e dettagli applicativi. Un comando di esportazione indiscriminata potrebbe rivelarle anche senza inviare dati via rete.

## Decisione

- Esportare solo su azione esplicita e tramite `NSSavePanel`.
- Includere esclusivamente una whitelist fissa di conteggi, dimensioni logiche aggregate, categorie di estensioni predefinite ed esclusioni/errori aggregati.
- Non serializzare modelli `ScanFinding`, URL, etichette delle sottocartelle, date individuali o dettagli di errori.
- Non scrivere archivi temporanei, cronologie o report automatici.
- I dati mostrano *dimensioni logiche osservate*, non byte effettivamente recuperabili.
- Ogni futura estensione di schema richiede test privacy con input ostili e revisione.

## Conseguenze

Meno dettagli nel JSON, ma un formato ispezionabile con rischio ridotto di perdita accidentale di informazioni. I conteggi possono comunque essere sensibili: il documento resta sotto la responsabilità dell'utente.
