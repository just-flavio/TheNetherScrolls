import 'package:flutter/material.dart';

class CharacterDraft {
  String name = '';
  String concept = '';
  String? race;
  String? characterClass;
  String? background;
  final int level = 1; 

  Map<String, int> baseStats = {
    'Forza': 10,
    'Destrezza': 10,
    'Costituzione': 10,
    'Intelligenza': 10,
    'Saggezza': 10,
    'Carisma': 10,
  };

  Set<String> startingItems = {};
}


const races = [
  'Umano', 'Elfo', 'Nano', 'Halfling', 'Dragonide',
  'Gnomo', 'Mezzelfo', 'Mezzorco', 'Tiefling',
];

const classes = [
  'Barbaro', 'Bardo', 'Chierico', 'Druido', 'Guerriero', 'Monaco',
  'Paladino', 'Ranger', 'Ladro', 'Stregone', 'Warlock', 'Mago',
];

const backgrounds = [
  'Accolito', 'Artigiano', 'Criminale', 'Eremita', 'Soldato',
  'Nobile', 'Sapiente', 'Marinaio', 'Ciarlatano', 'Intrattenitore',
];

const items = [
  'Spada lunga', 'Arco corto', 'Pugnale', 'Bastone',
  'Armatura di cuoio', 'Cotta di maglia', 'Scudo',
  'Zaino da esploratore', 'Kit da ladro', 'Libro degli incantesimi',
];


class AddnewCharacter extends StatefulWidget {
  const AddnewCharacter({super.key});

  @override
  State<AddnewCharacter> createState() => _AddnewCharacterState();
}

class _AddnewCharacterState extends State<AddnewCharacter> {
  final _formKey = GlobalKey<FormState>();
  final draft = CharacterDraft();

  // Modificatore D&D: (valore - 10) / 2 arrotondato per difetto
  int _modifier(int value) => ((value - 10) / 2).floor();

  String _modText(int value) {
    final m = _modifier(value);
    return m >= 0 ? '+$m' : '$m';
  }

  void _changeStat(String stat, int delta) {
    setState(() {
      draft.baseStats[stat] = (draft.baseStats[stat]! + delta).clamp(3, 18);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Qui trasformerai la bozza in un Character vero e lo salverai.
    // Poi torni alla pagina precedente:
    // Navigator.pop(context, draft);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Creato: ${draft.name}, ${draft.race} ${draft.characterClass} '
          '(livello ${draft.level})',
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );

  @override
  Widget build(BuildContext context) {
    // Niente MaterialApp qui: ci pensa main.dart
    return Scaffold(
      appBar: AppBar(title: const Text('Add new character')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---------- 1. NOME E CONCEPT ----------
            _sectionTitle('Nome e concept'),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Inserisci un nome' : null,
              onSaved: (v) => draft.name = v!.trim(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Concept (facoltativo)',
                hintText: 'Es. un ex soldato che cerca redenzione',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onSaved: (v) => draft.concept = v?.trim() ?? '',
            ),

            // ---------- 2. RAZZA ----------
            _sectionTitle('Razza'),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Scegli la razza',
                border: OutlineInputBorder(),
              ),
              initialValue: draft.race,
              items: races
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              validator: (v) => v == null ? 'Scegli una razza' : null,
              onChanged: (v) => setState(() => draft.race = v),
            ),

            // ---------- 3. CLASSE ----------
            _sectionTitle('Classe (livello 1)'),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Scegli la classe',
                border: OutlineInputBorder(),
              ),
              initialValue: draft.characterClass,
              items: classes
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              validator: (v) => v == null ? 'Scegli una classe' : null,
              onChanged: (v) => setState(() => draft.characterClass = v),
            ),

            // ---------- 4. CARATTERISTICHE ----------
            _sectionTitle('Caratteristiche'),
            ...draft.baseStats.entries.map((e) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(e.key)),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _changeStat(e.key, -1),
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${e.value}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _changeStat(e.key, 1),
                      ),
                      SizedBox(
                        width: 36,
                        child: Text(
                          _modText(e.value),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // ---------- 5. BACKGROUND ----------
            _sectionTitle('Background'),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Scegli il background',
                border: OutlineInputBorder(),
              ),
              initialValue: draft.background,
              items: backgrounds
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              validator: (v) => v == null ? 'Scegli un background' : null,
              onChanged: (v) => setState(() => draft.background = v),
            ),

            // ---------- 6. EQUIPAGGIAMENTO ----------
            _sectionTitle('Equipaggiamento iniziale'),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: items.map((item) {
                final selected = draft.startingItems.contains(item);
                return FilterChip(
                  label: Text(item),
                  selected: selected,
                  onSelected: (on) => setState(() {
                    on
                        ? draft.startingItems.add(item)
                        : draft.startingItems.remove(item);
                  }),
                );
              }).toList(),
            ),

            // ---------- 7. SALVA ----------
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _submit,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Crea personaggio'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
