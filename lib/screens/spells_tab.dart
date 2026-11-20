// ===== IMPORT =====
import 'package:flutter/material.dart'; // widget base di Flutter
import 'package:thenetherscrolls/data/character.dart'; // contiene SpellRef
import 'package:thenetherscrolls/services/spell_api_service.dart'; // la fetch (internet)

// Trasforma il livello in testo: 0 -> "Trucchetto", 3 -> "Livello 3"
String levelLabel(int level) => level == 0 ? 'Trucchetto' : 'Livello $level';

// Questo file contiene 3 schermate + 1 widget piccolo:
//   1. SpellsTab          -> lista degli incantesimi del personaggio
//   2. SpellSearchScreen  -> ricerca nella lista scaricata da internet
//   3. SpellDetailScreen  -> dettaglio di un incantesimo (seconda fetch)

// ============ 1. LISTA DEGLI INCANTESIMI DEL PERSONAGGIO ============
class SpellsTab extends StatefulWidget {
  // La lista del personaggio (la stessa di character.spells, non una copia)
  final List<SpellRef> spells;

  const SpellsTab({super.key, required this.spells});

  @override
  State<SpellsTab> createState() => _SpellsTabState();
}

class _SpellsTabState extends State<SpellsTab> {
  // Apre la ricerca e aggiunge l'incantesimo scelto
  Future<void> _addSpell() async {
    // push<SpellRef> = apro la pagina e aspetto che restituisca un SpellRef.
    // Il valore arriva quando la ricerca fa Navigator.pop(context, spell).
    final picked = await Navigator.push<SpellRef>(
      context,
      MaterialPageRoute(builder: (_) => const SpellSearchScreen()),
    );
    if (picked == null) return; // sei tornato indietro senza scegliere

    // Controllo doppioni: esiste già un incantesimo con lo stesso index?
    final alreadyAdded = widget.spells.any(
      (spell) => spell.index == picked.index,
    );
    if (alreadyAdded) return;

    // Aggiungo alla lista e ridisegno
    setState(() => widget.spells.add(picked));
  }

  @override
  Widget build(BuildContext context) {
    // Ordino per livello, poi per nome.
    // "[...lista]" crea una COPIA: ordino quella e lascio l'originale intatto.
    final sorted = [...widget.spells]
      ..sort((a, b) {
        final byLevel = a.level.compareTo(b.level); // negativo, 0 o positivo
        // se il livello è uguale (0), decide il nome in ordine alfabetico
        return byLevel != 0 ? byLevel : a.name.compareTo(b.name);
      });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Pulsante per aprire la ricerca
        OutlinedButton.icon(
          onPressed: _addSpell,
          icon: const Icon(Icons.search),
          label: const Text('Aggiungi incantesimo'),
        ),
        const SizedBox(height: 8),
        // Messaggio mostrato solo se la lista è vuota
        if (sorted.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Nessun incantesimo. Premi il pulsante per cercarne uno.',
              textAlign: TextAlign.center,
            ),
          ),
        // Una card per ogni incantesimo ("..." inserisce tutti gli elementi qui)
        ...sorted.map(
          (spell) => Card(
            child: ListTile(
              title: Text(spell.name),
              subtitle: Text(levelLabel(spell.level)),
              // Tocco sulla card: apre il dettaglio (fa la seconda fetch)
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SpellDetailScreen(spell: spell),
                ),
              ),
              // Cestino a destra: toglie l'incantesimo dalla lista
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => setState(() => widget.spells.remove(spell)),
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
  // Future = "un risultato che arriverà": qui la lista scaricata da internet.
  // "late" = lo assegno in initState, non subito.
  late Future<List<SpellRef>> _future;
  String _query = ''; // testo scritto nella barra di ricerca

  // initState parte UNA volta, quando la pagina si apre: avvia il download
  @override
  void initState() {
    super.initState();
    _future = SpellApiService.fetchSpellList();
  }

  // Riprova il download (pulsante mostrato in caso di errore)
  void _retry() {
    setState(() => _future = SpellApiService.fetchSpellList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cerca incantesimo')),
      // FutureBuilder ridisegna la pagina in base allo stato del download
      body: FutureBuilder<List<SpellRef>>(
        future: _future,
        builder: (context, snapshot) {
          // STATO 1: sta ancora scaricando -> spinner
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          // STATO 2: errore (niente internet, server giù...) -> messaggio + Riprova
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

          // STATO 3: dati pronti. Filtro in locale (nessuna chiamata a ogni lettera).
          // snapshot.data! = la lista scaricata ("!" = so che non è null)
          final filtered = snapshot.data!
              .where((spell) => spell.name.toLowerCase().contains(_query))
              .toList();

          return Column(
            children: [
              // Barra di ricerca
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Es. fireball',
                    border: OutlineInputBorder(),
                  ),
                  // A ogni lettera salvo il testo (minuscolo, senza spazi ai lati)
                  // e ridisegno: la lista si restringe subito
                  onChanged: (text) =>
                      setState(() => _query = text.trim().toLowerCase()),
                ),
              ),
              // Expanded = la lista occupa tutto lo spazio rimasto
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final spell = filtered[index];
                    return ListTile(
                      title: Text(spell.name),
                      subtitle: Text(levelLabel(spell.level)),
                      // Tocco = scelgo e torno indietro, restituendo l'incantesimo
                      // (arriva a "picked" dentro _addSpell)
                      onTap: () => Navigator.pop(context, spell),
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
// StatelessWidget: non ha dati che cambiano da soli, il FutureBuilder gestisce il resto
class SpellDetailScreen extends StatelessWidget {
  final SpellRef spell; // l'incantesimo da mostrare (solo nome, livello e index)

  const SpellDetailScreen({super.key, required this.spell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(spell.name)),
      // Scarica il testo completo usando l'index (es. "fireball")
      body: FutureBuilder<SpellDetail>(
        future: SpellApiService.fetchSpell(spell.index),
        builder: (context, snapshot) {
          // Sta scaricando -> spinner
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          // Errore -> messaggio
          if (snapshot.hasError) {
            return const Center(
              child: Text('Impossibile caricare. Controlla la connessione.'),
            );
          }

          // Dati pronti
          final detail = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Es. "Livello 3 • Evocation"
              Text(
                '${levelLabel(detail.level)} • ${detail.school}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              // Le righe con le informazioni principali
              _InfoLine(label: 'Tempo di lancio', value: detail.castingTime),
              _InfoLine(label: 'Gittata', value: detail.range),
              _InfoLine(label: 'Componenti', value: detail.components),
              _InfoLine(label: 'Durata', value: detail.duration),
              const Divider(height: 24), // linea di separazione
              // La descrizione arriva come lista di paragrafi: uno Text ciascuno
              ...detail.description.map(
                (paragraph) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(paragraph),
                ),
              ),
              // "A livelli superiori": solo se l'incantesimo lo prevede
              if (detail.higherLevel.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'A livelli superiori',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                // Text.new = scorciatoia per (testo) => Text(testo)
                ...detail.higherLevel.map(Text.new),
              ],
            ],
          );
        },
      ),
    );
  }
}

// Riga "Etichetta: valore", con l'etichetta in grassetto
class _InfoLine extends StatelessWidget {
  final String label; // es. "Gittata"
  final String value; // es. "150 feet"

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      // Text.rich permette di mescolare stili diversi nella stessa riga
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