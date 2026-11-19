import 'package:flutter/material.dart';

class IconOption {
  final IconData icon;
  final Color color;
  const IconOption(this.icon, this.color);
}

const List<IconOption> characterIconOptions = [
  IconOption(Icons.shield, Colors.blue),
  IconOption(Icons.local_fire_department, Colors.red),
  IconOption(Icons.bolt, Colors.orange),
  IconOption(Icons.forest, Colors.green),
  IconOption(Icons.auto_fix_high, Colors.purple),
  IconOption(Icons.pets, Colors.brown),
];

class CharacterClass {
  final String name;
  final int level;

  const CharacterClass({required this.name, required this.level});


  Map<String, dynamic> toJson() => {'name': name, 'level': level};

  factory CharacterClass.fromJson(Map<String, dynamic> json) =>
      CharacterClass(name: json['name'] ?? '', level: json['level'] ?? 1);
}

class CharacterEntry {
  String name;
  String description;
  int quantity;

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
// Un incantesimo salvato: solo il minimo, il testo lo scarichi dopo

class CharacterSheet {
  int? id; // assegnato dal database (null finché non è salvato)
  final int iconIndex;
  Widget get characterIcon {
    final i = iconIndex.clamp(0, characterIconOptions.length - 1);
    final o = characterIconOptions[i];
    return Icon(o.icon, color: o.color);
  }

  Map<String, dynamic> toJson() => {
    'iconIndex': iconIndex,
    'name': characterName,
    'race': race,
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
    'savingThrows': savingThrowProficiencies.toList(),
    'skills': skillProficiencies.toList(),
    'items': items.map((e) => e.toJson()).toList(),
    'passives': passives.map((e) => e.toJson()).toList(),
    'spells': spells.map((e) => e.toJson()).toList(),
  };

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
      currentHp: json['currentHp'],
      armorClass: json['armorClass'] ?? 10,
      speed: json['speed'] ?? 30,
      notes: json['notes'] ?? '',
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
  final String characterName;
  final String race;
  List<CharacterClass> classes;
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

  int strength; //Statistiche generali
  int dexterity; //Statistiche generali
  int constitution; //Statistiche generali
  int intelligence; //Statistiche generali
  int wisdom; //Statistiche generali
  int charisma; //Statistiche generali
  int maxHp; //Statistiche generali
  int currentHp; //hp adesso
  int armorClass; //Classe armatura
  int speed; //velocità
  String notes;
  // in cosa il personaggio ha competenza
  final Set<String> savingThrowProficiencies; // es. {'FOR', 'CAR'}
  final Set<String> skillProficiencies; // es. {'Atletica', 'Persuasione'}
  final List<CharacterEntry> items; //gli oggetti che ha un personaggio
  final List<CharacterEntry> passives; // Passive di classe
  final List<SpellRef> spells; //incantesimi conosciuti

  CharacterSheet({
    required this.iconIndex,
    this.id,
    required this.characterName,
    required this.race,
    required this.classes,
    this.strength = 10,
    this.dexterity = 10,
    this.constitution = 10,
    this.intelligence = 10,
    this.wisdom = 10,
    this.charisma = 10,
    this.maxHp = 10,
    int? currentHp,
    this.armorClass = 10,
    this.speed = 30,
    this.notes = "",
    Set<String>? savingThrowProficiencies,
    Set<String>? skillProficiencies,
    List<CharacterEntry>? items,
    List<CharacterEntry>? passives,
    List<SpellRef>? spells,
  }) : currentHp = currentHp ?? maxHp,
       savingThrowProficiencies = savingThrowProficiencies ?? <String>{},
       skillProficiencies = skillProficiencies ?? <String>{},
       items = items ?? <CharacterEntry>[],
       passives = passives ?? <CharacterEntry>[],
       spells = spells ?? <SpellRef>[];

  //ScoreOf => traduce l'abilità nel numero dello switch
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

  int get characterLevel =>
      classes.fold<int>(0, (sum, characterClass) => sum + characterClass.level);

  String get characterClass =>
      classes.map((characterClass) => characterClass.name).join(', ');
}

final List<CharacterSheet> characters = [];
