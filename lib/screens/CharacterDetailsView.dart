import 'package:flutter/material.dart';
import 'package:thenetherscrolls/data/character.dart';
import 'package:thenetherscrolls/data/DnDData.dart';
import 'package:thenetherscrolls/data/DnDMath.dart';
import 'package:thenetherscrolls/widgets/entries_tab.dart';
import 'package:thenetherscrolls/widgets/notes_tab.dart';
import 'package:thenetherscrolls/screens/spells_tab.dart';

class CharacterDetails extends StatefulWidget {
  final CharacterSheet character;

  const CharacterDetails({super.key, required this.character});

  @override
  State<CharacterDetails> createState() => _CharacterDetailsState();
}

class _CharacterDetailsState extends State<CharacterDetails> {
  CharacterSheet get c => widget.character;

  final _amountCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  int get prof => proficiencyBonus(c.characterLevel);

  void _changeHp(int delta) {
    setState(() {
      c.currentHp = (c.currentHp + delta).clamp(0, c.maxHp);
    });
  }

  // sign = -1 per il danno, +1 per la cura
  void _applyAmount(int sign) {
    final n = int.tryParse(_amountCtrl.text);
    if (n == null || n <= 0) return;
    _changeHp(sign * n);
    _amountCtrl.clear();
    FocusScope.of(context).unfocus();
  }

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
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(c.characterName),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Scheda'),
              Tab(text: 'Oggetti'),
              Tab(text: 'Incantesimi'),
              Tab(text: 'Passive'),
              Tab(text: 'Note'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSheetTab(),
            EntriesTab(
              entries: c.items,
              showQuantity: true,
              addLabel: 'Aggiungi oggetto',
              emptyText: 'Nessun oggetto. Aggiungi spade, pozioni, monete...',
            ),
            SpellsTab(spells: c.spells),
            EntriesTab(
              entries: c.passives,
              showQuantity: false,
              addLabel: 'Aggiungi passiva',
              emptyText: 'Nessuna passiva. Aggiungi tratti di razza e classe.',
            ),
            NotesTab(character: c),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetTab() {
    return ListView(
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
            const SizedBox(height: 12),
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
                  onPressed: () => _applyAmount(-1),
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Danno'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _applyAmount(1),
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

  // --- BLOCCO 3: CA, iniziativa, velocità, competenza ---
  Widget _buildCombatRow() {
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