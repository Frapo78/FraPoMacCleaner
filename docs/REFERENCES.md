# Riferimenti tecnici autorevoli

Collezione iniziale di API pubbliche Apple, da ricontrollare quando inizia il codice. **La disponibilità dell'API non implica che l'app abbia i permessi per usarla su qualunque percorso.**

- [Apple — FileManager.trashItem(at:resultingItemURL:)](https://developer.apple.com/documentation/foundation/filemanager/trashitem(at:resultingitemurl:)): spostamento nel Cestino, con percorso destinazione restituito se disponibile.
- [Apple — Accessing files from the macOS App Sandbox](https://developer.apple.com/documentation/security/accessing-files-from-the-macos-app-sandbox): pannelli di selezione e security-scoped bookmark.
- [Apple — SMAppService](https://developer.apple.com/documentation/servicemanagement/smappservice): gestione dei **propri** helper/login item tramite API supportate; non è un'API universale per controllare tutti i login item di terze parti.
- [Apple — URLResourceKey.fileResourceIdentifierKey](https://developer.apple.com/documentation/foundation/urlresourcekey/fileresourceidentifierkey): identità della risorsa utile per confronti, **non persistente in modo garantito attraverso riavvii**.
- [Apple — App Sandbox](https://developer.apple.com/documentation/security/app-sandbox): limiti di accesso e autorizzazioni.

## Verifiche aperte

1. Compatibilità esatta API con la versione minima macOS scelta.
2. Modalità affidabili di verificare oggetti/file durante l'operazione per contenere le race TOCTOU.
3. Test APFS su hard link, clone, snapshot, dimensione logica e dimensione allocata.
4. Implicazioni della distribuzione diretta, firma, notarizzazione e TCC.
5. Privacy delle informazioni presentate nei report e negli OSLog.

Nessun riferimento qui va interpretato come autorizzazione a usare API private o a scavalcare le protezioni del sistema.
