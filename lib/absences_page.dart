import 'package:flutter/material.dart';
import 'api.dart';
import 'models.dart';
import 'student_selector.dart';

class AbsencesPage extends StatefulWidget {
  const AbsencesPage({Key? key}) : super(key: key);

  @override
  State<AbsencesPage> createState() => _AbsencesPageState();
}

class _AbsencesPageState extends State<AbsencesPage> {
  Etudiant? _etud;
  List<Absence> _abs = [];
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
      setState(() => _abs = []);
      return;
    }
    try {
      final a = await fetchAbsences(_etud!.id!);
      if (mounted) setState(() => _abs = a);
    } catch (e) {
      _msg('Could not load absences');
    }
  }

  Future<void> _openForm([Absence? a]) async {
    String? mat = a?.matiere?.codMat ??
        (_matieres.isNotEmpty ? _matieres.first.codMat : null);
    final date = TextEditingController(
        text: a?.dateA ?? DateTime.now().toIso8601String().substring(0, 10));
    final nha = TextEditingController(text: a == null ? '' : fmt(a.nha));

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(a == null ? 'Add absence' : 'Edit absence'),
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
              TextField(
                controller: date,
                readOnly: true,
                decoration: const InputDecoration(
                    labelText: 'DateA', suffixIcon: Icon(Icons.calendar_today)),
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.tryParse(date.text) ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (d != null) {
                    date.text = d.toIso8601String().substring(0, 10);
                  }
                },
              ),
              TextField(
                controller: nha,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'NHA (hours)'),
              ),
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
    final h = double.tryParse(nha.text.replaceAll(',', '.'));
    if (mat == null || h == null) {
      _msg('Subject and hours are required');
      return;
    }
    try {
      await saveAbsence(Absence(
        id: a?.id,
        etudiant: _etud,
        matiere: Matiere(codMat: mat!),
        dateA: date.text,
        nha: h,
      ));
      await _load();
    } catch (e) {
      _msg('Could not save the absence');
    }
  }

  Future<void> _delete(Absence a) async {
    try {
      await deleteAbsence(a.id!);
      await _load();
    } catch (e) {
      _msg('Could not delete');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text('Absences'), backgroundColor: Colors.purple),
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
              columnSpacing: 20,
              columns: const [
                DataColumn(label: Text('DateA')),
                DataColumn(label: Text('CodMat')),
                DataColumn(label: Text('NHA')),
                DataColumn(label: Text('')),
              ],
              rows: _abs
                  .map((a) => DataRow(cells: [
                DataCell(Text(showDate(a.dateA))),
                DataCell(Text(a.matiere?.codMat ?? '')),
                DataCell(Text(fmt(a.nha))),
                DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openForm(a)),
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _delete(a)),
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