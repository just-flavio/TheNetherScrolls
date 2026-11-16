import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thenetherscrolls/data/character.dart';

// Il dettaglio completo di un incantesimo (scaricato quando lo apri)
class SpellDetail {
  final String name;
  final int level;
  final String school;
  final String castingTime;
  final String range;
  final String duration;
  final String components;
  final List<String> description;
  final List<String> higherLevel;

  SpellDetail({
    required this.name,
    required this.level,
    required this.school,
    required this.castingTime,
    required this.range,
    required this.duration,
    required this.components,
    required this.description,
    required this.higherLevel,
  });

  factory SpellDetail.fromJson(Map<String, dynamic> json) {
    return SpellDetail(
      name: json['name'] ?? '',
      level: json['level'] ?? 0,
      school: json['school']?['name'] ?? '',
      castingTime: json['casting_time'] ?? '',
      range: json['range'] ?? '',
      duration: json['duration'] ?? '',
      components: (json['components'] as List? ?? []).join(', '),
      description: List<String>.from(json['desc'] ?? []),
      higherLevel: List<String>.from(json['higher_level'] ?? []),
    );
  }
}

class SpellApiService {
  // Controlla la versione nella documentazione: dnd5eapi.co
  static const _base = 'https://www.dnd5eapi.co/api/2014/spells';

  // Cache in memoria: scarichi la lista UNA volta per sessione
  static List<SpellRef>? _cachedList;

  // Chiamata 1: la lista (solo nomi e livelli)
  static Future<List<SpellRef>> fetchSpellList() async {
    if (_cachedList != null) return _cachedList!;

    final res = await http
        .get(Uri.parse(_base))
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('Errore del server (${res.statusCode})');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = data['results'] as List;

    _cachedList = results
        .map((e) => SpellRef(
              index: e['index'],
              name: e['name'],
              level: e['level'] ?? 0,
            ))
        .toList();
    return _cachedList!;
  }

  // Chiamata 2: il dettaglio di UN incantesimo
  static Future<SpellDetail> fetchSpell(String index) async {
    final res = await http
        .get(Uri.parse('$_base/$index'))
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('Errore del server (${res.statusCode})');
    }
    return SpellDetail.fromJson(jsonDecode(res.body));
  }
}