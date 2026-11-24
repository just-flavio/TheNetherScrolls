# The Nether Scrolls

App Flutter per gestire le schede personaggio di D&D 5e in locale.

## Idea
Creare personaggi, consultare la scheda (caratteristiche, PF, competenze,
oggetti, passive, note), cercare incantesimi da un'API e lanciare dadi con modificatore.

## API usata
D&D 5e API (pubblica, senza chiave): https://www.dnd5eapi.co
- `GET /api/2014/spells`: lista degli incantesimi (ricerca)
- `GET /api/2014/spells/{index}`: dettaglio di un incantesimo

Gestiti: caricamento (spinner), errore con pulsante "Riprova", timeout di 10 secondi.

## Funzionalità
- Schermate: Home, creazione personaggio, scheda (5 tab), ricerca e dettaglio incantesimi, dadi
- Tema chiaro/scuro (salvato con shared_preferences)
- Form con validatori nella creazione del personaggio
- Salvataggio locale con sqflite (solo Android/iOS)

## Note
- Il database sqflite non funziona su web: su Chrome i dati restano in memoria.
- Possibili miglioramenti: cache degli incantesimi su disco, slot incantesimo, multiclasse completo.