import 'package:flutter/material.dart';
import 'api.dart';
import 'models.dart';
import 'student_selector.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  Etudiant? _etud;
  List<Note> _notes = [];
  List<Matiere> _matieres = [];

  @override
  void initState() {
    super.initState();
    _loadMatieres();
  }

  void _msg(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m), backgroundColor: Colors.red));
  }

  Future<void> _loadMatieres() async {
    try {
      final m = await fetchMatieres();
      if (mounted) setState(() => _matieres = m);
    } catch (e) {
      _msg('Could not load subjects');
    }
  }

  Future<void> _load() async {
    if (_etud == null) {
      setState(() => _notes = []);
      return;
    }
    try {
      final n = await fetchNotes(_etud!.id!);
      if (mounted) setState(() => _notes = n);
    } catch (e) {
      _msg('Could not load grades');
    }
  }

  double? _p(String s) =>
      s.trim().isEmpty ? null : double.tryParse(s.replaceAll(',', '.'));

  String _s(double? v) => v == null ? '' : fmt(v);

  Future<void> _openForm([Note? n]) async {
    String? mat =
        n?.matiere?.codMat ?? (_matieres.isNotEmpty ? _matieres.first.codMat : null);
    final tp1 = TextEditingController(text: _s(n?.tp1));
    final tp2 = TextEditingController(text: _s(n?.tp2));
    final ds = TextEditingController(text: _s(n?.ds));
    final ex = TextEditingController(text: _s(n?.examen));

    Widget num(TextEditingController c, String label) => TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(n == null ? 'Add grades' : 'Edit grades'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButton<String>(
                isExpanded: true,
                value: mat,
                hint: const Text('Subject'),
                items: _matieres
                    .map((m) => DropdownMenuItem<String>(
                    value: m.codMat, child: Text(m.codMat)))
                    .toList(),
                onChanged: (v) => setD(() => mat = v),
              ),
              num(tp1, 'TP1 (if TP module)'),
              num(tp2, 'TP2 (if TP module)'),
              num(ds, 'DS (if course)'),
              num(ex, 'Exam (if course)'),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Save')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    if (mat == null) {
      _msg('Choose a subject');
      return;
    }
    try {
      await saveNote(Note(
        id: n?.id,
        etudiant: _etud,
        matiere: Matiere(codMat: mat!),
        tp1: _p(tp1.text),
        tp2: _p(tp2.text),
        ds: _p(ds.text),
        examen: _p(ex.text),
      ));
      await _load();
    } catch (e) {
      _msg('Could not save the grades');
    }
  }

  Future<void> _delete(Note n) async {
    try {
      await deleteNote(n.id!);
      await _load();
    } catch (e) {
      _msg('Could not delete');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grades'), backgroundColor: Colors.purple),
      floatingActionButton: _etud == null
          ? null
          : FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          StudentSelector(onChanged: (e) {
            setState(() => _etud = e);
            _load();
          }),
          const Divider(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16,
              columns: const [
                DataColumn(label: Text('CodMat')),
                DataColumn(label: Text('TP1')),
                DataColumn(label: Text('TP2')),
                DataColumn(label: Text('DS')),
                DataColumn(label: Text('Exam')),
                DataColumn(label: Text('')),
              ],
              rows: _notes
                  .map((n) => DataRow(cells: [
                DataCell(Text(n.matiere?.codMat ?? '')),
                DataCell(Text(_s(n.tp1))),
                DataCell(Text(_s(n.tp2))),
                DataCell(Text(_s(n.ds))),
                DataCell(Text(_s(n.examen))),
                DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openForm(n)),
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _delete(n)),
                ])),
              ]))
                  .toList(),
            ),
          ),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }
}