import 'package:flutter/material.dart';

class CharacterClass {
  final String name;
  final int level;

  const CharacterClass({required this.name, required this.level});
}

// Un oggetto O una passiva: nome + testo libero
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

class CharacterSheet {
  final Widget characterIcon;
  final String characterName;
  final String race;
  final List<CharacterClass> classes;

  int strength;
  int dexterity;
  int constitution;
  int intelligence;
  int wisdom;
  int charisma;
  int maxHp;
  int currentHp;
  int armorClass;
  int speed; // NUOVO: velocità in metri o piedi, come preferisci

  // NUOVO: in cosa il personaggio ha competenza
  final Set<String> savingThrowProficiencies; // es. {'FOR', 'CAR'}
  final Set<String> skillProficiencies; // es. {'Atletica', 'Persuasione'}
  final List<CharacterEntry> items; // NUOVO
  final List<CharacterEntry> passives; // NUOVO
  final List<SpellRef> spells;

  CharacterSheet({
    required this.characterIcon,
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

final List<CharacterSheet> characters = [
  CharacterSheet(
    characterIcon: const Icon(Icons.shield, color: Colors.blue),
    characterName: 'Arthas',
    race: 'Paladino',
    classes: const [CharacterClass(name: 'Paladino', level: 15)],
    strength: 18,
    dexterity: 10,
    constitution: 16,
    intelligence: 8,
    wisdom: 12,
    charisma: 16,
    maxHp: 140,
    armorClass: 20,
  ),
  CharacterSheet(
    characterIcon: const Icon(Icons.local_fire_department, color: Colors.red),
    characterName: 'Drakar',
    race: 'Mago',
    classes: const [CharacterClass(name: 'Mago', level: 20)],
    strength: 8,
    dexterity: 14,
    constitution: 14,
    intelligence: 20,
    wisdom: 12,
    charisma: 10,
    maxHp: 110,
    armorClass: 15,
  ),
  CharacterSheet(
    characterIcon: const Icon(Icons.bolt, color: Colors.orange),
    characterName: 'Luna',
    race: 'Ladro',
    classes: const [
      CharacterClass(name: 'Ladro', level: 8),
      CharacterClass(name: 'Ranger', level: 12),
    ],
    strength: 10,
    dexterity: 9, // test: deve mostrare -1, non 0
    constitution: 12,
    intelligence: 13,
    wisdom: 14,
    charisma: 10,
    maxHp: 120,
    armorClass: 17,
  ),
  CharacterSheet(
    characterIcon: const Icon(Icons.forest, color: Colors.green),
    characterName: 'Thorin',
    race: 'Druido',
    classes: const [CharacterClass(name: 'Druido', level: 12)],
    strength: 10,
    dexterity: 12,
    constitution: 14,
    intelligence: 11,
    wisdom: 18,
    charisma: 10,
    maxHp: 90,
    armorClass: 16,
  ),
  CharacterSheet(
    characterIcon: const Icon(Icons.access_alarm_outlined, color: Colors.grey),
    characterName: 'Grom',
    race: 'Guerriero',
    classes: const [CharacterClass(name: 'Guerriero', level: 20)],
    strength: 20,
    dexterity: 12,
    constitution: 18,
    intelligence: 8,
    wisdom: 10,
    charisma: 8,
    maxHp: 220,
    armorClass: 19,
  ),
];
