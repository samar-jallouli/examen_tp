import 'package:flutter/material.dart';
import 'api.dart';
import 'models.dart';

class EtudiantsPage extends StatefulWidget {
  const EtudiantsPage({Key? key}) : super(key: key);

  @override
  State<EtudiantsPage> createState() => _EtudiantsPageState();
}

class _EtudiantsPageState extends State<EtudiantsPage> {
  List<Classe> _classes = [];
  List<Formation> _formations = [];
  List<Etudiant> _etudiants = [];
  int? _selectedClass;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _msg(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m), backgroundColor: Colors.red));
  }

  Future<void> _init() async {
    try {
      _classes = await fetchClasses();
      _formations = await fetchFormations();
      if (_classes.isNotEmpty) {
        _selectedClass = _classes.first.codClass;
        await _loadEtudiants();
      }
    } catch (e) {
      _msg('Could not load data');
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadEtudiants() async {
    if (_selectedClass == null) return;
    try {
      final list = await fetchEtudiants(_selectedClass!);
      if (mounted) setState(() => _etudiants = list);
    } catch (e) {
      _msg('Could not load students');
    }
  }

  Future<void> _openForm([Etudiant? e]) async {
    final nce = TextEditingController(text: e?.nce ?? '');
    final nom = TextEditingController(text: e?.nom ?? '');
    final prenom = TextEditingController(text: e?.prenom ?? '');
    final lieu = TextEditingController(text: e?.lieuNais ?? '');
    final date = TextEditingController(text: e?.dateNais ?? '');
    int? formationId = e?.formation?.id;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(e == null ? 'Add student' : 'Edit student'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: nce,
                  decoration: const InputDecoration(labelText: 'NCE (ex: E1)')),
              TextField(
                  controller: nom,
                  decoration: const InputDecoration(labelText: 'Last name')),
              TextField(
                  controller: prenom,
                  decoration: const InputDecoration(labelText: 'First name')),
              TextField(
                  controller: lieu,
                  decoration:
                  const InputDecoration(labelText: 'Place of birth')),
              TextField(
                controller: date,
                readOnly: true,
                decoration: const InputDecoration(
                    labelText: 'Birth date',
                    suffixIcon: Icon(Icons.calendar_today)),
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.tryParse(date.text) ?? DateTime(2002),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (d != null) {
                    date.text = d.toIso8601String().substring(0, 10);
                  }
                },
              ),
              DropdownButton<int>(
                isExpanded: true,
                value: formationId,
                hint: const Text('Training'),
                items: _formations
                    .map((f) =>
                    DropdownMenuItem<int>(value: f.id, child: Text(f.nom)))
                    .toList(),
                onChanged: (v) => setD(() => formationId = v),
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

    try {
      await saveEtudiant(Etudiant(
        id: e?.id,
        nce: nce.text.trim(),
        nom: nom.text,
        prenom: prenom.text,
        lieuNais: lieu.text,
        dateNais: date.text,
        classe: _classes.firstWhere((c) => c.codClass == _selectedClass),
        formation: formationId == null
            ? null
            : _formations.firstWhere((f) => f.id == formationId),
      ));
      await _loadEtudiants();
    } catch (err) {
      _msg('Could not save the student (NCE already used?)');
    }
  }

  Future<void> _delete(Etudiant e) async {
    try {
      await deleteEtudiant(e.id!);
      await _loadEtudiants();
    } catch (err) {
      _msg('Could not delete the student');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text('Students'), backgroundColor: Colors.purple),
      floatingActionButton: _selectedClass == null
          ? null
          : FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              const Text('Classe : ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _selectedClass,
                  hint: const Text('Code Classe'),
                  items: _classes
                      .map((c) => DropdownMenuItem<int>(
                      value: c.codClass, child: Text(c.nomClass)))
                      .toList(),
                  onChanged: (v) {
                    setState(() => _selectedClass = v);
                    _loadEtudiants();
                  },
                ),
              ),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: _etudiants.isEmpty
                ? const Center(child: Text('No students in this class'))
                : ListView.builder(
              itemCount: _etudiants.length,
              itemBuilder: (context, i) {
                final e = _etudiants[i];
                return ListTile(
                  title: Text('${e.nce} - ${e.nom} ${e.prenom}'),
                  subtitle: Text(
                      '${showDate(e.dateNais)}  •  ${e.lieuNais}'),
                  trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _openForm(e)),
                        IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () => _delete(e)),
                      ]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}