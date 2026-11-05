# Esperienza utente e modello di interazione

## Principio

L'interfaccia deve fare una cosa molto bene: rendere **comprensibile** il risultato della scansione e lasciare all'utente la decisione, senza pressione psicologica o pulsanti ingannevoli.

## Navigazione (proposta)

~~~text
FraPoMacCleaner
├── Panoramica
├── Scansione
│   ├── File grandi
│   ├── File vecchi
│   ├── Duplicati        [futuro]
│   └── Cache e log      [futuro]
├── Operazioni / Cronologia
└── Impostazioni
    ├── Ambiti ed esclusioni
    ├── Privacy
    └── Informazioni
~~~

## Panoramica

Mostra: nome e capacità del volume, spazio usato e disponibile con data aggiornamento, stato dell'ultima scansione e azione principale `Analizza cartella…`. Evitare velocità, vantaggi o «salute» simulati.

## Scansione

- L'utente sceglie esplicitamente una o più cartelle autorizzate.
- Prima della scansione: riepilogo ambito/esclusioni, gestione permessi e avvertimenti pertinenti.
- Durante: file esaminati, eventuali risultati e pulsante `Annulla`; stima percentuale solo quando il denominatore è noto.
- Dopo: file trovati, file esclusi, errori di accesso, dati incompleti, durata.

## Risultati

Tabella accessibile con categoria, nome, percorso, dimensione apparente, ultima modifica, rischio e motivazione. Filtri per grandezza/età/rischio. Azioni contestuali: `Mostra nel Finder`, `Escludi`, `Seleziona` solo se ammesso.

L'utente non deve capire solo *quale* file è grande, ma anche *se* e *perché* potrebbe essere superfluo.

## Conferma della pulizia (fase successiva)

Un passaggio separato mostra il numero di file, percorso completo espandibile, livello di rischio, quantità **stimata** e destinazione Cestino. Nessun pre-check automatico delle voci dubbie. Per gli elementi `caution` è necessaria una conferma aggiuntiva. Le voci `protected` non sono selezionabili.

## Errori e feedback

Esempi di messaggi:
- «Questa cartella non è accessibile. Se vuoi analizzarla, selezionala esplicitamente dal Finder.»
- «Il file è cambiato dopo la scansione: nessuna operazione eseguita.»
- «3 file spostati nel Cestino, 1 saltato. Controlla i dettagli.»

Non usare mai «Pulizia completata» se sono presenti errori senza renderli visibili.

## Identità visiva

Interfaccia originale macOS con `NavigationSplitView`, SF Symbols, colori di sistema, dark/light mode e grafici sobrii. Non copiare schermate, loghi, icone o testi di applicazioni concorrenti. Supportare VoiceOver, contrasto, tastiera, dimensioni finestre e riduzione animazioni.

## Risultati navigabili (alpha.8)

La schermata permette ricerca testuale (nome/percorso), filtro per motivo e tipo di file e ordinamento dimensione/data/nome. Mostra quanti dei candidati visualizzati corrispondono ai filtri e ricorda il limite di 500 risultati. I riepiloghi sono comprimibili per lasciare spazio alla lista.

Tutti i file sono identificati come **protetti dalla rimozione**: una segnalazione per data o dimensione non è indicazione di superfluità. Il pulsante **Esporta riepilogo anonimo…** apre un dialogo esplicito di salvataggio. Nessuna selezione di file o azione di cancellazione è presente.

## Soglie e spazio osservato (alpha.9)

Prima di ogni analisi si possono scegliere soglie predefinite di **50/250/500/1024 MiB** e **30/90/180/365 giorni**. Un candidato deve soddisfare almeno una condizione. Nel report e nell'export appaiono i valori applicati realmente, anche dopo una nuova selezione della cartella.

I riepiloghi mostrano separatamente somma per percorsi, somma logica per inode distinti e blocchi allocati osservati. Le voci con più hard link vengono etichettate. Nessuno di questi numeri deve essere chiamato «spazio liberabile»: cloni APFS e snapshot possono condividere blocchi, e i file possono essere ancora necessari.

## Manutenzione e Avvii (alpha.10)

Le nuove sezioni indicano subito la natura **read-only** della diagnosi. La prima contiene due azioni separate: log utente datati e build Xcode. La seconda elenca i soli agenti dell'utente rappresentati da file `.plist` e offre il pulsante per aprire le impostazioni di login macOS. Ogni azione richiede selezione e accesso espliciti alla cartella prevista; in assenza di corrispondenza viene mostrato un errore leggibile.

La lista mostra al massimo 200 risultati, segnala analisi parziali e marca tutte le voci come protette. La presenza di un elemento LaunchAgents non equivale all'avvio attivo; la dimensione osservata dei residui non è automaticamente recuperabile.

## Revisione guidata di log e build (alpha.12)

La lista di manutenzione visualizza provenienza indicativa, motivo, stato **Protetto** oppure **Da approfondire**, byte logici e blocchi allocati osservati. Un filtro facoltativo mostra soltanto le voci da approfondire. Gli agenti di avvio restano tutti visibili e protetti.

Gli indizi sono limitati a report diagnostici/log ruotati o vecchie cartelle di build, secondo l'ultima data osservata. L'interfaccia dichiara esplicitamente che non può determinare se il file sia in uso né stimare byte recuperabili; nessuna selezione per la pulizia è disponibile.
