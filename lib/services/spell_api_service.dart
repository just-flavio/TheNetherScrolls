// ===== IMPORT =====
import 'dart:convert'; // jsonDecode: testo JSON -> Map/List
import 'package:http/http.dart' as http; // chiamate a internet ("as http" = le chiamo http.get)
import 'package:thenetherscrolls/data/character.dart'; // contiene SpellRef

// Il dettaglio completo di un incantesimo.
// Si scarica solo quando apri un incantesimo (non viene salvato nel personaggio).
class SpellDetail {
  final String name; // es. "Fireball"
  final int level; // 0 = trucchetto
  final String school; // scuola di magia, es. "Evocation"
  final String castingTime; // tempo di lancio, es. "1 action"
  final String range; // gittata, es. "150 feet"
  final String duration; // durata, es. "Instantaneous"
  final String components; // componenti, es. "V, S, M"
  final List<String> description; // descrizione: una lista di paragrafi
  final List<String> higherLevel; // effetto a livelli superiori (può essere vuota)

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

  // factory = costruisce uno SpellDetail partendo dal JSON dell'API.
  // "?? valore" = se il campo manca nel JSON, uso un valore di riserva.
  factory SpellDetail.fromJson(Map<String, dynamic> json) {
    return SpellDetail(
      name: json['name'] ?? '',
      level: json['level'] ?? 0,
      // la scuola arriva come oggetto {"name": "Evocation"}: "?." evita errori se manca
      school: json['school']?['name'] ?? '',
      castingTime: json['casting_time'] ?? '', // l'API usa "casting_time" (con underscore)
      range: json['range'] ?? '',
      duration: json['duration'] ?? '',
      // i componenti arrivano come lista ["V","S","M"]: li unisco in "V, S, M"
      components: (json['components'] as List? ?? []).join(', '),
      // List<String>.from = converte la lista generica in lista di testi
      description: List<String>.from(json['desc'] ?? []),
      higherLevel: List<String>.from(json['higher_level'] ?? []),
    );
  }
}

// Classe che parla con l'API. Metodi "static": si usano senza creare un oggetto,
// es. SpellApiService.fetchSpellList()
class SpellApiService {
  // Indirizzo base dell'API. Se dà errore 404, controlla l'URL su dnd5eapi.co
  static const _base = 'https://www.dnd5eapi.co/api/2014/spells';

  // Cache in memoria: la lista si scarica UNA volta per sessione.
  // null = non ancora scaricata. Si perde alla chiusura dell'app.
  static List<SpellRef>? _cachedList;

  // ===== CHIAMATA 1: la lista di tutti gli incantesimi (solo nomi) =====
  static Future<List<SpellRef>> fetchSpellList() async {
    // Se l'ho già scaricata, la restituisco subito
    if (_cachedList != null) return _cachedList!;

    // Chiamata a internet. timeout = dopo 10 secondi si arrende con un errore.
    final response = await http
        .get(Uri.parse(_base))
        .timeout(const Duration(seconds: 10));

    // 200 = tutto ok. Altrimenti lancio un errore (lo gestisce il FutureBuilder)
    if (response.statusCode != 200) {
      throw Exception('Errore del server (${response.statusCode})');
    }

    // Il corpo della risposta è testo JSON: lo trasformo in Map
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    // L'API mette gli incantesimi nella chiave "results"
    final results = body['results'] as List;

    // Ogni elemento diventa uno SpellRef. Nota: la lista dell'API di solito
    // NON contiene "level", quindi finisce a 0 (vedi nota sotto).
    _cachedList = results
        .map(
          (item) => SpellRef(
            index: item['index'], // es. "fireball"
            name: item['name'], // es. "Fireball"
            level: item['level'] ?? 0,
          ),
        )
        .toList();
    return _cachedList!;
  }

  // ===== CHIAMATA 2: il dettaglio di UN incantesimo =====
  // index = l'identificativo, es. "fireball"
  static Future<SpellDetail> fetchSpell(String index) async {
    final response = await http
        .get(Uri.parse('$_base/$index')) // es. .../spells/fireball
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Errore del server (${response.statusCode})');
    }
    // Testo JSON -> Map -> SpellDetail
    return SpellDetail.fromJson(jsonDecode(response.body));
  }
}