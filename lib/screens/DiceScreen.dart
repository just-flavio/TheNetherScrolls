import 'dart:math';

import 'package:flutter/material.dart';

class DiceScreen extends StatefulWidget {
  const DiceScreen({super.key});

  @override
  State<DiceScreen> createState() => _DiceScreenState();
}

class _DiceScreenState extends State<DiceScreen> {
  final Random _random = Random();
  final List<int> _diceSides = [4, 8, 10, 12, 20, 100];

  int _selectedSides = 20;
  int _diceCount = 1;
  int _modifier = 0;
  List<int> _rollResults = const [];
  int _total = 0;

  void _rollDice() {
    final rolls = List<int>.generate(
      _diceCount,
      (_) => _random.nextInt(_selectedSides) + 1,
    );

    final total = rolls.reduce((sum, value) => sum + value) + _modifier;

    setState(() {
      _rollResults = rolls;
      _total = total;
    });
  }

  void _changeDiceCount(int delta) {
    setState(() {
      _diceCount = (_diceCount + delta).clamp(1, 20);
    });
  }

  void _changeModifier(int delta) {
    setState(() {
      _modifier = (_modifier + delta).clamp(-50, 50);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lancia i dadi'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tipo di dado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _diceSides.map((sides) {
                final isSelected = _selectedSides == sides;
                return ChoiceChip(
                  label: Text('d$sides'),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedSides = sides;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Numero di dadi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () => _changeDiceCount(-1),
                                icon: const Icon(Icons.remove),
                              ),
                              Text(
                                '$_diceCount',
                                style: const TextStyle(fontSize: 28),
                              ),
                              IconButton(
                                onPressed: () => _changeDiceCount(1),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Modificatore',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => _changeModifier(-1),
                          icon: const Icon(Icons.remove),
                        ),
                        Text(
                          _modifier >= 0 ? '+$_modifier' : '$_modifier',
                          style: const TextStyle(fontSize: 28),
                        ),
                        IconButton(
                          onPressed: () => _changeModifier(1),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _rollDice,
              icon: const Icon(Icons.casino_outlined),
              label: const Text('Lancia i dadi'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.deepPurple.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Risultato',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Totale: $_total',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _rollResults.isEmpty
                          ? 'Nessun lancio effettuato'
                          : 'Lanci: ${_rollResults.join(' + ')}',
                    ),
                    if (_modifier != 0)
                      Text(
                        'Modificatore: ${_modifier >= 0 ? '+$_modifier' : '$_modifier'}',
                      ),
                    if (_selectedSides == 20 &&
                        _rollResults.length == 1 &&
                        _rollResults.first == 20)
                      const Text(
                        'Successo CRITICO!',
                        style: TextStyle(color: Colors.green),
                      ),
                    if (_selectedSides == 20 &&
                        _rollResults.length == 1 &&
                        _rollResults.first == 1)
                      const Text(
                        'Fallimento critico',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
