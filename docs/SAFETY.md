# Modello di sicurezza per operazioni sui file

**Questa specifica è il criterio di accettazione primario dell'app.** Non esiste una modalità “pulizia indiscriminata”.

## Confini di fiducia

L'app analizza filesystem che possono cambiare durante la scansione, contenere symlink, permessi complessi, volumi rimovibili, placeholder cloud e metadati incompleti. Una voce osservata durante la scansione **non è un'autorizzazione permanente a eliminarla**.

## Regole rigide

1. La scansione è *read-only*; l'utente autorizza esplicitamente lo scope.
2. Esclusioni e percorsi di sistema protetti prevalgono su qualunque criterio “file vecchio/grande”.
3. Di default non si seguono symlink, non si attraversano mount point non autorizzati e non si agisce fuori scope.
4. Package, bundle, directory applicative, backup, librerie Foto/Mail e container cloud sono protetti o richiedono un flusso specialistico separato.
5. Nessuna pulizia su file in uso o per cui non si riesca a stabilire con sufficiente affidabilità lo stato.
6. Nessuna richiesta di root, disabilitazione SIP/TCC, ACL bypass, `sudo` o uso di shell per cancellare.
7. Nessun `rm -rf`, nessuna cancellazione permanente, nessuno svuotamento automatico del Cestino.
8. Se la policy non può verificare la sicurezza dell'azione, la risposta è **skip**.

## Classificazione

| Livello | Descrizione | Comportamento |
| --- | --- | --- |
| Protected | Dato critico, fuori ambito o ambiguo | Nessuna selezione consentita per la pulizia MVP |
| Review | Candidato potenziale ma richiede contesto | Mostrare con spiegazione; niente suggerimento pre-selezionato |
| Eligible | File ordinario, scope valido, policy positiva | L'utente può selezionarlo e confermare |

**Eligible non equivale a “sicuro da eliminare per tutti”.** È solo l'idoneità tecnica all'azione scelta dall'utente.

## Esecuzione di una pulizia

- Mostrare elenco finale, numero elementi, stima dimensioni, rischio e destinazione dell'azione.
- Richiedere conferma esplicita, evitando azioni nascoste.
- Poco prima della mutazione: nuova lettura dell'elemento, controllo del percorso canonico, identità del file ove disponibile, tipo, policy, scope, permessi e volume.
- Non fidarsi ciecamente del solo percorso: attenzione a rimpiazzi/symlink e condizioni TOCTOU. Se non è possibile mitigare ragionevolmente il rischio, **saltare**.
- Usare `FileManager.trashItem(at:resultingItemURL:)` per gli elementi supportati. Se fallisce, segnalare il fallimento; **non** fare fallback automatico a `removeItem`.
- Salvare gli esiti per elemento senza affermare un rollback globale atomico: il Cestino non è una transazione.
- Non presentare la quantità cestinata come spazio fisico immediatamente liberato.

## Recuperabilità e limiti

Spostare nel Cestino è *generalmente* più reversibile che eliminare definitivamente, ma non garantisce ripristino in ogni circostanza: dipende da volumi, permessi, disponibilità e dallo stato del Cestino. Eventuale funzione di ripristino futura sarà un'operazione distinta, verificata e testata.

## Elementi speciali

- **APFS snapshot, cloni, sparse files:** dimensione nominale e spazio recuperabile possono divergere.
- **iCloud / provider cloud:** evitare materializzazione automatica, download involontari e rimozione di contenuti sincronizzati non compresa dall'utente.
- **App aperte / cache:** cancellazioni rimandate; evitare cache delle app nel MVP.
- **Link:** non seguire percorsi che escano dalle radici consentite; non presumere che symlink e hard link siano eliminabili come file ordinari.
- **Volumi esterni e rete:** solo se selezionati esplicitamente; nessuna azione se volume cambia o si disconnette.
- **Time Machine e backup:** esclusi da pulizia generica.

## Checklist prima di qualunque PR che modifica file

- [ ] Test per permission denied e accesso negato
- [ ] Test per symlink e cambio target fra scansione e conferma
- [ ] Test per file spostato, sostituito, modificato o scomparso
- [ ] Test per cartelle package, backup e root fuori scope
- [ ] Test per cancellazione della task e fallimenti parziali
- [ ] Nessun fallback da Cestino a delete permanente
- [ ] Review UI con stato e spiegazione del rischio
- [ ] Nessuna raccolta/esposizione di contenuti sensibili nei log

Riferimenti alle API ufficiali in [REFERENCES.md](REFERENCES.md).

