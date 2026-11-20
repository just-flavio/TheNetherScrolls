// ===== IMPORT =====
import 'package:thenetherscrolls/services/database_service.dart'; // salvataggio su disco
import 'package:flutter/material.dart'; // widget base di Flutter
import 'package:thenetherscrolls/data/character.dart'; // CharacterSheet, characters, characterIconOptions
import 'package:thenetherscrolls/data/DnDData.dart'; // abilityNames (sigle e nomi)
import 'package:thenetherscrolls/data/DnDMath.dart'; // modifier() e signed()

// (Le icone ora stanno in character.dart come "characterIconOptions":
//  qui non vanno più duplicate)

// Pagina di creazione. StatefulWidget perché i valori cambiano mentre compili.
class AddnewCharacter extends StatefulWidget {
  const AddnewCharacter({super.key});

  @override
  State<AddnewCharacter> createState() => _AddnewCharacterState();
}

class _AddnewCharacterState extends State<AddnewCharacter> {
  // Chiave del Form: serve a lanciare la validazione (campi vuoti, numeri errati)
  final _formKey = GlobalKey<FormState>();

  // Un controller per ogni campo di testo: serve a leggere cosa hai scritto.
  // Il "text:" è il valore iniziale.
  final _nameCtrl = TextEditingController();
  final _raceCtrl = TextEditingController();
  final _classCtrl = TextEditingController();
  final _levelCtrl = TextEditingController(text: '1');
  final _hpCtrl = TextEditingController(text: '10');
  final _acCtrl = TextEditingController(text: '10');
  final _speedCtrl = TextEditingController(text: '30');

  // Le 6 caratteristiche, tutte a 10 all'inizio: {'FOR': 10, 'DES': 10, ...}
  // "for (...) key: 10" costruisce la mappa partendo dalle sigle di abilityNames
  final Map<String, int> _scores = {
    for (final key in abilityNames.keys) key: 10,
  };

  int _iconIndex = 0; // posizione dell'icona scelta in characterIconOptions

  // dispose() parte quando la pagina si chiude: libera la memoria dei controller
  @override
  void dispose() {
    _nameCtrl.dispose();
    _raceCtrl.dispose();
    _classCtrl.dispose();
    _levelCtrl.dispose();
    _hpCtrl.dispose();
    _acCtrl.dispose();
    _speedCtrl.dispose();
    super.dispose();
  }

  // Crea una funzione di controllo: il testo deve essere un numero tra min e max.
  // Restituisce un messaggio di errore, oppure null se va bene.
  String? Function(String?) _intValidator(int min, int max) {
    return (value) {
      final n = int.tryParse(value ?? ''); // testo -> numero (null se non valido)
      if (n == null) return 'Numero?';
      if (n < min || n > max) return '$min-$max';
      return null; // null = va bene
    };
  }

  // Controllo per i campi di testo obbligatori (nome, razza, classe)
  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Obbligatorio';
    return null;
  }

  // Cambia una caratteristica di delta (+1 o -1), tra 1 e 30
  void _changeScore(String key, int delta) {
    setState(() {
      _scores[key] = (_scores[key]! + delta).clamp(1, 30);
    });
  }

  // Crea il personaggio e lo salva
  Future<void> _save() async {
    // validate() controlla tutti i campi: se uno è sbagliato mostra l'errore e ci fermiamo
    if (!_formKey.currentState!.validate()) return;

    // Costruisco il personaggio con i valori letti dai campi
    final newCharacter = CharacterSheet(
      iconIndex: _iconIndex,
      characterName: _nameCtrl.text.trim(), // trim() toglie spazi ai bordi
      race: _raceCtrl.text.trim(),
      classes: [
        CharacterClass(
          name: _classCtrl.text.trim(),
          level: int.parse(_levelCtrl.text), // sicuro: già validato
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

    // await = aspetto che sia scritto su disco.
    // Serve perché insertCharacter assegna l'id al personaggio.
    await DatabaseService.insertCharacter(newCharacter);
    characters.add(newCharacter); // aggiungo alla lista in memoria (usata dalla Home)

    if (!mounted) return; // la pagina è ancora aperta? (obbligatorio dopo un await)
    Navigator.pop(context); // torna alla Home
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuovo personaggio')),
      // Form + validator = controllo dei campi in un punto solo
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ===== BLOCCO 1: informazioni base =====
            _sectionTitle('Informazioni base'),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome',
                hintText: 'Es. Thorin',
              ),
              textCapitalization: TextCapitalization.words, // maiuscola a ogni parola
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

            // ===== BLOCCO 2: scelta dell'icona =====
            const Text('Icona'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                // Un ChoiceChip per ogni icona disponibile
                for (int i = 0; i < characterIconOptions.length; i++)
                  ChoiceChip(
                    label: Icon(
                      characterIconOptions[i].icon,
                      color: characterIconOptions[i].color,
                    ),
                    selected: _iconIndex == i, // evidenziata se è quella scelta
                    onSelected: (_) => setState(() => _iconIndex = i),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // ===== BLOCCO 3: le 6 caratteristiche =====
            _sectionTitle('Caratteristiche'),
            // "..." inserisce tutte le righe nella lista; una per sigla (FOR, DES...)
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

            // ===== BLOCCO 4: combattimento (PF, CA, velocità) =====
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

            // ===== PULSANTE FINALE =====
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

  // Titolo di sezione (es. "Caratteristiche"), riusato più volte
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

// Riga caratteristica: FOR  Forza   [-]  16  (+3)  [+]
class _AbilityStepper extends StatelessWidget {
  final String abbreviation; // sigla, es. "FOR"
  final String name; // nome completo, es. "Forza"
  final int score; // valore attuale
  final VoidCallback onMinus; // cosa fare premendo "-"
  final VoidCallback onPlus; // cosa fare premendo "+"

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
        // Sigla in grassetto, larghezza fissa per tenere le righe allineate
        SizedBox(
          width: 44,
          child: Text(
            abbreviation,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(name)), // occupa lo spazio rimasto
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
        // Modificatore col segno, es. "(+3)"
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