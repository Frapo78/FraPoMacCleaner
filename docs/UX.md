# Esperienza utente e direzione visiva

## Identità

Interfaccia originale, non una riproduzione di CleanMyMac: macOS nativo con SwiftUI, navigazione a sidebar, tipografia di sistema, SF Symbols appropriati e grafici comprensibili. Supportare tema chiaro/scuro, VoiceOver, accessibilità da tastiera e localizzazione.

## Flusso MVP

```text
Dashboard
   |
   +--> Scegli cartella/e + esclusioni
   |           |
   |       Avvia scansione (sola lettura)
   |           |
   |       Risultati + esclusi + errori
   |           |
   |       Selezione manuale
   |           |
   |       Riepilogo e conferma
   |           |
   |       Nuovo controllo di sicurezza
   |           |
   |       Sposta nel Cestino / salta
   |           |
   +<-- Resoconto finale (successi e fallimenti)
```

## Schermate previste

1. **Dashboard:** capacità e disponibilità del disco, ultima analisi, invito a scegliere scope. Nessun punteggio salute inventato.
2. **Scansione:** progressivo con elementi visitati, dimensioni *stimate* e pulsante Annulla. Stati accesso negato e risorse escluse visibili.
3. **Risultati:** ricerca e filtri, colonne percorso/dimensione/data/motivo/rischio. Nessuna casella pre-selezionata.
4. **Conferma:** elenco finale chiaro; tasto distinto e riconoscibile per spostare nel Cestino.
5. **Esiti:** quanti cestinati, saltati, cambiati, falliti; possibilità di aprire il Cestino/Finder quando pertinente.
6. **Impostazioni:** scope autorizzati, esclusioni, soglie, spiegazioni sui permessi, pulizia della cronologia locale.

## Linguaggio

Evitare “Ottimizza in un click”, “Risolti 148 problemi”, “Raddoppia la velocità”. Preferire “Abbiamo trovato 12 file oltre 1 GB”, “Questa cartella non è accessibile”, “3 file sono cambiati e non sono stati toccati”.

## Comportamenti di protezione

- Prima di agire su file personali, rendere sempre visibile il percorso.
- Errori parziali non devono sparire dietro un unico indicatore verde.
- Non utilizzare pattern ingannevoli per spingere la selezione di elementi.
- Pulsante Annulla durante la scansione; durante la pulizia interrompere prima dell'elemento successivo (non fingere l'atomicità).

