// ===== IMPORT =====
import 'package:flutter/material.dart'; // serve per IconData, Color, Icon, Widget

// ============ ICONE DISPONIBILI ============
// Un'icona possibile per il personaggio: forma + colore
class IconOption {
  final IconData icon;
  final Color color;
  const IconOption(this.icon, this.color);
}

// Lista delle icone. Il personaggio salva solo la POSIZIONE (iconIndex),
// perché un Widget non si può trasformare in testo JSON.
// ATTENZIONE: non cambiare l'ordine e non togliere elementi,
// altrimenti i personaggi già salvati cambiano icona.
const List<IconOption> characterIconOptions = [
  IconOption(Icons.shield, Colors.blue), // 0
  IconOption(Icons.local_fire_department, Colors.red), // 1
  IconOption(Icons.bolt, Colors.orange), // 2
  IconOption(Icons.forest, Colors.green), // 3
  IconOption(Icons.auto_fix_high, Colors.purple), // 4
  IconOption(Icons.pets, Colors.brown), // 5
];

// ============ CLASSE DI PERSONAGGIO (es. Paladino 15) ============
class CharacterClass {
  final String name; // es. "Paladino"
  final int level; // es. 15

  const CharacterClass({required this.name, required this.level});

  // Oggetto -> Map (poi diventa testo JSON per il database)
  Map<String, dynamic> toJson() => {'name': name, 'level': level};

  // Map -> oggetto. "?? valore" = se il campo manca, uso un valore di riserva
  factory CharacterClass.fromJson(Map<String, dynamic> json) =>
      CharacterClass(name: json['name'] ?? '', level: json['level'] ?? 1);
}

// ============ OGGETTO O PASSIVA: nome + testo libero ============
class CharacterEntry {
  String name; // NON final: si può modificare
  String description;
  int quantity; // per le passive resta 1 e non viene mostrata

  CharacterEntry({
    required this.name,
    this.description = '',
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'quantity': quantity,
  };

  factory CharacterEntry.fromJson(Map<String, dynamic> json) => CharacterEntry(
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    quantity: json['quantity'] ?? 1,
  );
}

// ============ INCANTESIMO SALVATO ============
// Solo il minimo: il testo completo si scarica da internet quando lo apri
class SpellRef {
  final String index; // es. "fireball" (serve per la fetch)
  final String name; // es. "Fireball"
  final int level; // 0 = trucchetto

  const SpellRef({
    required this.index,
    required this.name,
    required this.level,
  });

  Map<String, dynamic> toJson() => {
    'index': index,
    'name': name,
    'level': level,
  };

  factory SpellRef.fromJson(Map<String, dynamic> json) => SpellRef(
    index: json['index'] ?? '',
    name: json['name'] ?? '',
    level: json['level'] ?? 0,
  );
}

// ============ IL PERSONAGGIO ============
class CharacterSheet {
  // ----- Dati fissi (final = non cambiano dopo la creazione) -----
  int? id; // assegnato dal database (null finché non è salvato)
  final int iconIndex; // posizione in characterIconOptions
  final String characterName;
  final String race;

  // ----- Dati modificabili durante il gioco -----
  List<CharacterClass> classes; // non final: si sostituisce la lista al level up
  int strength;
  int dexterity;
  int constitution;
  int intelligence;
  int wisdom;
  int charisma;
  int maxHp; // punti ferita massimi
  int currentHp; // punti ferita adesso
  int armorClass; // classe armatura (CA)
  int speed; // velocità
  String notes; // note libere

  // ----- Competenze e liste -----
  final Set<String> savingThrowProficiencies; // es. {'FOR', 'CAR'}
  final Set<String> skillProficiencies; // es. {'Atletica', 'Persuasione'}
  final List<CharacterEntry> items; // oggetti
  final List<CharacterEntry> passives; // passive di classe e razza
  final List<SpellRef> spells; // incantesimi conosciuti

  CharacterSheet({
    required this.iconIndex,
    this.id,
    required this.characterName,
    required this.race,
    required this.classes,
    // Valori di default: se non li passi, partono così
    this.strength = 10,
    this.dexterity = 10,
    this.constitution = 10,
    this.intelligence = 10,
    this.wisdom = 10,
    this.charisma = 10,
    this.maxHp = 10,
    int? currentHp, // opzionale: se manca, uguale a maxHp (vedi sotto)
    this.armorClass = 10,
    this.speed = 30,
    this.notes = "",
    Set<String>? savingThrowProficiencies,
    Set<String>? skillProficiencies,
    List<CharacterEntry>? items,
    List<CharacterEntry>? passives,
    List<SpellRef>? spells,
    // Dopo i ":" = inizializzazioni. "??" = se il valore è null uso quello a destra.
    // Ogni personaggio riceve una lista/Set NUOVO e suo.
  }) : currentHp = currentHp ?? maxHp,
       savingThrowProficiencies = savingThrowProficiencies ?? <String>{},
       skillProficiencies = skillProficiencies ?? <String>{},
       items = items ?? <CharacterEntry>[],
       passives = passives ?? <CharacterEntry>[],
       spells = spells ?? <SpellRef>[];

  // ----- Valori calcolati -----

  // Ricostruisce il Widget dall'indice (clamp evita indici fuori dalla lista)
  Widget get characterIcon {
    final i = iconIndex.clamp(0, characterIconOptions.length - 1);
    final option = characterIconOptions[i];
    return Icon(option.icon, color: option.color);
  }

  // Livello totale = somma dei livelli di tutte le classi (fold = somma a catena)
  int get characterLevel =>
      classes.fold<int>(0, (sum, characterClass) => sum + characterClass.level);

  // Nomi delle classi uniti, es. "Ladro, Ranger"
  String get characterClass =>
      classes.map((characterClass) => characterClass.name).join(', ');

  // ----- Leggere e scrivere una caratteristica dalla sua sigla -----

  // Sigla -> valore (es. 'FOR' -> strength)
  int scoreOf(String ability) {
    switch (ability) {
      case 'FOR':
        return strength;
      case 'DES':
        return dexterity;
      case 'COS':
        return constitution;
      case 'INT':
        return intelligence;
      case 'SAG':
        return wisdom;
      case 'CAR':
        return charisma;
      default:
        return 10;
    }
  }

  // Il contrario: scrive il valore nella caratteristica giusta
  void setScore(String ability, int value) {
    switch (ability) {
      case 'FOR':
        strength = value;
      case 'DES':
        dexterity = value;
      case 'COS':
        constitution = value;
      case 'INT':
        intelligence = value;
      case 'SAG':
        wisdom = value;
      case 'CAR':
        charisma = value;
    }
  }

  // ----- Salvataggio: personaggio <-> JSON -----

  // Personaggio -> Map (poi jsonEncode lo trasforma in testo per il database)
  Map<String, dynamic> toJson() => {
    'iconIndex': iconIndex,
    'name': characterName,
    'race': race,
    // ogni elemento della lista viene trasformato a sua volta in Map
    'classes': classes.map((e) => e.toJson()).toList(),
    'strength': strength,
    'dexterity': dexterity,
    'constitution': constitution,
    'intelligence': intelligence,
    'wisdom': wisdom,
    'charisma': charisma,
    'maxHp': maxHp,
    'currentHp': currentHp,
    'armorClass': armorClass,
    'speed': speed,
    'notes': notes,
    // JSON non conosce i Set: li trasformo in liste
    'savingThrows': savingThrowProficiencies.toList(),
    'skills': skillProficiencies.toList(),
    'items': items.map((e) => e.toJson()).toList(),
    'passives': passives.map((e) => e.toJson()).toList(),
    'spells': spells.map((e) => e.toJson()).toList(),
  };

  // Map -> personaggio. "id" arriva dal database, non dal JSON.
  // I "?? valore" permettono di leggere personaggi salvati prima che
  // aggiungessi un campo nuovo: il campo mancante prende il valore di riserva.
  factory CharacterSheet.fromJson(Map<String, dynamic> json, {int? id}) {
    return CharacterSheet(
      id: id,
      iconIndex: json['iconIndex'] ?? 0,
      characterName: json['name'] ?? '',
      race: json['race'] ?? '',
      classes: (json['classes'] as List? ?? [])
          .map((e) => CharacterClass.fromJson(e))
          .toList(),
      strength: json['strength'] ?? 10,
      dexterity: json['dexterity'] ?? 10,
      constitution: json['constitution'] ?? 10,
      intelligence: json['intelligence'] ?? 10,
      wisdom: json['wisdom'] ?? 10,
      charisma: json['charisma'] ?? 10,
      maxHp: json['maxHp'] ?? 10,
      currentHp: json['currentHp'], // se è null, il costruttore usa maxHp
      armorClass: json['armorClass'] ?? 10,
      speed: json['speed'] ?? 30,
      notes: json['notes'] ?? '',
      // lista JSON -> Set
      savingThrowProficiencies: Set<String>.from(
        json['savingThrows'] ?? <String>[],
      ),
      skillProficiencies: Set<String>.from(json['skills'] ?? <String>[]),
      items: (json['items'] as List? ?? [])
          .map((e) => CharacterEntry.fromJson(e))
          .toList(),
      passives: (json['passives'] as List? ?? [])
          .map((e) => CharacterEntry.fromJson(e))
          .toList(),
      spells: (json['spells'] as List? ?? [])
          .map((e) => SpellRef.fromJson(e))
          .toList(),
    );
  }
}

// ============ LISTA IN MEMORIA ============
// La Home legge questa lista. All'avvio (su telefono) viene riempita
// dal database in main(). Parte vuota.
final List<CharacterSheet> characters = [];