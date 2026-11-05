# ADR-0009 — Indizi per la revisione dei residui, senza pulizia

**Stato:** accettata per alpha.12, da rivalutare prima di ogni funzione di rimozione.  
**Data:** 2026-11-05.

## Contesto

Le sole dimensioni e date dei file non stabiliscono se un log, una cartella di build o un agente sia superfluo. La scansione può essere parziale, contenere errori o non riconoscere file attivi. L'utente ha bisogno di una distinzione utile per decidere cosa approfondire, senza rischiare cancellazioni affrettate.

## Decisione

- `RoutineReviewPolicy` ha i livelli `protected` e `needsReview` e **nessuno dei due autorizza la cancellazione**.
- «Da approfondire» richiede almeno 90 giorni dall'ultima modifica osservata, tipologia approvata (rapporto diagnostico o log ruotato compresso) o cartella di compilazione Xcode.
- I log ordinari e tutti gli agenti sono protetti; date sconosciute, errori e scansioni parziali forzano il livello protetto.
- Per ciascuna voce mostrare provenienza indicativa, data, dimensione logica e blocchi allocati osservati da `lstat`. I dati restano informativi, non costituiscono stime del recupero.
- La UI offre un filtro non distruttivo; la funzione Cestino rimane assente.

## Lavoro rimasto

Identificazione affidabile dei file aperti/in uso, del proprietario applicativo, dei rischi per-app, delle race e dei limiti APFS. Nessun segnale di sola anzianità consente di promuovere automaticamente un elemento a «sicuro da rimuovere».
