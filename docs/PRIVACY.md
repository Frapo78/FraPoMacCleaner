# Privacy, permessi e distribuzione

## Politica MVP

FraPoMacCleaner deve funzionare **interamente in locale**, senza account e senza collegamenti a server. Non trasmette inventari dei file, nomi, contenuti, hash o statistiche diagnostiche. Telemetria, sincronizzazione e crash reporting remoti sono **fuori scope** finché non esiste una decisione esplicita.

## Dati elaborati

| Dato | Perché | Persistenza proposta |
| --- | --- | --- |
| URL e metadati dei candidati | Mostrare risultati e verificare scelte | Memoria volatile nella sessione |
| Dimensioni e date | Ordinamento e report | Memoria volatile; eventuale riepilogo aggregato |
| Cartelle autorizzate/escluse | Gestire scope utente | Preferenze locali, con revoca |
| Risultato di pulizia | Trasparenza e supporto in caso d'errore | Riepilogo locale con controlli di eliminazione |
| Contenuto dei file | Non necessario in MVP | Non leggere, non salvare |
| Hash file | Solo futura ricerca duplicati | On demand, mai trasmesso |

## Permessi

- Richiedere accesso solo quando serve e spiegare l'utilizzo.
- Valutare pannelli di selezione cartelle e security-scoped bookmarks **se il modello sandbox li richiede**.
- I permessi macOS (File e cartelle, Accesso completo al disco, TCC) restano sotto controllo del sistema e dell'utente: non sono bypassabili dal progetto.
- In caso di accesso negato, fornire istruzioni chiare senza richiedere privilegi maggiori del necessario.
- Se un bookmark persistente diventa invalido, chiedere nuovamente l'accesso; offrire la revoca in preferenze.

## Policy di logging

Niente nome utente, percorso completo, nome di file o contenuto nei log diagnostici per impostazione predefinita. Usare categorie, conteggi e codici d'errore. Un'eventuale esportazione dettagliata dev'essere avviata dall'utente, con anteprima e avvertimento sul contenuto.

## Modalità di distribuzione

Ipotesi iniziale: distribuzione diretta (non Mac App Store), con firma e notarizzazione prima di un rilascio pubblico. **Non è ancora una decisione sul sandbox**. La configurazione di sandbox, entitlements, eventuali helper e accesso a cartelle protette va sperimentata e documentata in un ADR successivo; nessuna scorciatoia con escalation dei privilegi.

## Dipendenze

Preferire i framework Apple. Nuove librerie solo se indispensabili, mantenute e compatibili con GPL-3.0. Nessuna dipendenza con SDK di analytics obbligatori.

