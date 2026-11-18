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

final List<CharacterSheet> characters = [
  CharacterSheet(
    characterIcon: const Icon(Icons.shield, color: Colors.blue),
    characterName: 'Arthas',
    race: 'Umano',
    classes: [CharacterClass(name: 'Paladino', level: 15)],
    strength: 18,
    dexterity: 10,
    constitution: 16,
    intelligence: 8,
    wisdom: 12,
    charisma: 16,
    maxHp: 140,
    armorClass: 20,
    speed: 30,
    notes: 'Il Barone ha un anello strano.',
    savingThrowProficiencies: {'SAG', 'CAR'},
    skillProficiencies: {'Atletica', 'Persuasione', 'Intimidire'},
    items: [
      CharacterEntry(name: 'Spada lunga +1', description: '1d8+1 taglienti'),
      CharacterEntry(name: 'Pozione di cura', quantity: 3),
    ],
    passives: [
      CharacterEntry(
        name: 'Aura di protezione',
        description: '+3 ai tiri salvezza degli alleati entro 3 m',
      ),
    ],
    spells: [
      const SpellRef(index: 'bless', name: 'Bless', level: 1),
      const SpellRef(index: 'cure-wounds', name: 'Cure Wounds', level: 1),
    ],
  ),
  CharacterSheet(
    characterIcon: const Icon(Icons.bolt, color: Colors.orange),
    characterName: 'Luna',
    race: 'Elfo',
    classes: [
      CharacterClass(name: 'Ladro', level: 8),
      CharacterClass(name: 'Ranger', level: 12),
    ],
    strength: 10,
    dexterity: 9, // test: l'iniziativa deve mostrare -1
    constitution: 12,
    intelligence: 13,
    wisdom: 14,
    charisma: 10,
    maxHp: 120,
    currentHp: 80, // già ferita, per provare cura e danno
    armorClass: 17,
    skillProficiencies: {'Furtività', 'Percezione'},
  ),
];
