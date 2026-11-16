import 'package:flutter/material.dart';
import 'package:thenetherscrolls/data/character.dart';

class NotesTab extends StatefulWidget {
  final CharacterSheet character;

  const NotesTab({super.key, required this.character});

  @override
  State<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _controller;

  // Tiene viva la tab quando cambi pagina
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Parte con le note già scritte del personaggio
    _controller = TextEditingController(text: widget.character.notes);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // richiesto da AutomaticKeepAliveClientMixin
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        // a ogni modifica, aggiorna il personaggio
        onChanged: (text) => widget.character.notes = text,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: const InputDecoration(
          hintText: 'Note, missioni, PNG incontrati...',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}