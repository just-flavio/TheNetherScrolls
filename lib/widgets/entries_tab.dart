// ===== IMPORT =====
import 'package:flutter/material.dart'; // widget base di Flutter
import 'package:thenetherscrolls/data/character.dart'; // contiene CharacterEntry

// Questo file serve sia per gli OGGETTI sia per le PASSIVE:
// hanno gli stessi campi (nome + descrizione), quindi si scrive il codice una volta sola.
// Contiene:
//   1. showEntryDialog -> la finestra per scrivere/modificare una voce
//   2. EntriesTab      -> la lista con i pulsanti aggiungi/modifica/elimina

// ============ 1. FINESTRA DI SCRITTURA ============
// Restituisce la voce creata, oppure null se premi Annulla.
// "existing" = se lo passi, la finestra parte con i valori da modificare.
// "showQuantity" = mostra il campo Quantità (oggetti sì, passive no).
Future<CharacterEntry?> showEntryDialog(
  BuildContext context, {
  CharacterEntry? existing, // "?" = può essere null (nuova voce)
  required bool showQuantity,
}) {
  // Un controller per campo, già riempito con i valori attuali (se esistono).
  // "existing?.name ?? ''" = nome della voce, oppure testo vuoto se è nuova.
  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  final descCtrl = TextEditingController(text: existing?.description ?? '');
  final qtyCtrl = TextEditingController(text: '${existing?.quantity ?? 1}');

  return showDialog<CharacterEntry>(
    context: context,
    builder: (ctx) => AlertDialog(
      // Titolo diverso se stai creando o modificando
      title: Text(existing == null ? 'Nuovo' : 'Modifica'),
      // SingleChildScrollView = la finestra scorre se la tastiera occupa spazio
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // la finestra è alta quanto serve
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Descrizione'),
              minLines: 2, // altezza minima: 2 righe
              maxLines: 6, // poi scorre
            ),
            // "if" dentro una lista: il campo compare solo se showQuantity è true
            if (showQuantity)
              TextField(
                controller: qtyCtrl,
                decoration: const InputDecoration(labelText: 'Quantità'),
                keyboardType: TextInputType.number, // tastiera numerica
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx), // chiude restituendo null
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () {
            final name = nameCtrl.text.trim(); // trim() toglie spazi ai bordi
            if (name.isEmpty) return; // il nome è obbligatorio: non chiude
            // Chiude la finestra e restituisce la voce appena scritta
            Navigator.pop(
              ctx,
              CharacterEntry(
                name: name,
                description: descCtrl.text.trim(),
                // testo -> numero; se non è valido, usa 1
                quantity: int.tryParse(qtyCtrl.text) ?? 1,
              ),
            );
          },
          child: const Text('Salva'),
        ),
      ],
    ),
  );
}

// ============ 2. LISTA ============
class EntriesTab extends StatefulWidget {
  final List<CharacterEntry> entries; // la lista del personaggio (non una copia)
  final bool showQuantity; // true = oggetti, false = passive
  final String addLabel; // testo del pulsante, es. "Aggiungi oggetto"
  final String emptyText; // messaggio mostrato quando la lista è vuota

  const EntriesTab({
    super.key,
    required this.entries,
    required this.showQuantity,
    required this.addLabel,
    required this.emptyText,
  });

  @override
  State<EntriesTab> createState() => _EntriesTabState();
}

class _EntriesTabState extends State<EntriesTab> {
  // Serve sia per AGGIUNGERE (existing = null) sia per MODIFICARE
  Future<void> _edit({CharacterEntry? existing}) async {
    // Apro la finestra e aspetto che si chiuda
    final result = await showEntryDialog(
      context,
      existing: existing,
      showQuantity: widget.showQuantity,
    );
    if (result == null) return; // Annulla: non cambia nulla

    setState(() {
      if (existing == null) {
        widget.entries.add(result); // nuova voce: la aggiungo in fondo
      } else {
        // Modifica: aggiorno i campi della voce esistente
        existing.name = result.name;
        existing.description = result.description;
        existing.quantity = result.quantity;
      }
    });
  }

  // Toglie una voce dalla lista (subito, senza conferma)
  void _delete(CharacterEntry entry) {
    setState(() => widget.entries.remove(entry));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Pulsante "Aggiungi ..."
        OutlinedButton.icon(
          onPressed: () => _edit(), // senza "existing" = nuova voce
          icon: const Icon(Icons.add),
          label: Text(widget.addLabel),
        ),
        const SizedBox(height: 8),
        // Messaggio mostrato solo se la lista è vuota
        if (widget.entries.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(widget.emptyText, textAlign: TextAlign.center),
          ),
        // Una card per ogni voce ("..." inserisce tutti gli elementi qui)
        ...widget.entries.map(
          (entry) => Card(
            child: ListTile(
              // Per gli oggetti mostra anche la quantità, es. "Pozione ×3"
              title: Text(
                widget.showQuantity
                    ? '${entry.name}  ×${entry.quantity}'
                    : entry.name,
              ),
              // Se la descrizione è vuota non mostra il sottotitolo
              subtitle: entry.description.isEmpty
                  ? null
                  : Text(entry.description),
              onTap: () => _edit(existing: entry), // tocca = modifica
              // Cestino a destra
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(entry),
              ),
            ),
          ),
        ),
      ],
    );
  }
}