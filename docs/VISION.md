# Visione del prodotto

## Problema

Gli utenti macOS spesso non sanno *quali* dati occupino spazio, *se* siano eliminabili e *quale effetto* abbia la rimozione. Un'interfaccia che promette “ottimizzazione” senza spiegazioni può indurre perdita di dati o pulizie inutili.

## Proposta di valore

FraPoMacCleaner dà strumenti per ispezionare, comprendere e liberare spazio **con decisioni verificabili**. È un'app nativa Apple Silicon, con un costo di risorse contenuto, senza dipendenza da servizi cloud e con azioni leggibili.

## Pubblico

- Utenti domestici che vogliono capire cosa occupa il proprio SSD.
- Sviluppatori e creativi con molti file, cache di build e archivi.
- Utenti avanzati che richiedono report e selezioni precise, non un pulsante “magico”.

## Differenziazione

- Presenta **risultati e rischio** prima di offrire un'azione.
- Distingue spazio logico, spazio allocato e spazio realmente recuperabile dove le API permettono una stima.
- Evidenzia cosa viene *escluso*, non solo cosa viene trovato.
- Privilegia azioni reversibili e fornisce un resoconto di ciò che è cambiato.
- Non equipara memoria RAM usata a “problema” e non elimina cache indiscriminatamente.

## Principi guida

**Sicurezza > correttezza > chiarezza > prestazioni > ampiezza di funzioni.**

L'utente mantiene il controllo: il programma può raccomandare, non deve forzare una scelta. Le operazioni automatiche future richiederanno una valutazione separata.

## Non-obiettivi

- Imitare interfaccia, icone, nomi o meccaniche proprietarie di CleanMyMac.
- Antimalware/antivirus, modifica delle protezioni del sistema, “riparazioni” non documentate.
- Pulizia di RAM, forzatura di purge di cache macOS, terminazione automatica di processi.
- Rimozione di snapshot APFS/Time Machine, cartelle di sistema, backup o dati iCloud in MVP.
- Cancellazione irreversibile o svuotamento automatico del Cestino.
- Account obbligatori, pubblicità, abbonamenti o telemetria nel MVP.

## Criteri qualitativi

- Zero perdita dati nei test e nessuna azione fuori dall'ambito esplicitamente autorizzato.
- Scansione interrompibile, interfaccia responsiva, consumo risorse misurabile.
- Messaggi onesti per “non accessibile”, “stima”, “file escluso” e “azione non eseguita”.
- Capacità di spiegare all'utente perché un elemento è stato suggerito o protetto.

## Vincoli di piattaforma

ARM64 nativo, SwiftUI, rispetto delle autorizzazioni del filesystem e delle protezioni macOS. Requisito minimo proposto: macOS 14+; da misurare e confermare nella prima build.

## Stato

Questa è una visione, non la descrizione di un prodotto già funzionante.

