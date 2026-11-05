# Roadmap

Le date non costituiscono una promessa di rilascio. Ogni milestone avanza solo se supera i criteri di uscita.

## M0 — Fondazioni e documentazione (attuale)

- [x] Visione, target, confini e principi di prodotto
- [x] Architettura iniziale e separazione scansione / mutazione
- [x] Modello di sicurezza, privacy, UX e piano test
- [x] Inventario funzionalità e priorità
- [ ] Validazione requisiti macOS/Xcode, sandbox e autorizzazioni con prototipo
- [ ] Revisione e accettazione esplicita delle decisioni aperte

**Exit gate:** documenti coerenti; rischi principali catalogati e policy condivise.

## M1 — Scheletro nativo

- [ ] Progetto Xcode arm64 SwiftUI avviabile
- [ ] Sidebar, navigazione, design system e accessibilità base
- [ ] Domain models, adapter protocollati e dependency injection
- [ ] Impostazioni locali, error handling, test suite iniziale
- [ ] CI di build/test su runner macOS compatibile

**Exit gate:** app compilabile su Mac Apple Silicon, test verdi; nessun codice di cancellazione.

## M2 — Analisi read-only

- [ ] Selezione cartelle e permessi secondo policy scelta
- [ ] Inventory streaming, esclusioni, progresso e annullamento
- [ ] File grandi/vecchi, ordinamento e filtri
- [ ] Report di errori ed esclusioni, niente accesso fuori scope
- [ ] Test con symlink, package, volumi e file mutabili

**Exit gate:** scansione affidabile senza modificare dati; limiti memoria/I/O misurati.

## M3 — Pulizia MVP e versione 0.1

- [ ] Selezione esplicita, valutazione rischio, preflight
- [ ] Cestino tramite API native, mai delete permanente
- [ ] Esiti per file, gestione errori parziali e interruzione
- [ ] Test sicurezza e test manuali di recupero con dati fittizi
- [ ] Documentazione installazione, limiti, permessi, firma/notarizzazione se distribuita

**Exit gate:** nessuna perdita dati nei test, operazioni prevedibili, versione candidata verificata su Apple Silicon.

## M4 — Analisi avanzata / versione 0.2

- [ ] Classificazione prudente di cache/log utente
- [ ] Ricerca duplicati con hash incrementale e politica di conservazione copie
- [ ] Report più precisi su spazio logico/fisico quando possibile

## M5 — Diagnostica / versione 0.3

- [ ] Monitor risorse senza promesse di “boost”
- [ ] Inventario app e login items con API documentate
- [ ] Valutare disinstallazione residui solo dopo audit separato

## Backlog esplicitamente rinviato

Automazione, helper privilegiati, interventi su snapshot, cancellazione definitiva, antimalware, sincronizzazione cloud e funzioni di rete. Ogni aggiunta richiede valutazione di sicurezza/privacy autonoma.

## Regole per lo stato

Spuntare una voce solo quando esiste evidenza nel repository. Una specifica scritta non equivale a una funzione completata.

