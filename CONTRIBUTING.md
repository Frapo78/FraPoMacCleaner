# Contribuire a FraPoMacCleaner

Il progetto è in **fase di progettazione**. Al momento il contributo più utile è migliorare specifiche, threat model, esperienza utente e criteri di test, non proporre funzioni di «pulizia aggressiva».

## Prima di contribuire

1. Leggi `README.md` e `AGENTS.md`.
2. Consulta `docs/SECURITY.md` e `docs/ARCHITECTURE.md`.
3. Per scelte strutturali, apri una proposta (Issue o ADR) con alternative, rischi e motivazioni.
4. Mantieni le PR piccole e focalizzate; spiega cosa cambia e cosa **non** cambia.

## Criteri per accettare una modifica

- Non aumenta i rischi di perdita dei dati.
- Rispetta permessi e meccanismi di sicurezza macOS.
- Espone limiti e casi ambigui, senza presentarli come risolti.
- Non porta dipendenze pesanti o strumenti proprietari senza giustificazione.
- Ha test e documentazione coerenti quando arriverà il codice.

## Segnalazioni di problemi

Indica versione macOS, architettura, operazione eseguita, risultato atteso/ottenuto e passaggi riproducibili. **Oscura sempre username, percorsi personali, nomi dei file, token e dati sensibili** da log e screenshot.

Le segnalazioni di vulnerabilità o rischio di cancellazione dovranno essere gestite senza pubblicare dati personali o istruzioni di sfruttamento sui dati altrui; concordare prima un canale riservato con il maintainer se necessario.

## Licenza

I contributi devono essere compatibili con la licenza presente nel repository (`LICENSE`, GPL-3.0). Nessuna dipendenza con licenza incompatibile senza previa verifica.
