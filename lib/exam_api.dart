import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api.dart';

class TopMatiere {
  final String codMat;
  final String intMat;
  final double total;

  TopMatiere(this.codMat, this.intMat, this.total);

  factory TopMatiere.fromMap(Map<String, dynamic> m) => TopMatiere(
    m['codMat'] ?? '',
    m['intMat'] ?? '',
    (m['total'] as num).toDouble(),
  );
}

Future<List<TopMatiere>> fetchTopMatieres() async {
  final res = await http.get(Uri.parse('$baseUrl/absences/top-matieres'));
  if (res.statusCode != 200) throw Exception('Error ${res.statusCode}');
  return (jsonDecode(res.body) as List<dynamic>)
      .map((e) => TopMatiere.fromMap(e))
      .toList();
}