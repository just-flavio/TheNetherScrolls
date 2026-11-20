// ===== IMPORT: codice preso da altri file =====
import 'package:flutter/material.dart'; // widget base di Flutter
import 'package:thenetherscrolls/data/character.dart'; // modello CharacterSheet e lista "characters"
import 'package:thenetherscrolls/data/DnDData.dart'; // nomi delle caratteristiche e lista abilità
import 'package:thenetherscrolls/data/DnDMath.dart'; // modifier(), proficiencyBonus(), signed()
import 'package:thenetherscrolls/widgets/entries_tab.dart'; // tab Oggetti e Passive
import 'package:thenetherscrolls/widgets/notes_tab.dart'; // tab Note
import 'package:thenetherscrolls/screens/spells_tab.dart'; // tab Incantesimi

// La pagina "scheda personaggio".
// È StatefulWidget perché i valori cambiano mentre la guardi (PF, competenze...).
class CharacterDetails extends StatefulWidget {
  final CharacterSheet character; // il personaggio da mostrare, passato dalla Home

  const CharacterDetails({super.key, required this.character});

  @override
  State<CharacterDetails> createState() => _CharacterDetailsState();
}

// Lo stato della pagina: dati che cambiano e funzioni che li modificano
class _CharacterDetailsState extends State<CharacterDetails> {
  // Scorciatoia: scrivo "c" invece di "widget.character" ovunque
  CharacterSheet get c => widget.character;

  // Controller del campo "Quantità" (danno/cura): serve a leggere cosa hai scritto
  final _amountCtrl = TextEditingController();

  // dispose() parte quando la pagina si chiude: libera la memoria del controller
  @override
  void dispose() {
    // DatabaseService.updateCharacter(c); // da attivare col database: salva uscendo
    _amountCtrl.dispose();
    super.dispose();
  }

  // Bonus competenza in base al livello totale (es. Lv 5 -> +3)
  int get prof => proficiencyBonus(c.characterLevel);

  // Cambia i PF di "delta" (negativo = danno, positivo = cura)
  void _changeHp(int delta) {
    setState(() {
      // clamp = tiene il valore tra 0 e il massimo
      c.currentHp = (c.currentHp + delta).clamp(0, c.maxHp);
    });
    // DatabaseService.updateCharacter(c); // da attivare col database
  }

  // Applica la quantità scritta nel campo. sign = -1 danno, +1 cura
  void _applyAmount(int sign) {
    final n = int.tryParse(_amountCtrl.text); // testo -> numero (null se non valido)
    if (n == null || n <= 0) return; // vuoto o non valido: non fa nulla
    _changeHp(sign * n); // es. -1 * 37 = -37
    _amountCtrl.clear(); // svuota il campo
    FocusScope.of(context).unfocus(); // chiude la tastiera
  }

  // Aggiunge o toglie una voce da un Set (competenza sì/no)
  void _toggle(Set<String> set, String key, bool value) {
    setState(() {
      if (value) {
        set.add(key); // spunta: ha competenza
      } else {
        set.remove(key); // tolta la spunta
      }
    });
    // DatabaseService.updateCharacter(c); // da attivare col database
  }

  // Apre la finestra "Modifica statistiche" (PF max, CA, velocità)
  Future<void> _edit() async {
    final saved = await showEditCharacterDialog(context, c); // true se premi Salva
    if (!saved) return; // Annulla: non cambia nulla
    setState(() {}); // ridisegna la scheda coi nuovi valori
    // DatabaseService.updateCharacter(c); // da attivare col database
  }

  // Apre la finestra "Classi e livelli"
  Future<void> _editClasses() async {
    final saved = await showClassesDialog(context, c);
    if (!saved) return;
    setState(() {}); // ridisegna livello e competenza
    // DatabaseService.updateCharacter(c);
  }

  // Chiede conferma, poi elimina il personaggio
  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Eliminare ${c.characterName}?'),
        content: const Text('Non si può annullare.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), // chiude con "no"
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true), // chiude con "sì"
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (ok != true) return; // non ha confermato

    // await DatabaseService.deleteCharacter(c); // da attivare col database
    characters.remove(c); // toglie dalla lista in memoria
    if (!mounted) return; // la pagina è ancora aperta? (serve dopo un await)
    Navigator.pop(context); // torna alla Home
  }

  // Finestra per cambiare il valore di una caratteristica (key = 'FOR', 'DES'...)
  Future<void> _editAbility(String key) async {
    final ctrl = TextEditingController(text: '${c.scoreOf(key)}'); // parte dal valore attuale

    final newValue = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(abilityNames[key]!), // nome completo, es. "Forza"
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true, // tastiera subito aperta
          decoration: const InputDecoration(labelText: 'Valore (1-30)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // restituisce null
            child: const Text('Annulla'),
          ),
          FilledButton(
            // restituisce il numero scritto (o null se non valido)
            onPressed: () => Navigator.pop(ctx, int.tryParse(ctrl.text)),
            child: const Text('Salva'),
          ),
        ],
      ),
    );
    if (newValue == null) return; // annullato o non valido

    // setScore scrive il valore nella caratteristica giusta; clamp lo tiene tra 1 e 30
    setState(() => c.setScore(key, newValue.clamp(1, 30)));
    // DatabaseService.updateCharacter(c);
  }

  // build() disegna la pagina; viene richiamato a ogni setState
  @override
  Widget build(BuildContext context) {
    // DefaultTabController gestisce le tab (5 in totale)
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(c.characterName),
          // Pulsanti a destra nella barra
          actions: [
            IconButton(
              icon: const Icon(Icons.trending_up),
              tooltip: 'Classi e livelli',
              onPressed: _editClasses,
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Modifica statistiche',
              onPressed: _edit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Elimina',
              onPressed: _confirmDelete,
            ),
          ],
          // Le etichette delle tab, sotto il titolo
          bottom: const TabBar(
            isScrollable: true, // con 5 tab servono a scorrere
            tabs: [
              Tab(text: 'Scheda'),
              Tab(text: 'Oggetti'),
              Tab(text: 'Incantesimi'),
              Tab(text: 'Passive'),
              Tab(text: 'Note'),
            ],
          ),
        ),
        // Il contenuto: un widget per ogni tab, nello STESSO ORDINE delle etichette
        body: TabBarView(
          children: [
            _buildSheetTab(), // 1. Scheda
            EntriesTab( // 2. Oggetti
              entries: c.items,
              showQuantity: true,
              addLabel: 'Aggiungi oggetto',
              emptyText: 'Nessun oggetto. Aggiungi spade, pozioni, monete...',
            ),
            SpellsTab(spells: c.spells), // 3. Incantesimi
            EntriesTab( // 4. Passive
              entries: c.passives,
              showQuantity: false,
              addLabel: 'Aggiungi passiva',
              emptyText: 'Nessuna passiva. Aggiungi tratti di razza e classe.',
            ),
            NotesTab(character: c), // 5. Note
          ],
        ),
      ),
    );
  }

  // Contenuto della prima tab: i blocchi della scheda, uno sotto l'altro
  Widget _buildSheetTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(),
        const SizedBox(height: 16), // spazio vuoto tra i blocchi
        _buildHpCard(),
        const SizedBox(height: 16),
        _buildCombatRow(),
        const SizedBox(height: 16),
        _buildAbilities(),
        const SizedBox(height: 16),
        _buildSavingThrows(),
        const SizedBox(height: 16),
        _buildSkills(),
        const SizedBox(height: 16),
      ],
    );
  }

  // --- BLOCCO 1: intestazione (icona, nome, razza, classi, livello) ---
  Widget _buildHeader() {
    return Column(
      children: [
        c.characterIcon,
        const SizedBox(height: 8),
        Text(c.characterName, style: Theme.of(context).textTheme.headlineSmall),
        Text('${c.race} • ${c.characterClass} • Lv ${c.characterLevel}'),
      ],
    );
  }

  // --- BLOCCO 2: punti ferita ---
  Widget _buildHpCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text('PUNTI FERITA'),
            const SizedBox(height: 4),
            // Es. "103 / 140"
            Text(
              '${c.currentHp} / ${c.maxHp}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            // Riga con i 4 pulsanti rapidi
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _HpButton(label: '-5', onPressed: () => _changeHp(-5)),
                _HpButton(label: '-1', onPressed: () => _changeHp(-1)),
                _HpButton(label: '+1', onPressed: () => _changeHp(1)),
                _HpButton(label: '+5', onPressed: () => _changeHp(5)),
              ],
            ),
            const SizedBox(height: 12),
            // Riga per danno/cura di una quantità esatta
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantità',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _applyAmount(-1), // danno
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Danno'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _applyAmount(1), // cura
                  style: FilledButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Cura'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- BLOCCO 3: CA, iniziativa, velocità, competenza, percezione passiva ---
  Widget _buildCombatRow() {
    // Percezione passiva = 10 + bonus dell'abilità Percezione
    final perceptionBonus = _skillBonus(const SkillInfo('Percezione', 'SAG'));

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatBox(label: 'CA', value: '${c.armorClass}'),
            ),
            Expanded(
              child: _StatBox(
                label: 'Iniziativa',
                // iniziativa = modificatore di Destrezza
                value: signed(modifier(c.dexterity)),
              ),
            ),
            Expanded(
              child: _StatBox(label: 'Velocità', value: '${c.speed}'),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _StatBox(label: 'Competenza', value: signed(prof)),
            ),
            Expanded(
              child: _StatBox(
                label: 'Percezione passiva',
                value: '${10 + perceptionBonus}',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- BLOCCO 4: le 6 caratteristiche, in griglia 3 x 2 ---
  Widget _buildAbilities() {
    return GridView.count(
      crossAxisCount: 3, // 3 colonne
      shrinkWrap: true, // la griglia occupa solo lo spazio che serve
      physics: const NeverScrollableScrollPhysics(), // scorre la pagina, non la griglia
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      // Per ogni sigla (FOR, DES...) crea un riquadro toccabile
      children: abilityNames.keys
          .map(
            (key) => _AbilityBox(
              label: key,
              score: c.scoreOf(key),
              onTap: () => _editAbility(key),
            ),
          )
          .toList(),
    );
  }

  // --- BLOCCO 5: tiri salvezza ---
  Widget _buildSavingThrows() {
    return _SectionCard(
      title: 'TIRI SALVEZZA',
      children: abilityNames.keys.map((key) {
        // Ha competenza in questo tiro salvezza?
        final proficient = c.savingThrowProficiencies.contains(key);
        // bonus = modificatore + (competenza, se ce l'ha)
        final bonus = modifier(c.scoreOf(key)) + (proficient ? prof : 0);

        return _ProficiencyRow(
          label: abilityNames[key]!,
          bonus: bonus,
          proficient: proficient,
          onChanged: (v) => _toggle(c.savingThrowProficiencies, key, v),
        );
      }).toList(),
    );
  }

  // --- BLOCCO 6: abilità ---
  // Bonus di un'abilità: modificatore della caratteristica collegata + competenza
  int _skillBonus(SkillInfo skill) {
    final proficient = c.skillProficiencies.contains(skill.name);
    return modifier(c.scoreOf(skill.ability)) + (proficient ? prof : 0);
  }

  Widget _buildSkills() {
    return _SectionCard(
      title: 'ABILITÀ',
      children: skills.map((skill) {
        final proficient = c.skillProficiencies.contains(skill.name);

        return _ProficiencyRow(
          label: skill.name,
          sublabel: skill.ability, // sigla della caratteristica (es. FOR)
          bonus: _skillBonus(skill),
          proficient: proficient,
          onChanged: (v) => _toggle(c.skillProficiencies, skill.name, v),
        );
      }).toList(),
    );
  }
}

// ============ WIDGET PICCOLI (riusabili) ============
// StatelessWidget = non cambiano da soli: mostrano ciò che ricevono.

// Pulsante per i PF (-5, -1, +1, +5)
class _HpButton extends StatelessWidget {
  final String label; // testo sul pulsante
  final VoidCallback onPressed; // cosa fare quando lo premi

  const _HpButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: OutlinedButton(onPressed: onPressed, child: Text(label)),
    );
  }
}

// Riquadro piccolo (CA, iniziativa, ecc.): valore grande, etichetta sotto
class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Riquadro caratteristica: modificatore grande, valore piccolo, toccabile
class _AbilityBox extends StatelessWidget {
  final String label; // sigla, es. "FOR"
  final int score; // valore, es. 16
  final VoidCallback onTap; // cosa fare al tocco (apre la modifica)

  const _AbilityBox({
    required this.label,
    required this.score,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // InkWell = rende l'area toccabile con l'effetto "onda"
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            // modificatore col segno, es. "+3"
            Text(
              signed(modifier(score)),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text('($score)'), // valore tra parentesi
          ],
        ),
      ),
    );
  }
}

// Scatola con un titolo e una lista di righe dentro (tiri salvezza, abilità)
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children; // le righe da mostrare

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // allinea a sinistra
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            ...children, // "..." = inserisce tutti gli elementi della lista qui
          ],
        ),
      ),
    );
  }
}

// Riga: [casella competenza] [+bonus] [nome] [sigla]
class _ProficiencyRow extends StatelessWidget {
  final String label; // nome, es. "Atletica"
  final String? sublabel; // sigla opzionale (? = può essere null)
  final int bonus; // bonus già calcolato
  final bool proficient; // casella spuntata?
  final ValueChanged<bool> onChanged; // chiamata col nuovo valore della casella

  const _ProficiencyRow({
    required this.label,
    required this.bonus,
    required this.proficient,
    required this.onChanged,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!proficient), // toccare la riga inverte la spunta
      child: Row(
        children: [
          Checkbox(value: proficient, onChanged: (v) => onChanged(v ?? false)),
          SizedBox(
            width: 40, // larghezza fissa: i bonus restano allineati
            child: Text(
              signed(bonus),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(label)), // occupa lo spazio rimasto
          if (sublabel != null) // mostra la sigla solo se c'è
            Text(sublabel!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

// ============ FINESTRE (funzioni fuori dalle classi) ============

// Finestra "Modifica statistiche". Restituisce true se premi Salva.
Future<bool> showEditCharacterDialog(
  BuildContext context,
  CharacterSheet character, // il personaggio vero (non una copia)
) async {
  // Un controller per campo, già riempito con il valore attuale
  final hpCtrl = TextEditingController(text: '${character.maxHp}');
  final acCtrl = TextEditingController(text: '${character.armorClass}');
  final speedCtrl = TextEditingController(text: '${character.speed}');

  final saved = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Modifica statistiche'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // la finestra è alta quanto serve
          children: [
            TextField(
              controller: hpCtrl,
              decoration: const InputDecoration(labelText: 'PF max'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: acCtrl,
              decoration: const InputDecoration(labelText: 'CA'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: speedCtrl,
              decoration: const InputDecoration(labelText: 'Velocità'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false), // Annulla: non scrive nulla
          child: const Text('Annulla'),
        ),
        FilledButton(
          // Scrivo sul personaggio SOLO qui, quando premi Salva
          onPressed: () {
            // "?? valore vecchio" = se il testo non è un numero, tengo quello di prima
            character.maxHp =
                (int.tryParse(hpCtrl.text) ?? character.maxHp).clamp(1, 999);
            character.armorClass =
                int.tryParse(acCtrl.text) ?? character.armorClass;
            character.speed = int.tryParse(speedCtrl.text) ?? character.speed;
            // i PF attuali non possono superare il nuovo massimo
            character.currentHp =
                character.currentHp.clamp(0, character.maxHp);
            Navigator.pop(ctx, true);
          },
          child: const Text('Salva'),
        ),
      ],
    ),
  );

  return saved ?? false; // se chiudi toccando fuori, saved è null -> false
}

// Finestra "Classi e livelli". Restituisce true se premi Salva.
Future<bool> showClassesDialog(
  BuildContext context,
  CharacterSheet character,
) async {
  // COPIA di lavoro: modifico questa, e la applico solo se premi Salva.
  // (così "Annulla" lascia il personaggio intatto)
  final working = character.classes
      .map((e) => CharacterClass(name: e.name, level: e.level))
      .toList();
  final newNameCtrl = TextEditingController(); // campo "Nuova classe"

  final saved = await showDialog<bool>(
    context: context,
    // StatefulBuilder = permette di avere un setState dentro la finestra
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) {
        // Livello totale = somma dei livelli di tutte le classi
        final total = working.fold<int>(0, (s, e) => s + e.level);

        // Cambia il livello della classe in posizione i (delta = +1 o -1)
        void changeLevel(int i, int delta) {
          final newLevel = working[i].level + delta;
          setLocal(() {
            if (newLevel <= 0) {
              working.removeAt(i); // livello 0 = la classe sparisce
            } else {
              // CharacterClass è immutabile: ne creo una nuova
              working[i] = CharacterClass(
                name: working[i].name,
                level: newLevel,
              );
            }
          });
        }

        // Aggiunge una classe nuova a livello 1
        void addClass() {
          final name = newNameCtrl.text.trim();
          if (name.isEmpty || total >= 20) return;
          setLocal(() {
            working.add(CharacterClass(name: name, level: 1));
            newNameCtrl.clear();
          });
        }

        return AlertDialog(
          title: Text('Classi (livello totale $total / 20)'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Una riga per ogni classe: nome, [-] livello [+]
                for (int i = 0; i < working.length; i++)
                  Row(
                    children: [
                      Expanded(child: Text(working[i].name)),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => changeLevel(i, -1),
                      ),
                      Text('${working[i].level}'),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        // null = pulsante disattivato (tetto: livello 20 totale)
                        onPressed: total >= 20 ? null : () => changeLevel(i, 1),
                      ),
                    ],
                  ),
                const Divider(),
                // Riga per aggiungere una classe nuova
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: newNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nuova classe',
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: total >= 20 ? null : addClass,
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              // Disattivato se non c'è nessuna classe (ne serve almeno una)
              onPressed: working.isEmpty
                  ? null
                  : () {
                      character.classes = working; // applico la copia all'originale
                      Navigator.pop(ctx, true);
                    },
              child: const Text('Salva'),
            ),
          ],
        );
      },
    ),
  );

  return saved ?? false;
}