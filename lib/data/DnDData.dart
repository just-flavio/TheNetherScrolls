
const Map<String, String> abilityNames = {
  'FOR': 'Forza',
  'DES': 'Destrezza',
  'COS': 'Costituzione',
  'INT': 'Intelligenza',
  'SAG': 'Saggezza',
  'CAR': 'Carisma',
};

class SkillInfo {
  final String name;
  final String ability; 

  const SkillInfo(this.name, this.ability);
}


const List<SkillInfo> skills = [
  SkillInfo('Acrobazia', 'DES'),
  SkillInfo('Addestrare Animali', 'SAG'),
  SkillInfo('Arcano', 'INT'),
  SkillInfo('Atletica', 'FOR'),
  SkillInfo('Furtività', 'DES'),
  SkillInfo('Indagare', 'INT'),
  SkillInfo('Inganno', 'CAR'),
  SkillInfo('Intimidire', 'CAR'),
  SkillInfo('Intrattenere', 'CAR'),
  SkillInfo('Intuizione', 'SAG'),
  SkillInfo('Medicina', 'SAG'),
  SkillInfo('Natura', 'INT'),
  SkillInfo('Percezione', 'SAG'),
  SkillInfo('Persuasione', 'CAR'),
  SkillInfo('Rapidità di Mano', 'DES'),
  SkillInfo('Religione', 'INT'),
  SkillInfo('Sopravvivenza', 'SAG'),
  SkillInfo('Storia', 'INT'),
];