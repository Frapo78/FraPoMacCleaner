# Identità visiva

## Brand

Il logo orizzontale e l'icona di FraPoMacCleaner utilizzano un segno grafico **FP**, sfumature blu e argento e un simbolo di pulizia. L'identità è originale e distinta da qualsiasi altro prodotto.

## Risorse native

- `FraPoMacCleaner/Resources/Assets.xcassets/BrandLogo.imageset/brand-logo.png`: logo orizzontale usato nell'interfaccia SwiftUI tramite `Image("BrandLogo")`.
- `FraPoMacCleaner/Resources/Assets.xcassets/AppIcon.appiconset/`: icona dell'app con varianti da 16 a 1024 pixel configurate in Xcode.
- `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon` abilita l'icona per il bundle macOS.

Le immagini integrate sono state ricostruite a partire da versioni ridotte del materiale grafico preparato per il progetto. Le dimensioni dei PNG sono quelle richieste dall'asset catalog, ma la nitidezza delle varianti più grandi non corrisponde ancora a quella dei sorgenti originali. **Sostituire i PNG con gli originali ad alta risoluzione appena disponibile un trasferimento binario diretto verso GitHub.** Conservare nomi e contenuto dei manifest.

## Regole

- Non introdurre asset di terzi o loghi simili a quelli di altre applicazioni.
- L'icona deve restare riconoscibile anche a 16–32 px.
- L'interfaccia deve funzionare sia in tema chiaro sia in tema scuro e offrire etichette accessibili.
- Ogni aggiornamento all'icona deve essere seguito da test di compilazione e da una nuova prerelease.

## Controllo

In Xcode aprire `Assets.xcassets` e verificare `AppIcon` e `BrandLogo`. In fase di rilascio verificare che `FraPoMacCleaner.app/Contents/Resources/Assets.car` sia presente.
