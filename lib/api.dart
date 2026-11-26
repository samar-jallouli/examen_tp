import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

// Émulateur : 10.0.2.2 ; téléphone réel : IP du PC (ipconfig)
const String baseUrl = "http://10.0.2.2:8081/api";

Future<List<dynamic>> _getList(String path) async {
  final res = await http.get(Uri.parse('$baseUrl$path'));
  if (res.statusCode != 200) throw Exception('Error ${res.statusCode}');
  return jsonDecode(res.body) as List<dynamic>;
}

Future<void> _send(String method, String path, [Object? body]) async {
  final req = http.Request(method, Uri.parse('$baseUrl$path'));
  req.headers['Content-Type'] = 'application/json';
  if (body != null) req.body = jsonEncode(body);
  final res = await http.Response.fromStream(await req.send());
  if (res.statusCode >= 300) throw Exception('Error ${res.statusCode}');
}

// ---- Départements ----
Future<List<Departement>> fetchDepartements() async =>
    (await _getList('/departements')).map((e) => Departement.fromMap(e)).toList();

Future<void> saveDepartement(Departement d) => d.codDept == null
    ? _send('POST', '/departements', d.toMap())
    : _send('PUT', '/departements/${d.codDept}', d.toMap());

Future<void> deleteDepartement(int id) => _send('DELETE', '/departements/$id');

// ---- Classes ----
Future<List<Classe>> fetchClasses() async =>
    (await _getList('/classes')).map((e) => Classe.fromMap(e)).toList();

Future<List<Classe>> fetchClassesByDept(int codDept) async =>
    (await _getList('/classes/departement/$codDept'))
        .map((e) => Classe.fromMap(e))
        .toList();

Future<void> saveClasse(Classe c) => c.codClass == null
    ? _send('POST', '/classes', c.toMap())
    : _send('PUT', '/classes/${c.codClass}', c.toMap());

Future<void> deleteClasse(int id) => _send('DELETE', '/classes/$id');

// ---- Formations ----
Future<List<Formation>> fetchFormations() async =>
    (await _getList('/formations')).map((e) => Formation.fromMap(e)).toList();

Future<void> saveFormation(Formation f) => f.id == null
    ? _send('POST', '/formations', f.toMap())
    : _send('PUT', '/formations/${f.id}', f.toMap());

Future<void> deleteFormation(int id) => _send('DELETE', '/formations/$id');

// ---- Étudiants ----
Future<List<Etudiant>> fetchEtudiants(int codClass) async =>
    (await _getList('/etudiants/classe/$codClass'))
        .map((e) => Etudiant.fromMap(e))
        .toList();

Future<void> saveEtudiant(Etudiant e) => e.id == null
    ? _send('POST', '/etudiants', e.toMap())
    : _send('PUT', '/etudiants/${e.id}', e.toMap());

Future<void> deleteEtudiant(int id) => _send('DELETE', '/etudiants/$id');

// ---- Matières ----
Future<List<Matiere>> fetchMatieres() async =>
    (await _getList('/matieres')).map((e) => Matiere.fromMap(e)).toList();

Future<void> saveMatiere(Matiere m, bool isNew) => isNew
    ? _send('POST', '/matieres', m.toMap())
    : _send('PUT', '/matieres/${m.codMat}', m.toMap());

Future<void> deleteMatiere(String codMat) => _send('DELETE', '/matieres/$codMat');

// ---- ClassMat (coefficients) ----
Future<List<ClassMat>> fetchClassMats(int codClass) async =>
    (await _getList('/classmats/classe/$codClass'))
        .map((e) => ClassMat.fromMap(e))
        .toList();

// ---- Absences ----
Future<List<Absence>> fetchAbsences(int etudiantId) async =>
    (await _getList('/absences/etudiant/$etudiantId'))
        .map((e) => Absence.fromMap(e))
        .toList();

Future<void> saveAbsence(Absence a) => a.id == null
    ? _send('POST', '/absences', a.toMap())
    : _send('PUT', '/absences/${a.id}', a.toMap());

Future<void> deleteAbsence(int id) => _send('DELETE', '/absences/$id');

// ---- Notes ----
Future<List<Note>> fetchNotes(int etudiantId) async =>
    (await _getList('/notes/etudiant/$etudiantId'))
        .map((e) => Note.fromMap(e))
        .toList();

Future<void> saveNote(Note n) => n.id == null
    ? _send('POST', '/notes', n.toMap())
    : _send('PUT', '/notes/${n.id}', n.toMap());

Future<void> deleteNote(int id) => _send('DELETE', '/notes/$id');

// ---- Utilisateurs ----
Future<List<Utilisateur>> fetchUsers() async =>
    (await _getList('/users')).map((e) => Utilisateur.fromMap(e)).toList();

Future<void> saveUser(Utilisateur u) => u.id == null
    ? _send('POST', '/users', u.toMap())
    : _send('PUT', '/users/${u.id}', u.toMap());

Future<void> deleteUser(int id) => _send('DELETE', '/users/$id');