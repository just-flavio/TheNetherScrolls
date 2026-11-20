// ===== IMPORT =====
import 'dart:math'; // serve per Random (numeri casuali)

import 'package:flutter/material.dart'; // widget base di Flutter

// Pagina dei dadi. È StatefulWidget perché i valori cambiano
// mentre la usi (tipo di dado, quantità, risultato).
class DiceScreen extends StatefulWidget {
  const DiceScreen({super.key});

  @override
  State<DiceScreen> createState() => _DiceScreenState();
}

// Lo stato della pagina: i dati che cambiano e le funzioni che li modificano
class _DiceScreenState extends State<DiceScreen> {
  // Generatore di numeri casuali (uno solo, riusato a ogni lancio)
  final Random _random = Random();

  // I dadi disponibili: d4, d6, d8, d10, d12, d20, d100
  final List<int> _diceSides = [4, 6, 8, 10, 12, 20, 100];

  int _selectedSides = 20; // dado scelto (parte dal d20)
  int _diceCount = 1; // quanti dadi lanciare
  int _modifier = 0; // numero da sommare al totale (può essere negativo)
  List<int> _rollResults = const []; // i singoli tiri dell'ultimo lancio
  int _total = 0; // somma dei tiri + modificatore

  // Lancia i dadi e salva il risultato
  void _rollDice() {
    // Crea una lista con un numero casuale per ogni dado.
    // nextInt(20) dà 0..19, quindi "+ 1" per ottenere 1..20.
    // "(_)" = l'indice di ogni dado: non mi serve, lo ignoro.
    final rolls = List<int>.generate(
      _diceCount,
      (_) => _random.nextInt(_selectedSides) + 1,
    );

    // Somma tutti i tiri (reduce) e aggiunge il modificatore
    final total = rolls.reduce((sum, value) => sum + value) + _modifier;

    // setState = "i dati sono cambiati, ridisegna la pagina"
    setState(() {
      _rollResults = rolls;
      _total = total;
    });
  }

  // Aumenta o diminuisce il numero di dadi (delta = +1 o -1)
  void _changeDiceCount(int delta) {
    setState(() {
      // clamp = tiene il valore tra 1 e 20
      _diceCount = (_diceCount + delta).clamp(1, 20);
    });
  }

  // Aumenta o diminuisce il modificatore (delta = +1 o -1)
  void _changeModifier(int delta) {
    setState(() {
      _modifier = (_modifier + delta).clamp(-50, 50); // tra -50 e +50
    });
  }

  // build() disegna la pagina; viene richiamato a ogni setState
  @override
  Widget build(BuildContext context) {
    // Scaffold = lo scheletro della pagina (barra in alto + corpo)
    return Scaffold(
      appBar: AppBar(title: const Text('Lancia i dadi'), centerTitle: true),
      // SingleChildScrollView = permette di scorrere se lo schermo è piccolo
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          // stretch = i figli occupano tutta la larghezza
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== BLOCCO 1: scelta del tipo di dado =====
            const Text(
              'Tipo di dado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12), // spazio vuoto
            // Wrap = mette i pulsanti in fila e va a capo se non c'è spazio
            Wrap(
              spacing: 8, // spazio orizzontale tra i pulsanti
              runSpacing: 8, // spazio verticale tra le righe
              // Per ogni dado della lista crea un pulsante "d4", "d6"...
              children: _diceSides.map((sides) {
                final isSelected = _selectedSides == sides; // è quello scelto?
                return ChoiceChip(
                  label: Text('d$sides'),
                  selected: isSelected, // evidenziato se scelto
                  onSelected: (_) {
                    // al tocco, memorizzo il dado scelto e ridisegno
                    setState(() {
                      _selectedSides = sides;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ===== BLOCCO 2: numero di dadi =====
            Row(
              children: [
                // Expanded = la card occupa tutta la larghezza disponibile
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
                          // Riga: [-]  numero  [+]
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () => _changeDiceCount(-1),
                                icon: const Icon(Icons.remove),
                              ),
                              Text(
                                '$_diceCount', // mostra il numero attuale
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

            // ===== BLOCCO 3: modificatore =====
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
                    // Riga: [-]  +3  [+]
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => _changeModifier(-1),
                          icon: const Icon(Icons.remove),
                        ),
                        Text(
                          // mostra il segno: "+3" se positivo, "-2" se negativo
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

            // ===== BLOCCO 4: pulsante di lancio =====
            ElevatedButton.icon(
              onPressed: _rollDice, // al tocco, lancia
              icon: const Icon(Icons.casino_outlined),
              label: const Text('Lancia i dadi'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),

            // ===== BLOCCO 5: risultato =====
            Card(
              // colore del tema: si vede bene sia in chiaro che in scuro
              color: Theme.of(context).colorScheme.primaryContainer,
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
                    // Totale = somma dei tiri + modificatore
                    Text(
                      'Totale: $_total',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Prima del primo lancio la lista è vuota: mostro un avviso.
                    // Dopo, mostra i singoli tiri, es. "Lanci: 4 + 6"
                    Text(
                      _rollResults.isEmpty
                          ? 'Nessun lancio effettuato'
                          : 'Lanci: ${_rollResults.join(' + ')}',
                    ),
                    // "if" dentro una lista: il widget compare solo se la condizione è vera
                    if (_modifier != 0)
                      Text(
                        'Modificatore: ${_modifier >= 0 ? '+$_modifier' : '$_modifier'}',
                      ),
                    // 20 naturale: solo con un singolo d20
                    if (_selectedSides == 20 &&
                        _rollResults.length == 1 &&
                        _rollResults.first == 20)
                      const Text(
                        'Successo CRITICO!',
                        style: TextStyle(color: Colors.green),
                      ),
                    // 1 naturale: solo con un singolo d20
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