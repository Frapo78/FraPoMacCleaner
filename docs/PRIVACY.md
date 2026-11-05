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
