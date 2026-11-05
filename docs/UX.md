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
