import 'package:flutter/material.dart';
import 'package:thenetherscrolls/data/character.dart';
import 'package:thenetherscrolls/services/spell_api_service.dart';

String levelLabel(int level) => level == 0 ? 'Trucchetto' : 'Livello $level';

// ============ 1. LISTA DEGLI INCANTESIMI DEL PERSONAGGIO ============
class SpellsTab extends StatefulWidget {
  final List<SpellRef> spells;

  const SpellsTab({super.key, required this.spells});

  @override
  State<SpellsTab> createState() => _SpellsTabState();
}

class _SpellsTabState extends State<SpellsTab> {
  Future<void> _addSpell() async {
    // Apre la ricerca e aspetta che tu ne scelga uno
    final picked = await Navigator.push<SpellRef>(
      context,
      MaterialPageRoute(builder: (_) => const SpellSearchScreen()),
    );
    if (picked == null) return;

    // Niente doppioni
    final already = widget.spells.any((s) => s.index == picked.index);
    if (already) return;

    setState(() => widget.spells.add(picked));
  }

  @override
  Widget build(BuildContext context) {
    // Ordino per livello, poi per nome (copia: non tocco l'originale)
    final sorted = [...widget.spells]..sort((a, b) {
        final byLevel = a.level.compareTo(b.level);
        return byLevel != 0 ? byLevel : a.name.compareTo(b.name);
      });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        OutlinedButton.icon(
          onPressed: _addSpell,
          icon: const Icon(Icons.search),
          label: const Text('Aggiungi incantesimo'),
        ),
        const SizedBox(height: 8),
        if (sorted.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Nessun incantesimo. Premi il pulsante per cercarne uno.',
              textAlign: TextAlign.center,
            ),
          ),
        ...sorted.map(
          (s) => Card(
            child: ListTile(
              title: Text(s.name),
              subtitle: Text(levelLabel(s.level)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SpellDetailScreen(spell: s),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => setState(() => widget.spells.remove(s)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============ 2. RICERCA (fetch della lista) ============
class SpellSearchScreen extends StatefulWidget {
  const SpellSearchScreen({super.key});

  @override
  State<SpellSearchScreen> createState() => _SpellSearchScreenState();
}

class _SpellSearchScreenState extends State<SpellSearchScreen> {
  late Future<List<SpellRef>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = SpellApiService.fetchSpellList();
  }

  void _retry() {
    setState(() => _future = SpellApiService.fetchSpellList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cerca incantesimo')),
      body: FutureBuilder<List<SpellRef>>(
        future: _future,
        builder: (context, snapshot) {
          // STATO 1: sta caricando
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          // STATO 2: errore
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Impossibile scaricare gli incantesimi.'),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _retry,
                    child: const Text('Riprova'),
                  ),
                ],
              ),
            );
          }

          // STATO 3: dati pronti, filtro in locale
          final filtered = snapshot.data!
              .where((s) => s.name.toLowerCase().contains(_query))
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Es. fireball',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) =>
                      setState(() => _query = v.trim().toLowerCase()),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final s = filtered[i];
                    return ListTile(
                      title: Text(s.name),
                      subtitle: Text(levelLabel(s.level)),
                      // Tocca = scegli e torna indietro
                      onTap: () => Navigator.pop(context, s),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============ 3. DETTAGLIO (seconda fetch) ============
class SpellDetailScreen extends StatelessWidget {
  final SpellRef spell;

  const SpellDetailScreen({super.key, required this.spell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(spell.name)),
      body: FutureBuilder<SpellDetail>(
        future: SpellApiService.fetchSpell(spell.index),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Impossibile caricare. Controlla la connessione.'),
            );
          }

          final d = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '${levelLabel(d.level)} • ${d.school}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _Line(label: 'Tempo di lancio', value: d.castingTime),
              _Line(label: 'Gittata', value: d.range),
              _Line(label: 'Componenti', value: d.components),
              _Line(label: 'Durata', value: d.duration),
              const Divider(height: 24),
              // desc è una lista di paragrafi
              ...d.description.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(p),
                ),
              ),
              if (d.higherLevel.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'A livelli superiori',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                ...d.higherLevel.map(Text.new),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;

  const _Line({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}