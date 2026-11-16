import 'package:flutter/material.dart';
import 'package:thenetherscrolls/data/character.dart';
import 'package:thenetherscrolls/data/DnDData.dart';
import 'package:thenetherscrolls/data/DnDMath.dart';
import 'package:thenetherscrolls/widgets/entries_tab.dart';
import 'package:thenetherscrolls/screens/spells_tab.dart';

class CharacterDetails extends StatefulWidget {
  final CharacterSheet character;

  const CharacterDetails({super.key, required this.character});

  @override
  State<CharacterDetails> createState() => _CharacterDetailsState();
}
class CharacterEntry {
  String name;
  String description;
  int quantity; // per le passive resta 1 e non lo mostriamo

  CharacterEntry({
    required this.name,
    this.description = '',
    this.quantity = 1,
  });
}

// Un incantesimo salvato: solo il minimo, il testo lo scarichi dopo
class SpellRef {
  final String index; // es. "fireball" (serve per la fetch)
  final String name; // es. "Fireball"
  final int level; // 0 = trucchetto

  const SpellRef({
    required this.index,
    required this.name,
    required this.level,
  });
}
class _CharacterDetailsState extends State<CharacterDetails> {
  CharacterSheet get c => widget.character;

  // Bonus competenza calcolato una volta sola
  int get prof => proficiencyBonus(c.characterLevel);

  void _changeHp(int delta) {
    setState(() {
      c.currentHp = (c.currentHp + delta).clamp(0, c.maxHp);
    });
  }

  // Aggiunge o toglie una voce da un Set (competenza sì/no)
  void _toggle(Set<String> set, String key, bool value) {
    setState(() {
      if (value) {
        set.add(key);
      } else {
        set.remove(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(c.characterName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
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
      ),
    );
  }

  // --- BLOCCO 1: intestazione ---
  Widget _buildHeader() {
    return Column(
      children: [
        c.characterIcon,
        const SizedBox(height: 8),
        Text(
          c.characterName,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
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
            Text(
              '${c.currentHp} / ${c.maxHp}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _HpButton(label: '-5', onPressed: () => _changeHp(-5)),
                _HpButton(label: '-1', onPressed: () => _changeHp(-1)),
                _HpButton(label: '+1', onPressed: () => _changeHp(1)),
                _HpButton(label: '+5', onPressed: () => _changeHp(5)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- BLOCCO 3: CA, iniziativa, velocità, competenza ---
  Widget _buildCombatRow() {
    // Percezione passiva = 10 + bonus di Percezione
    final perceptionBonus = _skillBonus(
      const SkillInfo('Percezione', 'SAG'),
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatBox(label: 'CA', value: '${c.armorClass}')),
            Expanded(
              child: _StatBox(
                label: 'Iniziativa',
                value: signed(modifier(c.dexterity)),
              ),
            ),
            Expanded(child: _StatBox(label: 'Velocità', value: '${c.speed}')),
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

  // --- BLOCCO 4: le 6 caratteristiche ---
  Widget _buildAbilities() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: abilityNames.keys
          .map((key) => _AbilityBox(label: key, score: c.scoreOf(key)))
          .toList(),
    );
  }

  // --- BLOCCO 5: tiri salvezza ---
  Widget _buildSavingThrows() {
    return _SectionCard(
      title: 'TIRI SALVEZZA',
      children: abilityNames.keys.map((key) {
        final proficient = c.savingThrowProficiencies.contains(key);
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
          sublabel: skill.ability,
          bonus: _skillBonus(skill),
          proficient: proficient,
          onChanged: (v) => _toggle(c.skillProficiencies, skill.name, v),
        );
      }).toList(),
    );
  }
}

// ============ WIDGET PICCOLI (riusabili) ============

// Pulsante per i PF
class _HpButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _HpButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: OutlinedButton(onPressed: onPressed, child: Text(label)),
    );
  }
}

// Riquadro piccolo (CA, iniziativa, ecc.)
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

// Riquadro caratteristica: modificatore grande, valore piccolo
class _AbilityBox extends StatelessWidget {
  final String label;
  final int score;

  const _AbilityBox({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          Text(
            signed(modifier(score)),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text('($score)'),
        ],
      ),
    );
  }
}

// Scatola con titolo e una lista di righe dentro
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            ...children,
          ],
        ),
      ),
    );
  }
}

// Riga: [casella competenza] [+bonus] [nome] (sigla)
class _ProficiencyRow extends StatelessWidget {
  final String label;
  final String? sublabel;
  final int bonus;
  final bool proficient;
  final ValueChanged<bool> onChanged;

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
      onTap: () => onChanged(!proficient),
      child: Row(
        children: [
          Checkbox(value: proficient, onChanged: (v) => onChanged(v ?? false)),
          SizedBox(
            width: 40,
            child: Text(
              signed(bonus),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(label)),
          if (sublabel != null)
            Text(sublabel!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}