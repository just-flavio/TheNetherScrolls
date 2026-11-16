import 'package:flutter/material.dart';
import 'package:thenetherscrolls/data/character.dart';

class CharacterTile extends StatelessWidget {
  final CharacterSheet character;
  final VoidCallback onTap;

  const CharacterTile({
    super.key,
    required this.character,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: character.characterIcon,
      title: Text('${character.characterName} - ${character.race}'),
      subtitle: Text('Livello ${character.characterLevel} - HP ${character.currentHp} / ${character.maxHp}'),
      onTap: onTap,
    );
  }
}