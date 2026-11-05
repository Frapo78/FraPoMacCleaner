# ADR-0006 — Contabilità read-only per inode e confini del volume

**Stato:** accettata per lo scanner sperimentale, non per operazioni distruttive.  
**Data:** 2026-11-05.

## Contesto

La somma delle dimensioni dei percorsi può sovrastimare l'uso di spazio quando più nomi puntano allo stesso inode. File sparse, snapshot e cloni APFS rendono inaffidabile la deduzione dello spazio fisico recuperabile dalla semplice dimensione logica.

## Decisione

- Leggere solo metadati attraverso le API pubbliche di Foundation e `Darwin.lstat`.
- Contare distintamente percorsi, coppie device/inode e blocchi allocati osservati (`st_blocks × 512`).
- Non serializzare chiavi inode e device nei report esportati.
- Scartare gli elementi su device diverso da quello della cartella selezionata e non seguire symlink.
- Continuare a richiedere selezione e autorizzazione esplicite per ogni scansione.
- Esporre soglie personalizzabili che influiscono solo sui candidati informativi.
- Mantenere ogni finding in stato `protected`, senza consentire pulizia o dichiarare byte recuperabili.

## Rischi residui

La somma dei blocchi può attribuire più volte quelli condivisi da cloni APFS, ignorare i dati legati a snapshot e non rappresentare lo spazio che si libererebbe. Il controllo con `lstat` non neutralizza completamente race TOCTOU; controlli basati su file descriptor e una policy separata saranno indispensabili prima di implementare la pulizia. Il confine `st_dev` non riconosce eventuali mount alias sullo stesso device.

## Test

Hard link reali, file sparse, validazione soglie, limite di enumerazione e cancellazione della scansione: suite XCTest CI, più test manuali su fixture ancora aperti.
