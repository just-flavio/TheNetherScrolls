// ===== IMPORT =====
import 'package:flutter/material.dart'; // widget base di Flutter
import 'package:thenetherscrolls/data/character.dart'; // contiene CharacterSheet (e il campo "notes")

// Tab "Note": un unico campo di testo grande, collegato al personaggio.
// Il testo vive dentro il personaggio (character.notes), quindi ogni
// personaggio ha le sue note.
class NotesTab extends StatefulWidget {
  final CharacterSheet character; // il personaggio vero (non una copia)

  const NotesTab({super.key, required this.character});

  @override
  State<NotesTab> createState() => _NotesTabState();
}

// "with AutomaticKeepAliveClientMixin" = aggiunge la capacità di restare
// in memoria quando cambi tab (vedi wantKeepAlive qui sotto)
class _NotesTabState extends State<NotesTab>
    with AutomaticKeepAliveClientMixin {
  // Controller: legge e scrive il testo del campo da codice.
  // "late final" = lo assegno in initState, una volta sola.
  late final TextEditingController _controller;

  // true = la tab NON viene distrutta quando passi a un'altra tab.
  // Senza, perderesti il cursore e la posizione dello scorrimento.
  @override
  bool get wantKeepAlive => true;

  // initState parte UNA volta, quando la tab viene creata
  @override
  void initState() {
    super.initState();
    // Il campo parte già con le note salvate del personaggio
    _controller = TextEditingController(text: widget.character.notes);
  }

  // dispose() parte quando la tab si chiude: libera la memoria del controller
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // obbligatorio con AutomaticKeepAliveClientMixin
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        // A ogni lettera scritta, copio il testo dentro il personaggio.
        // Così, quando si salva il personaggio, le note vengono salvate con lui.
        onChanged: (text) => widget.character.notes = text,
        maxLines: null, // righe illimitate
        expands: true, // il campo riempie tutto lo spazio disponibile
        textAlignVertical: TextAlignVertical.top, // il testo parte dall'alto
        decoration: const InputDecoration(
          hintText: 'Note, missioni, PNG incontrati...', // testo grigio quando è vuoto
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}