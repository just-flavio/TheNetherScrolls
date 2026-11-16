import 'package:flutter/material.dart';
import 'package:thenetherscrolls/data/character.dart';
import 'package:thenetherscrolls/data/DnDData.dart';
import 'package:thenetherscrolls/data/DnDMath.dart';

// Un'icona possibile per il personaggio
class _IconOption {
  final IconData icon;
  final Color color;
  const _IconOption(this.icon, this.color);
}

const List<_IconOption> _iconOptions = [
  _IconOption(Icons.shield, Colors.blue),
  _IconOption(Icons.local_fire_department, Colors.red),
  _IconOption(Icons.bolt, Colors.orange),
  _IconOption(Icons.forest, Colors.green),
  _IconOption(Icons.auto_fix_high, Colors.purple),
  _IconOption(Icons.pets, Colors.brown),
];

class AddnewCharacter extends StatefulWidget {
  const AddnewCharacter({super.key});

  @override
  State<AddnewCharacter> createState() => _AddnewCharacterState();
}

class _AddnewCharacterState extends State<AddnewCharacter> {
  final _formKey = GlobalKey<FormState>();

  // Un controller per ogni campo di testo: serve a leggere cosa hai scritto
  final _nameCtrl = TextEditingController();
  final _raceCtrl = TextEditingController();
  final _classCtrl = TextEditingController();
  final _levelCtrl = TextEditingController(text: '1');
  final _hpCtrl = TextEditingController(text: '10');
  final _acCtrl = TextEditingController(text: '10');
  final _speedCtrl = TextEditingController(text: '30');

  // Le 6 caratteristiche, tutte a 10 all'inizio: {'FOR': 10, 'DES': 10, ...}
  final Map<String, int> _scores = {
    for (final key in abilityNames.keys) key: 10,
  };

  int _iconIndex = 0;

  @override
  void dispose() {
    // Libera la memoria dei controller quando la pagina si chiude
    _nameCtrl.dispose();
    _raceCtrl.dispose();
    _classCtrl.dispose();
    _levelCtrl.dispose();
    _hpCtrl.dispose();
    _acCtrl.dispose();
    _speedCtrl.dispose();
    super.dispose();
  }

  // Controlla che il testo sia un numero tra min e max
  String? Function(String?) _intValidator(int min, int max) {
    return (value) {
      final n = int.tryParse(value ?? '');
      if (n == null) return 'Numero?';
      if (n < min || n > max) return '$min-$max';
      return null; // null = va bene
    };
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Obbligatorio';
    return null;
  }

  void _changeScore(String key, int delta) {
    setState(() {
      _scores[key] = (_scores[key]! + delta).clamp(1, 30);
    });
  }

  void _save() {
    // Se un campo non è valido, si ferma e mostra gli errori in rosso
    if (!_formKey.currentState!.validate()) return;

    final option = _iconOptions[_iconIndex];

    final newCharacter = CharacterSheet(
      characterIcon: Icon(option.icon, color: option.color),
      characterName: _nameCtrl.text.trim(),
      race: _raceCtrl.text.trim(),
      classes: [
        CharacterClass(
          name: _classCtrl.text.trim(),
          level: int.parse(_levelCtrl.text),
        ),
      ],
      strength: _scores['FOR']!,
      dexterity: _scores['DES']!,
      constitution: _scores['COS']!,
      intelligence: _scores['INT']!,
      wisdom: _scores['SAG']!,
      charisma: _scores['CAR']!,
      maxHp: int.parse(_hpCtrl.text), // currentHp parte uguale a maxHp
      armorClass: int.parse(_acCtrl.text),
      speed: int.parse(_speedCtrl.text),
    );

    characters.add(newCharacter); // la lista globale della Home
    Navigator.pop(context); // torna indietro
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuovo personaggio')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('Informazioni base'),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome',
                hintText: 'Es. Thorin',
              ),
              textCapitalization: TextCapitalization.words,
              validator: _requiredValidator,
            ),
            TextFormField(
              controller: _raceCtrl,
              decoration: const InputDecoration(
                labelText: 'Razza',
                hintText: 'Es. Nano',
              ),
              textCapitalization: TextCapitalization.words,
              validator: _requiredValidator,
            ),
            TextFormField(
              controller: _classCtrl,
              decoration: const InputDecoration(
                labelText: 'Classe',
                hintText: 'Es. Guerriero',
              ),
              textCapitalization: TextCapitalization.words,
              validator: _requiredValidator,
            ),
            TextFormField(
              controller: _levelCtrl,
              decoration: const InputDecoration(labelText: 'Livello (1-20)'),
              keyboardType: TextInputType.number,
              validator: _intValidator(1, 20),
            ),
            const SizedBox(height: 16),
            const Text('Icona'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (int i = 0; i < _iconOptions.length; i++)
                  ChoiceChip(
                    label: Icon(
                      _iconOptions[i].icon,
                      color: _iconOptions[i].color,
                    ),
                    selected: _iconIndex == i,
                    onSelected: (_) => setState(() => _iconIndex = i),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            _sectionTitle('Caratteristiche'),
            ...abilityNames.keys.map(
              (key) => _AbilityStepper(
                abbreviation: key,
                name: abilityNames[key]!,
                score: _scores[key]!,
                onMinus: () => _changeScore(key, -1),
                onPlus: () => _changeScore(key, 1),
              ),
            ),
            const SizedBox(height: 24),

            _sectionTitle('Combattimento'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _hpCtrl,
                    decoration: const InputDecoration(labelText: 'PF max'),
                    keyboardType: TextInputType.number,
                    validator: _intValidator(1, 999),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _acCtrl,
                    decoration: const InputDecoration(labelText: 'CA'),
                    keyboardType: TextInputType.number,
                    validator: _intValidator(1, 40),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _speedCtrl,
                    decoration: const InputDecoration(labelText: 'Velocità'),
                    keyboardType: TextInputType.number,
                    validator: _intValidator(0, 200),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Crea personaggio'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

// Riga caratteristica: FOR  Forza   [-]  16  (+3)  [+]
class _AbilityStepper extends StatelessWidget {
  final String abbreviation;
  final String name;
  final int score;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _AbilityStepper({
    required this.abbreviation,
    required this.name,
    required this.score,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 44,
          child: Text(
            abbreviation,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(name)),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: onMinus,
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$score',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: onPlus,
        ),
        SizedBox(
          width: 40,
          child: Text(
            '(${signed(modifier(score))})',
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}