// Modificatore: (valore - 10) / 2, arrotondato per DIFETTO
int modifier(int score) => ((score - 10) / 2).floor();

// Bonus competenza in base al livello
int proficiencyBonus(int level) => ((level - 1) / 4).floor() + 2;

// Per mostrare il segno: 3 -> "+3", -1 -> "-1", 0 -> "+0"
String signed(int n) => n >= 0 ? '+$n' : '$n';