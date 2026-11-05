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
