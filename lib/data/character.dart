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
  String notes;
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
