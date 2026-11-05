# Politica di distribuzione e versionamento

## Formato scelto

**ZIP contenente `FraPoMacCleaner.app` ARM64.** È un formato nativo, semplice da riprodurre con `ditto` e adatto alle release GitHub. Una versione futura potrà aggiungere un DMG solo se utile.

## Versioni e cambiamenti maggiori

Usiamo **Semantic Versioning**: `vMAJOR.MINOR.PATCH`, con prerelease `v0.1.0-alpha.1`, `v0.1.0-beta.1` o `v0.1.0-rc.1`.

**Ogni cambiamento significativo di funzionalità o architettura che raggiunge il ramo principale e viene dichiarato pronto per il rilascio deve produrre una nuova versione e una GitHub Release.** In pratica: incrementare `MARKETING_VERSION`, aggiornare `CHANGELOG.md`, creare e pubblicare un tag semantico. Il workflow `.github/workflows/release.yml` esegue build/test e pubblicazione in modo automatico. I semplici cambiamenti documentali non generano una release.

La pubblicazione avviene **solo dopo esito positivo** della pipeline. I tag non sostituiscono la revisione dei rischi e il test funzionale.

## Due livelli di distribuzione

| Canale | Trigger | Output | Requisiti |
| --- | --- | --- | --- |
| Sviluppo | Push su `main` e PR | Artefatto ZIP temporaneo associato al workflow | Build/test riusciti; nessuna firma distributiva |
| Prerelease | Tag `v*-alpha.*`, `v*-beta.*`, `v*-rc.*` | GitHub prerelease ZIP per test | Build/test riusciti; binario di sviluppo **non notarizzato** |
| Stabile | Tag `vX.Y.Z` | GitHub Release ZIP firmato e notarizzato | Build/test, Developer ID, notarytool, stapler e verifiche riuscite |

**Importante:** le prerelease non firmate per la distribuzione potrebbero essere bloccate da Gatekeeper. Non richiedere agli utenti finali di disabilitare protezioni per eseguirle. Le versioni stabili non vengono pubblicate se mancano le credenziali Apple necessarie.

## Segreti GitHub per release stabile

Configura nei **GitHub Actions repository secrets**, mai nel codice:

- `MACOS_CERT_P12_BASE64`: certificato **Developer ID Application** in formato P12 codificato base64.
- `MACOS_CERT_PASSWORD`: password del P12.
- `MACOS_SIGNING_IDENTITY`: nome esatto dell'identità certificato.
- `APPLE_ID`: account Apple per notarizzazione.
- `APPLE_APP_PASSWORD`: password specifica per l'app Apple.
- `APPLE_TEAM_ID`: Team ID per notarytool.

Non includere file `.p12`, chiavi o credenziali nel repository. Lo script di release importa il certificato **solo nel portachiavi temporaneo del runner**. Per versioni stabili la build usa hardened runtime e `codesign --timestamp`, poi notarizzazione con `xcrun notarytool`, `stapler` sulla `.app`, verifica e nuovo ZIP.

## Procedura del maintainer

1. Confermare milestone funzionale, test, analisi della sicurezza e numero di versione.
2. Aggiornare `MARKETING_VERSION` nei build settings e `CHANGELOG.md`.
3. Fare commit e verificare la CI del ramo principale.
4. Creare il tag che corrisponde alla versione, es. `git tag v0.2.0`.
5. Pubblicare con `git push origin v0.2.0`.
6. Controllare workflow Release, pagina Releases, checksum SHA-256 e installazione su Mac pulito.

Se la pipeline fallisce, **nessuna release valida è stata prodotta**. Non pubblicare manualmente un artefatto compilato male.

## Limite di questa fase

Il repository contiene ora solo lo scheletro dell'app; **non è una versione completa per uso quotidiano**. La prima release stabile sarà definita solo quando saranno completate e testate le funzionalità effettivamente previste per quel traguardo.
