# Politica di sicurezza e prevenzione perdita dati

Questo documento è **normativo**: ogni implementazione deve rispettarlo. In caso di conflitto con requisiti, performance o UX, prevale la protezione dei dati.

## Livelli di rischio

| Livello | Comportamento |
| --- | --- |
| **Protected (bloccato)** | Mai proposto per la rimozione; nessuna eccezione dall'UI ordinaria. |
| **Caution (revisione esplicita)** | Rischio concreto o dipendenza applicativa; richiede spiegazione specifica e conferma aggiuntiva. |
| **Reviewable (basso rischio relativo)** | Può essere selezionato manualmente dopo la revisione; **non** indica sicurezza garantita. |

Non esiste `auto-clean all` che ignori la classificazione.

## Esclusioni iniziali

Sono **fuori ambito per rimozione** almeno:
- `/System`, `/usr`, `/bin`, `/sbin`, `/private`, `/Library` (a meno di future regole esplicite e molto ristrette), volumi di sistema e snapshot.
- `~/Library/Keychains`, dati di credenziali, autorizzazioni, profili, backup/sync, database delle app, posta e archivi dei browser.
- Librerie Foto/Musica, bundle delle applicazioni, macchine virtuali, immagini sparse, archivi Time Machine.
- Dati iCloud in sincronizzazione, placeholder cloud, directory gestite da provider o file aperti/in uso quando identificabili.
- Cestini, directory speciali, volumi esterni e cartelle di rete salvo scelta esplicita per funzioni **read-only**.

L'elenco è il **punto di partenza conservativo**, non esaustivo. L'esclusione deve usare identità e risoluzione del filesystem, non semplici prefissi di stringa. Una whitelist esplicita di file candidati è più sicura di «tutto tranne queste cartelle».

## Invarianti di sicurezza

1. La scansione non modifica contenuti, permessi, timestamp per scelta intenzionale né impostazioni di sistema.
2. La UI non possiede API di cancellazione; solo CleanupCoordinator può comporre azioni.
3. Ogni azione richiede un piano leggibile, selezione e conferma **nella sessione attuale**.
4. Prima di muovere un file: rieseguire verifiche su percorso reale, ambito autorizzato, link, mount, identità, policy e disponibilità.
5. **Symlink:** mai attraversarli implicitamente durante scansione ricorsiva; non cancellare la destinazione risolta perché è stato selezionato un link.
6. **Hard link / cloni APFS:** distinguere oggetti e spazio fisico; non considerare un gruppo «duplicato eliminabile» senza valida verifica.
7. Se una validazione fallisce, il file viene **saltato** con un messaggio.
8. Operazioni di default tramite `FileManager.trashItem(at:resultingItemURL:)`; registrare il percorso risultante quando disponibile.
9. Nessuna eliminazione permanente automatica, nessun `rm -rf`, `sudo`, comando shell distruttivo, elevazione opportunistica o bypass di SIP/TCC.
10. Ogni operazione può essere interrotta; l'annullamento **non** annulla operazioni già completate.
11. Nessuna promessa di recupero dal Cestino dopo svuotamento, su volumi incompatibili o in errori di filesystem.
12. I permessi sono il limite: no scansione indiscriminata di aree accessibili soltanto con autorizzazioni speciali.

## Permessi e distribuzione

- **MVP:** partire da ambiti selezionati dall'utente con `NSOpenPanel`/file importer e accessi autorizzati; preservare eventuali security-scoped bookmark solo se davvero necessari.
- **Full Disk Access:** non richiederlo come passaggio automatico, non aggirarlo; eventuale funzione futura richiede caso d'uso documentato e scelta informata.
- **App Sandbox:** decisione esplicita dopo test; la distribuzione fuori dallo Store **non elimina** le protezioni TCC, SIP, POSIX o Gatekeeper.
- **Helper privilegiati:** nessuno per il primo MVP. Una futura proposta richiede threat model e revisione dedicata.

## Threat model minimo

| Rischio | Mitigazione progettata |
| --- | --- |
| File sostituito tra scansione e azione (TOCTOU) | Revalidare metadata/identità; abortire se cambia o non verificabile. |
| Symlink o mount che puntano altrove | Non seguire, controllare tipo e ambito effettivo. |
| Rimozione di dati applicativi attivi | Denylist + whitelist specifica + nessuna pulizia per estensione generica. |
| Duplicati con hard link / cloni | Dedupe logico distinto da spazio recuperabile; non eliminare senza conferma puntuale. |
| Ambiti cloud o network instabili | Scansione limitata, nessuna pulizia in modalità standard. |
| Dati sensibili nei log | Redazione, log strutturati con privacy, export opzionale. |
| Cancellazione parziale o crash | Operazione elementare per file, esito durevole e niente retry automatico aggressivo. |
| Interfaccia che sottostima il rischio | Percorso, descrizione, rischio e conferma sempre visibili. |

## Gate specifico per log utente e avvii in background (priorità P0)

Per il primo caso d'uso di pulizia ordinaria è vietato trattare genericamente i file sotto `/System`, `/Library`, `/private/var/log`, `/var/db` o i log unificati macOS come rifiuti. **Il sistema gestisce autonomamente rotazione e conservazione di molti log**. Il solo criterio «vecchio», «grande», «cache» o «.log» non dimostra che un elemento sia eliminabile.

Una policy specifica deve definire una **allowlist stretta** di file dell'utente e di app con semantica nota, verificare accesso e titolarità, escludere file attivi/in rotazione e considerare i segnali mancanti come rischio `protected`. L'anteprima può essere proposta prima della fase distruttiva; ogni spostamento nel Cestino rimane proibito finché non esistono tutte le validazioni richieste in questo documento.

La diagnosi di login item, agenti e servizi di background è **read-only** per gli elementi di terze parti: non eliminare `.plist`, non terminare processi e non disabilitare servizi modificando direttamente file, database o impostazioni protette. Consentire soltanto il collegamento alle Impostazioni di sistema o l'uso autorizzato delle API pubbliche Apple nel rispettivo ambito. L'eliminazione di un log non disabilita l'avvio del processo che lo produce.

## Verifica e rilascio

Prima di abilitare la pulizia: test automatici su fixture sintetiche, controlli su symlink/hardlink/rename race, cartelle protette, permessi revocati, filesystem in sola lettura, errori Cestino, volumi esterni e iCloud. Condurre una prova manuale **solo su file di test**. Vedi `TESTING.md`.

## Segnalazioni

Non pubblicare file personali, percorsi completi o dati di terzi in Issue. Le vulnerabilità con rischio perdita dati devono essere segnalate al maintainer in modalità riservata prima di una divulgazione pubblica.

## Vincoli di lettura rafforzati (alpha.9)

La scansione prova a identificare i file tramite `lstat` senza seguire il collegamento finale, scarta device diversi dalla radice autorizzata e aggrega gli hard link per inode. Il confronto dei device non equivale a validare ogni mount point, e una verifica `lstat` non elimina tutte le race tra controllo ed enumerazione. Queste mitigazioni sono **solo per letture esplorative**, non autorizzano spostamento nel Cestino né altre mutazioni. Anche le misure dei blocchi `st_blocks` sono indicative e non devono essere presentate come spazio recuperabile.

## Diagnosi P0-A implementata (alpha.10)

L'implementazione iniziale elenca solo metadati di log utente datati, file nelle directory di compilazione Xcode e nomi `.plist` di `~/Library/LaunchAgents`, dopo richiesta esplicita dell'utente (pulsante) e match con la posizione attesa. Non apre contenuti, non usa `launchctl`, non disabilita agenti, non richiede Full Disk Access, non legge `/private/var/log` né directory di sistema.

Il file `.plist` resta protetto, indipendentemente dalla data o dimensione. Il modulo di scansione non possiede alcuna API di cancellazione, non prova se i log siano in uso e non distingue con certezza le build ancora utili: **queste informazioni non sono sufficienti per avviare una pulizia**. La futura fase P0-B richiederà prove dedicate e una policy di ammissibilità separata, con conferme e revalidazione dell'identità.

## Eccezioni di sola lettura per l'avvio diretto (alpha.11)

L'App Sandbox rimane attiva. Per evitare che una scelta cartella sia necessaria ad ogni ispezione P0-A, il bundle firmato dichiara l'entitlement Apple `com.apple.security.temporary-exception.files.home-relative-path.read-only` **solo per le tre posizioni esatte** previste nel modulo. È una decisione da riesaminare prima di distribuire nello Store; le eccezioni temporanee sono soggette a valutazione e non rimuovono protezioni TCC/POSIX. Non richiedere privilegi amministrativi o Full Disk Access.

Nessun percorso arbitrario viene accettato da `RoutineInspectionEngine` e la sola apertura della sezione non avvia una scansione: occorre premere il pulsante. Un errore di accesso alla cartella iniziale **fallisce esplicitamente**: non viene presentato come elenco vuoto. Nessuna nuova azione scrive, elimina file o gestisce servizi. La successiva fase di pulizia non deve assumere che questa eccezione di sola lettura autorizzi operazioni di scrittura.
