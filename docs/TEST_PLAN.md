# Strategia di test

## Obiettivo

Dimostrare che l'app **non tocca ciò che non deve** prima di misurare quanti file trova. Nessun test automatico deve agire sulle cartelle personali o sul filesystem reale dell'utente senza ambienti isolati.

## Livelli

- **Unit:** classificazione rischio, exclusions, policy scope, stime e use case con adapter finti.
- **Integration:** filesystem temporaneo con file e cartelle artificiali; verificare Cestino solo dove l'ambiente permette un ripristino controllato.
- **UI:** navigazione, assenza di selezione iniziale, conferma, errori chiari, accessibilità.
- **Manuale:** Mac Apple Silicon di test, installazione/firma, autorizzazioni, performance, filesystem APFS e configurazioni differenti.

## Matrice minima

| Scenario | Risultato atteso |
| --- | --- |
| Directory non autorizzata | Non letta; errore comprensibile |
| File fuori scope | Mai selezionabile o mutabile |
| Symlink che esce dallo scope | Non seguito né mutato |
| File rimosso dopo scansione | Saltato in preflight |
| File sostituito o cambiato | Saltato in preflight |
| Folder package, libreria Foto, backup | Protetto dalla policy generica |
| Accesso al Cestino negato | Errore riportato; nessun fallback delete |
| Volume scollegato durante azione | Saltato; non operare su percorso ricreato |
| Annullamento scansione | Stop cooperativo, nessuna mutazione |
| Annullamento pulizia | Stop fra elementi, esiti parziali corretti |
| Duplicati hard link o APFS clone (P1) | Nessuna pretesa di spazio recuperabile identico alla somma logica |
| Placeholder cloud (P1) | Nessun download o rimozione inaspettati |

## Test delle policy

Test table-driven sui confini del filesystem e sulle esclusioni. L'esito incerto dev'essere `protected`, non `eligible`. Controllare il rilevamento di condizioni TOCTOU e il comportamento di rollback non atomico.

## Prestazioni

Benchmark su cartelle sintetiche con molti file piccoli, file grandi e profondità elevata; rilevare tempo, uso RAM, CPU e accessi disco. Definire soglie **dopo** avere una baseline verificata su macchina reale.

## Verifica delle release

- [ ] Compilazione arm64 in configurazione release
- [ ] Suite automatica senza test distruttivi fuori da fixture
- [ ] Test manuale delle autorizzazioni TCC
- [ ] Test interruzioni, errori parziali e volume rimosso
- [ ] Valutazione sicurezza delle operazioni implementate
- [ ] Documentazione coerente con comportamento reale
- [ ] Firma e notarizzazione verificate, se distribuite

**Stato attuale:** piano di test; nessuna suite eseguibile presente.

