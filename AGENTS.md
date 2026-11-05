# AGENTS.md — Contratto operativo per sviluppatori e assistenti AI

Questo file va letto **prima di analizzare, modificare, creare codice o aprire PR** su FraPoMacCleaner. Si applica all'intero repository, salvo istruzioni più restrittive in file AGENTS.md locali.

## Stato del progetto

- Fase corrente: **infrastruttura Xcode pre-alpha**. La creazione di skeleton SwiftUI e test è autorizzata; scanner e funzioni di pulizia devono seguire milestone esplicite e revisione di sicurezza.
- Il progetto include CI e preparazione delle release, ma nessun binario va dichiarato completo senza funzionalità e verifiche reali.
- Il repository contiene una licenza **GPL-3.0**: non sostituirla o modificarla senza richiesta del maintainer.
- Le funzionalità pianificate non devono mai essere descritte come già funzionanti.

## Obiettivo

Costruire una utility macOS **nativa Swift/SwiftUI** per Apple Silicon che analizzi e gestisca file superflui con un criterio **safety-first** e senza bypassare le protezioni del sistema operativo.

Documenti vincolanti:
1. `docs/SECURITY.md` (in caso di conflitto prevale sui requisiti funzionali).
2. `docs/ARCHITECTURE.md` e ADR approvate.
3. `docs/REQUIREMENTS.md`, `docs/ROADMAP.md` e `docs/TESTING.md`.

## Identità visiva

- L'icona del bundle e il logo sono risorse del catalogo `FraPoMacCleaner/Resources/Assets.xcassets`, rispettivamente `AppIcon.appiconset` e `BrandLogo.imageset`.
- Non sostituirli con segnaposto e non creare identità grafiche divergenti. Prima di cambiare marchio, aggiornare `docs/BRANDING.md`.
- Ogni modifica agli asset deve essere verificata nelle build Debug e Release e produrre una nuova prerelease quando modifica la presentazione pubblica dell'app.
- Non sostituire mai asset HD con miniature ingrandite. Conservare gli hash nel controllo `scripts/check_brand_assets.sh`, aggiornandoli solo dopo approvazione esplicita dei nuovi originali.

## Regole di sviluppo

- Non citare nomi, marchi, prodotti o società concorrenti in documentazione, sorgenti, commenti, metadati, asset e messaggi di commit. La descrizione pubblica del progetto deve essere autonoma.
- Per modifiche maggiori: incrementare la versione, aggiornare il changelog, aggiornare `RELEASE_VERSION` su `main` e verificare la GitHub Release generata automaticamente. Consulta `docs/RELEASING.md`.
- Prima di modificare la UI aprire `docs/GETTING_STARTED.md` e verificare i test CI; non dichiarare una build valida senza evidenza.

1. **Read-only by default.** Nessun codice distruttivo dentro scanner o view model.
2. **Due fasi distinte.** Ogni modifica ai file passa da piano/anteprima a conferma esplicita; rivalidare prima dell'esecuzione.
3. **Default Cestino.** Non introdurre `rm -rf`, `sudo`, operazioni su cartelle di sistema o pulizie ricorsive indiscriminate.
4. **Least privilege.** Mai tentare di eludere SIP, TCC, sandbox, autorizzazioni, Gatekeeper o permessi UNIX.
5. **Percorsi ostili.** Non fidarsi del nome di un file o della sua posizione iniziale: trattare symlink, hard link, mount point, path traversal e sostituzione tra scansione e azione (TOCTOU).
6. **Valori verificabili.** Distinguere «dimensione logica» da «spazio fisico recuperabile»; non sommare ingenuamente cloni APFS o hard link.
7. **Prudenza applicativa.** Escludere per impostazione predefinita dati attivi di browser, database, app, backup, sincronizzazioni cloud, librerie foto e credenziali.
8. **Cancellazione e ripristino.** Registrare esito per-file e non promettere ripristino automatico universale.
9. **Risorse.** I/O e hash in streaming, job annullabili, limiti di concorrenza, UI responsiva.
10. **Privacy.** Niente upload di percorsi, contenuto file, inventari, identificativi o telemetria non autorizzata.
11. **API ufficiali.** Preferire API pubbliche Apple, documentare limiti e permessi necessari; nessuna API privata.
12. **No promesse infondate.** Niente «boost RAM», finti indicatori di salute o stime inventate.

## Qualità richiesta per ogni futura PR di codice

- Scope piccolo e testabile; nessun refactoring estraneo.
- Test automatici su file temporanei e fixture sintetiche, mai sui dati reali dell'utente.
- Copertura dei casi pericolosi e delle condizioni di errore.
- Aggiornamento di documentazione, ADR e changelog quando cambiano decisioni o comportamento.
- Build/test documentati con output reale; non dichiarare «test superati» senza averli eseguiti.
- Nessun commit di segreti, certificati, provisioning profile, dati di utenti, archivi di cache o artefatti binari.
- I secret Apple Development si usano esclusivamente nel workflow di sviluppo su `main`; mai nelle PR o nel workflow di distribuzione. Non mettere la chiave privata negli artefatti.
- Se un'azione richiede privilegi più elevati, bloccarla e proporre una progettazione separata per la revisione.

## Sequenza di lavoro

Leggere repository e `AGENTS.md` → identificare il requisito → controllare `docs/SECURITY.md` → proporre modifica minima → implementare (solo se richiesto) → testare → esaminare i rischi → documentare esito e limiti.

In caso di ambiguità scegliere sempre l'opzione **meno distruttiva**. Non trasformare una funzione informativa in un'azione automatica.
