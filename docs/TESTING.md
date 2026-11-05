# Strategia di test e criteri di rilascio

**Sono presenti suite XCTest per dominio e scanner read-only.** I test dello scanner sono stati eseguiti con successo su [macOS ARM64 (Xcode 16.4)](https://github.com/Frapo78/FraPoMacCleaner/actions/runs/42058024473): 9 test, 0 errori. Permessi App Sandbox, prestazioni su alberi grandi e casi di revoca rimangono da verificare manualmente. Non esistono test di operazioni distruttive perché non esiste codice di pulizia.

## Livelli

1. **Unità:** classificazione del rischio, esclusioni, ordinamento risultati, dimensioni e formattazione.
2. **Integrazione:** enumerazione filesystem temporaneo, metadata, accesso negato, Cestino test e recupero manuale.
3. **UI:** percorso autorizzazione → scansione → risultati → anteprima → conferma, accessibilità e annullamento.
4. **Prestazioni:** scansioni con 1k/10k/100k elementi sintetici, streaming hash di file grandi, memoria e I/O.
5. **Manuali su Apple Silicon:** test in cartelle temporanee dedicate, non su home reali; verifica strumenti Xcode e macOS target.

## Matrice di casi ad alto rischio

| Scenario | Risultato atteso |
| --- | --- |
| Path `/System` o altra radice protetta | Bloccato prima dell'azione. |
| Symlink a percorso protetto | Non attraversato; nessun target modificato. |
| Hard link allo stesso inode | Non etichettato come doppia occupazione fisica indipendente. |
| File rinominato/sostituito dopo scansione | Revalidazione fallita, operazione saltata. |
| File modificato dopo scansione | Stima invalidata e nuova conferma richiesta, oppure skip. |
| File non leggibile / permesso revocato | Errore esplicito, nessuna escalation. |
| Volume esterno smontato | Sessione termina in sicurezza, report errore. |
| Directory di rete / contenuti cloud | Nessuna pulizia ordinaria automatica. |
| Elemento in Cestino / percorso ambiguo | Non aggiunto a un piano sicuro. |
| Annullamento durante scansione | Stop tempestivo, nessuna mutazione. |
| Annullamento durante pulizia | Nessuna nuova azione; mantenere esiti già completati. |
| Errore su metà elementi | Resoconto parziale accurato, nessun retry aggressivo. |
| Clone APFS / sparse file | Non promettere byte fisici liberati uguali alla somma logica. |
| File duplicati con contenuto differente | Nessun falso positivo dopo verifica finale. |

## Nuova priorità P0: log, residui e agenti utente (da implementare)

**Test necessari prima della modalità read-only:** allowlist/denylist con directory sintetiche, distinzione log utente/log sistema, regressioni sui percorsi di app attive, file di credenziali, volumi esterni, symlink e hard link, directory non accessibili e confini TCC/Sandbox. Verificare che la diagnosi degli avvii automatici non cambi impostazioni e non uccida processi.

**Gate aggiuntivo prima della prima pulizia:** simulare log in scrittura o rotazione, attività concorrente, rinomina/sostituzione TOCTOU, file che cambiano owner o permessi, permessi revocati, hard link, disconnessione disco, errore parziale del Cestino e annullamento; garantire il blocco di tutte le categorie non esplicitamente approvate. Usare esclusivamente fixture di test e provare il flusso su Mac Apple Silicon. Verificare che nessun risultato prometta boost prestazionale né spazio recuperabile identico ai byte logici.

## Criteri per abilitare la pulizia

- Test automatici per tutte le policy e i casi ad alto rischio applicabili.
- Azioni provate solo su file temporanei creati dai test.
- App non usa `rm -rf`, shell privilegiata, comandi di manutenzione non documentati.
- La UI spiega differenza fra spazio analizzato, spazio selezionato e spazio effettivamente liberato.
- Nessuna regressione nota nella gestione permessi/identità file.

## Tracciamento verificabile

Per ogni PR: indicare test eseguiti, ambiente macOS/Xcode, risultato e test non eseguiti. Non contrassegnare test come superati senza un'esecuzione reale. Per una release: checklist e artefatti di build verificabili.

## Verifica della ripartizione (alpha.6)

[CI macOS ARM64](https://github.com/Frapo78/FraPoMacCleaner/actions/runs/42060620420): **11 test XCTest, 0 errori**. I due nuovi casi provano classificazione per estensione senza lettura dei contenuti e aggregazione di file piccoli sotto soglia, distinguendo i candidati dal totale osservato. Per la validazione manuale restano la UI dei grafici a barre, la revoca dei permessi e le prestazioni su alberi sintetici grandi.

## Verifica dei progressi e delle esclusioni (alpha.7)

[CI macOS ARM64](https://github.com/Frapo78/FraPoMacCleaner/actions/runs/42063148205): **13 XCTest superati, zero errori**. Le nuove prove verificano che gli snapshot di progresso siano non decrescenti e coincidano con il rapporto finale, e che una sottocartella protetta venga esclusa senza leggere il contenuto. I test esistenti confermano separatamente link simbolici, limiti di scansione, annullamento e metadati.

Da validare manualmente: annullamento su scansione lunga, progressi SwiftUI, autorizzazioni TCC/App Sandbox, volumi diversi e cartelle non accessibili. I dati di diagnostica sono solo contatori senza percorsi.

## Esplorazione e privacy del rapporto (alpha.8)

[CI macOS ARM64](https://github.com/Frapo78/FraPoMacCleaner/actions/runs/42066402117): **18 test XCTest, zero errori**. Cinque test nuovi verificano ricerca per nome/percorso senza distinzione maiuscole, combinazione dei filtri, quattro ordinamenti con date mancanti, esportazione limitata ai soli aggregati con un nome utente fittizio ostile e mantenimento della policy che blocca la rimozione.

La compilazione UI su macOS ARM64 è stata completata; la verifica manuale dell'interfaccia, salvataggio attraverso `NSSavePanel`, accesso App Sandbox/revoca, test di prestazione e accessibilità restano aperti.

## Identità dei file e soglie personalizzabili (alpha.9)

[CI macOS ARM64](https://github.com/Frapo78/FraPoMacCleaner/actions/runs/42100723365): **23 XCTest superati, zero errori**. Nuovi test con hard link creati su file temporanei verificano che due percorsi rimangano due finding ma contino una sola volta nei totali per inode; il caso sparse controlla che i byte allocati osservati non siano presentati come dimensione logica recuperabile. Test dedicati controllano anche le soglie opzionali e il rifiuto di soglie invalide, oltre al confronto di device.

**Non sono ancora verificati** su hardware reale: attraversamento di un volume montato dentro una cartella, permessi revocati durante scansione, cloni APFS e snapshot, benchmark con 10k/100k elementi e il comportamento UI dei preset. La classificazione del rischio resta fail-closed e la pulizia assente.

## Diagnostica ordinaria (alpha.10)

[CI macOS ARM64](https://github.com/Frapo78/FraPoMacCleaner/actions/runs/42105807359): **30 test, 0 errori**. I 7 casi del nuovo modulo creano directory di prova dedicate e controllano: whitelist di suffissi e anzianità, rifiuto di cartelle non previste, esclusione di symlink/hard link e directory sensibili, aggregazione di build Xcode, presenza non equivalente all'attività degli agenti, annullamento e limiti, assenza di autorizzazione alla rimozione.

**Test manuali aperti:** selezione reale delle tre posizioni su Mac con App Sandbox e read-only entitlement; cartelle assenti/negate, volumi diversi, revoca dei permessi, log in rotazione, grandi directory; verifica della UI e del collegamento ufficiale alle Impostazioni. La prima versione non abilita alcuna pulizia.

## Avvio diretto della manutenzione (alpha.11)

[CI macOS ARM64](https://github.com/Frapo78/FraPoMacCleaner/actions/runs/42113452818): **32 test, zero errori**. Due nuovi test verificano le tre mappature predefinite e la segnalazione della cartella mancante. La CI compila l'interfaccia senza file importer per la Manutenzione.

**Test manuali ancora necessari:** lanciare il pacchetto **firmato Apple Development** su macOS con App Sandbox attiva, verificare che un clic apra direttamente ciascuna delle tre scansioni e che gli errori TCC/UNIX siano mostrati, senza chiedere un percorso. Controllare firma ed entitlement inclusi nell'app distribuita. La disponibilità di un entitlement non prova di per sé accessibilità su ogni Mac.

## Indizi di revisione, mai permessi di cancellazione (alpha.12)

[CI macOS ARM64](https://github.com/Frapo78/FraPoMacCleaner/actions/runs/42118076668): **37 XCTest, 0 errori**. I cinque nuovi casi verificano rapporti diagnostici con età diversa, log normali sempre protetti, build Xcode vecchie e recenti, scansioni con limiti raggiunti, agenti di avvio protetti e data assente. Verificano anche che `canRemove` sia sempre falso e che `st_blocks` sia riportato solo come osservazione.

La nuova vista e il filtro sono compilati in CI, ma resta la verifica visiva manuale su build firmata, nonché lo stato effettivo di file aperti/attività dei progetti e i cambiamenti fra scansione e uso dei risultati.
