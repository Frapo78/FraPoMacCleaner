# Identità visiva

## Brand

Il logo orizzontale e l'icona di FraPoMacCleaner utilizzano un segno grafico **FP**, sfumature blu e argento e un simbolo di pulizia. L'identità è originale e distinta da qualsiasi altro prodotto.

## Risorse native

- `FraPoMacCleaner/Resources/Assets.xcassets/BrandLogo.imageset/brand-logo.png`: logo orizzontale usato nell'interfaccia SwiftUI tramite `Image("BrandLogo")`.
- `FraPoMacCleaner/Resources/Assets.xcassets/AppIcon.appiconset/`: icona dell'app con varianti da 16 a 1024 pixel configurate in Xcode.
- `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon` abilita l'icona per il bundle macOS.

Dalla **v0.1.0-alpha.4** sono integrati gli originali verificati, senza alcun ingrandimento di miniature:

- Logo orizzontale trasparente: **1460×285 px**, SHA-256 `5538179542dfaf2f4aa13bc50b9456e9d4fe9a0530ce25e703d7b0ac6337cb82`.
- Icona principale: **1024×1024 px**, SHA-256 `db8b77d6cf1dbfddb044c71e055c4ce68dcc126ed0d7bde25c8467f574602231`.
- Varianti 16, 32, 64, 128, 256 e 512 px derivate dall'originale con riduzione.
- `scripts/check_brand_assets.sh` verifica in CI e release l'identità degli originali e le dimensioni delle varianti.

Sono immagini raster HD: per aumenti illimitati di dimensioni servirebbe una versione vettoriale, non ancora disponibile.

## Regole

- Non introdurre asset di terzi o loghi simili a quelli di altre applicazioni.
- L'icona deve restare riconoscibile anche a 16–32 px.
- L'interfaccia deve funzionare sia in tema chiaro sia in tema scuro e offrire etichette accessibili.
- Ogni aggiornamento all'icona deve essere seguito da test di compilazione e da una nuova prerelease.

## Controllo

In Xcode aprire `Assets.xcassets` e verificare `AppIcon` e `BrandLogo`. In fase di rilascio verificare che `FraPoMacCleaner.app/Contents/Resources/Assets.car` sia presente.
