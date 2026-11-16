import 'package:flutter/material.dart';
import 'package:thenetherscrolls/data/character.dart';

// Finestra per scrivere/modificare. Restituisce null se annulli.
Future<CharacterEntry?> showEntryDialog(
  BuildContext context, {
  CharacterEntry? existing,
  required bool showQuantity,
}) {
  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  final descCtrl = TextEditingController(text: existing?.description ?? '');
  final qtyCtrl = TextEditingController(text: '${existing?.quantity ?? 1}');

  return showDialog<CharacterEntry>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(existing == null ? 'Nuovo' : 'Modifica'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Descrizione'),
              minLines: 2,
              maxLines: 6,
            ),
            if (showQuantity)
              TextField(
                controller: qtyCtrl,
                decoration: const InputDecoration(labelText: 'Quantità'),
                keyboardType: TextInputType.number,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () {
            final name = nameCtrl.text.trim();
            if (name.isEmpty) return; // il nome è obbligatorio
            Navigator.pop(
              ctx,
              CharacterEntry(
                name: name,
                description: descCtrl.text.trim(),
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

class EntriesTab extends StatefulWidget {
  final List<CharacterEntry> entries;
  final bool showQuantity;
  final String addLabel;
  final String emptyText;

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
  // Serve sia per aggiungere (existing = null) sia per modificare
  Future<void> _edit({CharacterEntry? existing}) async {
    final result = await showEntryDialog(
      context,
      existing: existing,
      showQuantity: widget.showQuantity,
    );
    if (result == null) return;

    setState(() {
      if (existing == null) {
        widget.entries.add(result);
      } else {
        existing.name = result.name;
        existing.description = result.description;
        existing.quantity = result.quantity;
      }
    });
  }

  void _delete(CharacterEntry entry) {
    setState(() => widget.entries.remove(entry));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        OutlinedButton.icon(
          onPressed: () => _edit(),
          icon: const Icon(Icons.add),
          label: Text(widget.addLabel),
        ),
        const SizedBox(height: 8),
        if (widget.entries.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(widget.emptyText, textAlign: TextAlign.center),
          ),
        ...widget.entries.map(
          (e) => Card(
            child: ListTile(
              title: Text(
                widget.showQuantity ? '${e.name}  ×${e.quantity}' : e.name,
              ),
              subtitle: e.description.isEmpty ? null : Text(e.description),
              onTap: () => _edit(existing: e), // tocca = modifica
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(e),
              ),
            ),
          ),
        ),
      ],
    );
  }
}