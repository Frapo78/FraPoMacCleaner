# Privacy by design

**Stato:** impegni di progettazione, non informativa legale definitiva di un'app distribuita.

## Dati trattati

La futura app potrà leggere metadati locali (nome, URL/percorso, dimensione, data di modifica, tipo) dei file **nell'ambito autorizzato**. Il confronto di duplicati può richiedere la lettura del contenuto per calcolare un hash locale: il contenuto non deve essere caricato su servizi remoti.

## Impegni

- Elaborazione **sul Mac**, senza server di analisi.
- **Nessuna telemetria per impostazione predefinita**.
- Niente account o login obbligatorio.
- Log diagnostici con percorsi e identificativi oscurati o protetti; esportazione solo su scelta dell'utente.
- Report locali minimali, cancellabili, e con periodo di conservazione definito prima del rilascio.
- Permessi richiesti solo quando una funzione ne ha effettiva necessità.
- Nessuna scansione in background o accesso permanente a cartelle senza consenso specifico.

## Punti da finalizzare prima del rilascio

Formato e ciclo di vita dei report, eventuali bookmark di sicurezza, canale di aggiornamento software, eventuale crash reporting opt-in e testo definitivo della privacy policy. Qualsiasi servizio di rete futuro richiederà una decisione architetturale e una informativa aggiornata.

## Esportazione locale anonima (alpha.8)

La funzione `ScanSummaryExporter` richiede un gesto esplicito e una destinazione scelta con il pannello macOS. Il JSON contiene **solo** aggregati numerici e categorie fisse; non include nomi, percorsi, date individuali, etichette delle cartelle o liste dei candidati. Nessun upload o salvataggio automatico. L'utente conserva e gestisce il file esportato.

La parola *anonimo* descrive l'assenza di identificativi diretti nel documento, non garantisce anonimato matematico in tutti gli scenari: anche le statistiche aggregate possono essere private. Il file non deve essere allegato automaticamente a segnalazioni pubbliche.

## Contabilità per inode (alpha.9)

Durante la scansione viene mantenuto in memoria un insieme limitato di coppie device/inode per evitare il doppio conteggio degli hard link. L'esportazione JSON aggiornata include esclusivamente i **totali numerici** e le soglie utilizzate: **non include inode, ID del volume, percorsi, nomi file o elenchi individuali**. I dati sono elaborati solo in locale nella sessione e non persistono automaticamente.

## Diagnosi dei residui utente (alpha.10)

Dalla alpha.11 l'app legge direttamente le sole tre posizioni predefinite quando l'utente preme il relativo pulsante, utilizzando un entitlement Sandbox di sola lettura ristretto; nessun bookmark persistente. Mantiene solo in memoria nomi di log, cartelle DerivedData e identificativi nominali di LaunchAgents per mostrare le voci nel Finder; non legge contenuti, non esporta inventari e non li trasmette. I percorsi delle tre aree sono descrizioni pubbliche dei casi d'uso, non privilegi di accesso.

## Metadati di revisione (alpha.12)

La classificazione e i blocchi allocati sono prodotti in locale utilizzando metadati già necessari alla diagnosi. L'indicazione della sottocartella non identifica con certezza l'app di origine. Nessun nome di file, percorso, identità inode o dato di processi viene trasmesso o esportato automaticamente. I risultati sono mantenuti nella sessione e non costituiscono permessi di pulizia.

## Firme dei metadati della sessione (alpha.13)

La funzione di confronto conserva in memoria firme con percorso relativo, identità inode/device e timestamp di file e cartelle osservati. Questi dati possono rivelare nomi di progetto, pertanto **non sono esportati nel JSON, non vengono scritti in file e non sono trasmessi**. Il report precedente viene scartato dopo il confronto e non è mantenuto fra riavvii dell'app. Nessun contenuto viene letto per calcolare le firme.
