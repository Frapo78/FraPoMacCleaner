# ADR-0002 — Pulizia conservativa, esplicita, verso il Cestino

- **Stato:** adottata come requisito di prodotto
- **Data:** 2026-11-05

## Contesto

Un errore di classificazione può eliminare dati importanti. Una scansione non autorizza l'eliminazione: i file possono cambiare dopo la rilevazione.

## Decisione

La scansione è read-only. Le selezioni sono inizialmente vuote. Policy e scope proteggono candidati incerti; un preflight rivalida ogni file immediatamente prima dell'operazione. Nel MVP usare solo lo **spostamento nel Cestino** tramite API native, senza fallback distruttivi e senza svuotamento del Cestino.

## Alternative considerate

Rimozione permanente per liberare subito spazio (respinta nel MVP); pulizia in un click di tutto il sistema (respinta); helper root (respinto nel MVP).

## Conseguenze

Più passaggi UI e spazio non immediatamente recuperato, in cambio di maggior controllo e rischio ridotto. Il Cestino non è una transazione né garanzia assoluta di ripristino; ogni esito è registrato per elemento. Vedere `docs/SAFETY.md`.

