import 'package:flutter/material.dart';
import 'api.dart';
import 'models.dart';

class ClassesPage extends StatefulWidget {
  const ClassesPage({Key? key}) : super(key: key);

  @override
  State<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  late Future<List<Classe>> _future;
  List<Departement> _depts = [];

  @override
  void initState() {
    super.initState();
    _future = fetchClasses();
    _loadDepts();
  }

  Future<void> _loadDepts() async {
    try {
      final d = await fetchDepartements();
      if (mounted) setState(() => _depts = d);
    } catch (e) {
      _msg('Could not load departments');
    }
  }

  void _reload() => setState(() {
    _future = fetchClasses();
  });

  void _msg(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m), backgroundColor: Colors.red));
  }

  Future<void> _openForm([Classe? c]) async {
    final nom = TextEditingController(text: c?.nomClass ?? '');
    final nbre = TextEditingController(text: c?.nbreEtud.toString() ?? '');
    int? dept = c?.departement?.codDept ??
        (_depts.isNotEmpty ? _depts.first.codDept : null);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(c == null ? 'Add class' : 'Edit class'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: nom,
                  decoration: const InputDecoration(labelText: 'Class name')),
              TextField(
                  controller: nbre,
                  keyboardType: TextInputType.number,
                  decoration:
                  const InputDecoration(labelText: 'Number of students')),
              DropdownButton<int>(
                isExpanded: true,
                value: dept,
                hint: const Text('Department'),
                items: _depts
                    .map((d) => DropdownMenuItem<int>(
                    value: d.codDept, child: Text(d.nomDept)))
                    .toList(),
                onChanged: (v) => setD(() => dept = v),
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
      await saveClasse(Classe(
        codClass: c?.codClass,
        nomClass: nom.text,
        nbreEtud: int.tryParse(nbre.text) ?? 0,
        departement: dept == null ? null : Departement(codDept: dept),
      ));
      _reload();
    } catch (e) {
      _msg('Could not save the class');
    }
  }

  Future<void> _delete(Classe c) async {
    try {
      await deleteClasse(c.codClass!);
      _reload();
    } catch (e) {
      _msg('Could not delete (this class still has students?)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text('Classes'), backgroundColor: Colors.purple),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Classe>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(child: Text('Could not load classes'));
          }
          final list = snap.data!;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final c = list[i];
              return ListTile(
                title: Text(c.nomClass),
                subtitle: Text(
                    '${c.nbreEtud} students  •  ${c.departement?.nomDept ?? ''}'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openForm(c)),
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _delete(c)),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}