# Politica di distribuzione e versionamento

## Formato scelto

**ZIP contenente `FraPoMacCleaner.app` ARM64.** È un formato nativo, semplice da riprodurre con `ditto` e adatto alle release GitHub. Una versione futura potrà aggiungere un DMG solo se utile.

## Versioni e cambiamenti maggiori

Il file radice **`RELEASE_VERSION`** è il marcatore di pubblicazione: quando viene modificato su `main`, GitHub Actions compila, esegue i test e crea automaticamente il tag e la release corrispondente. Non occorre creare manualmente il tag in questo flusso.

Usiamo **Semantic Versioning**: `vMAJOR.MINOR.PATCH`, con prerelease `v0.1.0-alpha.1`, `v0.1.0-beta.1` o `v0.1.0-rc.1`.

**Ogni cambiamento significativo di funzionalità o architettura che raggiunge il ramo principale e viene dichiarato pronto per il rilascio deve produrre una nuova versione e una GitHub Release.** In pratica: incrementare `MARKETING_VERSION`, aggiornare `CHANGELOG.md`, aggiornare il file `RELEASE_VERSION`. Il workflow `.github/workflows/release.yml` esegue build/test e pubblicazione in modo automatico. I semplici cambiamenti documentali non generano una release.

La pubblicazione avviene **solo dopo esito positivo** della pipeline: XCTest gira in configurazione **Debug** per assicurare la compilazione testabile, seguita da build applicazione in **Release** per il pacchetto ZIP. I tag non sostituiscono la revisione dei rischi e il test funzionale.

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
4. Aggiornare `RELEASE_VERSION` con il tag scelto (es. `v0.2.0`) **nello stesso commit** della modifica di versione e del changelog.
5. Pubblicare su `main`: il workflow crea tag, build ARM64 e GitHub Release, soltanto se tutti i controlli passano.
6. Controllare workflow Release, pagina Releases, checksum SHA-256 e installazione su Mac pulito.

Si può anche creare manualmente il tag o avviare `workflow_dispatch` indicando la versione presente in `RELEASE_VERSION`; il workflow blocca tag non corrispondenti al valore `MARKETING_VERSION` del progetto. Non ripubblicare tag già rilasciati.

Se la pipeline fallisce, **nessuna release valida è stata prodotta**. Non pubblicare manualmente un artefatto compilato male.

## Identità visiva e build

Le build includono l'asset catalog `AppIcon.appiconset` per l'icona del bundle e `BrandLogo.imageset` per il logo visualizzato nell'app. La CI e la pipeline release eseguono `scripts/check_brand_assets.sh` per prevenire sostituzioni con miniature ingrandite. Per verificare la dotazione della release, ispezionare `Contents/Resources/Assets.car` nel bundle e aprire l'applicazione sul Mac.

## Prima prerelease verificata

Il workflow [Release macOS ARM64 ZIP](https://github.com/Frapo78/FraPoMacCleaner/actions/runs/42025800237) ha completato compilazione, XCTest, ZIP e pubblicazione. Artefatto pubblicato: [v0.1.0-alpha.2](https://github.com/Frapo78/FraPoMacCleaner/releases/tag/v0.1.0-alpha.2). Il pacchetto è per test, non firmato né notarizzato e non comprende alcuna funzione di cancellazione.

## Limite di questa fase

Il repository contiene ora solo lo scheletro dell'app; **non è una versione completa per uso quotidiano**. La prima release stabile sarà definita solo quando saranno completate e testate le funzionalità effettivamente previste per quel traguardo.

## Build di sviluppo firmata con Apple Development

Il workflow separato [`development-sign.yml`](../.github/workflows/development-sign.yml) usa i secret `APPLE_DEVELOPMENT_P12_BASE64` e `APPLE_DEVELOPMENT_P12_PASSWORD` già configurati dal maintainer. Questo certificato è **Apple Development**, non Developer ID.

**Sicurezza:** il workflow si esegue soltanto sul branch `main`, mai su PR; esegue i test in **Debug**, poi compila un bundle **Release** privo di componenti XCTest e librerie di debug, **prima** di rendere disponibili i secret al passo di firma; importa la chiave in un Portachiavi temporaneo del runner; controlla `codesign`, Team ID e architettura ARM64; produce uno ZIP e un file SHA-256 tra gli artefatti della run, senza creare una GitHub Release pubblica. Il Portachiavi temporaneo viene eliminato anche in caso di errore.

Esecuzione manuale dal repository locale (richiede `gh auth login`):

```sh
gh workflow run development-sign.yml --ref main -R Frapo78/FraPoMacCleaner
gh run list --workflow development-sign.yml -R Frapo78/FraPoMacCleaner --limit 5
```

Per leggere lo stato e ottenere l'artefatto, identificare la run conclusa con successo:

```sh
gh run view RUN_ID -R Frapo78/FraPoMacCleaner
gh run download RUN_ID -R Frapo78/FraPoMacCleaner -n FraPoMacCleaner-AppleDevelopment-arm64
```

**Limiti:** la firma di sviluppo non conferisce un'autorizzazione per la distribuzione pubblica e non evita gli avvisi Gatekeeper sui Mac di altri utenti. Non fornisce notarizzazione. Le normali GitHub Releases continuano a seguire il workflow separato `release.yml` e richiedono un vero certificato Developer ID per la distribuzione stabile.

Il file `.p12` e la sua password non devono mai essere inclusi nella repository, nei log o nei file ZIP.
