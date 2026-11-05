# Funzionalità e priorità

Legenda: **P0** = MVP, **P1** = fase successiva, **P2** = esplorazione. Nessuna voce è ancora implementata.

| Modulo | Funzione prevista | Priorità | Vincoli |
| --- | --- | --- | --- |
| Dashboard | Capacità, spazio disponibile e stato ultima scansione | P0 | Dati di sistema, niente “health score” inventato |
| Scansione file | Analisi cartelle autorizzate, file grandi e vecchi | P0 | Solo lettura, annullabile |
| Review | Lista, filtri, ordinamento, selezione esplicita | P0 | Spiegare percorso, dimensioni e rischio |
| Pulizia | Spostamento di file idonei nel Cestino | P0 | Riconvalida, conferma, resoconto, nessun delete permanente |
| Preferenze | Esclusioni, soglie, gestione scope autorizzati | P0 | Safe defaults |
| Cache e log utente | Catalogazione di specifiche categorie note | P1 | Non toccare dati di app in esecuzione; allowlist rivista |
| Duplicati | Hash SHA-256 incrementale su candidati verificati | P1 | Non selezionare automaticamente l'ultima copia |
| File ingombranti | Raggruppamento per classe, cartella, volume | P1 | Distingue dimensione logica da spazio reale |
| Monitor | CPU, memoria e pressione memoria, spazio | P1 | Niente allarmismi o “RAM boost” |
| App/Residuati | Inventario e proposta di disinstallazione | P2 | Associazione residui probabilistica, rischio elevato |
| Login items | Visibilità dello stato dove consentito | P2 | API pubbliche; niente disattivazioni indiscriminate |
| Scansioni periodiche | Pianificazione solo lettura con consenso | P2 | Opt-in e nessuna cancellazione automatica |
| Report | Esportazione locale, eventualmente anonimizzata | P2 | Privacy by design |

## Scansione file MVP: comportamento atteso

- L'utente sceglie una o più cartelle; niente scansione totale implicita del Mac.
- La scansione registra candidati, dimensioni, date e indicatori, saltando ciò che non è accessibile.
- Interfaccia con progressivo, possibilità di interrompere, errori non fatali e riepilogo degli esclusi.
- Le selezioni iniziali sono **vuote**. Non esiste “seleziona tutto” automatico su dati ambigui.
- I risultati cambiano se i file cambiano: prima della pulizia si verifica nuovamente ogni candidato.
- I file in cestino non costituiscono immediatamente spazio recuperato: viene mostrato il risultato effettivo dell'azione, non un guadagno inventato.

## Categorie da proteggere in modo conservativo

- Directory di sistema; librerie e dati applicativi non espressamente selezionati.
- Librerie Foto, Mail, backup, immagini disco montate, bundle e package.
- Cartelle sincronizzate o placeholder cloud e volumi rimovibili non esplicitamente autorizzati.
- Symlink e target fuori scope; file con permessi insoliti; candidati che non possono essere ricontrollati.

Le policy saranno centralizzate e testate, non duplicate nei componenti UI.

## Criterio di passaggio da P1/P2 a P0

Ogni funzione deve dimostrare precisione nella classificazione, non modificare elementi protetti, avere gestione degli errori e produrre un risultato interpretabile. Le funzioni prive di una strategia sicura di reversibilità restano fuori dal MVP.

