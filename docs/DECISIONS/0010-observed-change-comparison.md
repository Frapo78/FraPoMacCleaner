# ADR-0010 — Confronto read-only delle variazioni osservabili

**Stato:** accettata per alpha.13; non autorizza pulizie.  
**Data:** 2026-11-07.

## Contesto

La sola data di modifica o l'assenza di modifiche apparenti non dimostrano che file di log e artefatti Xcode siano inutilizzati. È utile però rilevare cambiamenti fra due osservazioni, soprattutto per cartelle di compilazione che possono ricevere nuovi file.

## Decisione

- Conservare soltanto nella sessione firme dei metadati POSIX degli elementi visitati: percorso relativo, coppia device/inode, tipo, owner, numero link, size, mtime e ctime.
- Confrontare due report della stessa area solo se entrambi completi e senza errori.
- Per Xcode confrontare tutti i metadati osservati dei file e delle sottocartelle di ogni gruppo; un figlio escluso rende il gruppo non qualificabile come vecchia build «da approfondire».
- Mostrare voci aggiunte, scomparse o cambiate senza affermare che quelle immutate siano inattive.
- Limitare la memoria al numero massimo di elementi visitati e non conservare/exportare firme su disco.
- Non introdurre API che spostano, eliminano o modificano file e servizi.

## Limiti

Le variazioni non rilevano file aperti se non cambiano metadati, né neutralizzano race TOCTOU. Due controlli non dimostrano che un oggetto sia eliminabile. Un piano di pulizia richiederà una nuova verifica, controlli sui processi nel limite dei permessi, approvazione per-app, conferma per-file e un coordinatore separato.
