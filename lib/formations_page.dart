import 'package:flutter/material.dart';
import 'api.dart';
import 'models.dart';

class FormationsPage extends StatefulWidget {
  const FormationsPage({Key? key}) : super(key: key);

  @override
  State<FormationsPage> createState() => _FormationsPageState();
}

class _FormationsPageState extends State<FormationsPage> {
  late Future<List<Formation>> _future;

  @override
  void initState() {
    super.initState();
    _future = fetchFormations();
  }

  void _reload() => setState(() {
    _future = fetchFormations();
  });

  void _msg(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m), backgroundColor: Colors.red));
  }

  Future<void> _openForm([Formation? f]) async {
    final nom = TextEditingController(text: f?.nom ?? '');
    final duree = TextEditingController(text: f?.duree.toString() ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(f == null ? 'Add training' : 'Edit training'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: nom,
              decoration: const InputDecoration(labelText: 'Name')),
          TextField(
              controller: duree,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Duration')),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await saveFormation(Formation(
          id: f?.id, nom: nom.text, duree: int.tryParse(duree.text) ?? 0));
      _reload();
    } catch (e) {
      _msg('Could not save the training');
    }
  }

  Future<void> _delete(Formation f) async {
    try {
      await deleteFormation(f.id!);
      _reload();
    } catch (e) {
      _msg('Could not delete (used by students?)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trainings'), backgroundColor: Colors.purple),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Formation>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(child: Text('Could not load trainings'));
          }
          final list = snap.data!;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final f = list[i];
              return ListTile(
                title: Text(f.nom),
                subtitle: Text('Duration: ${f.duree}'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                      icon: const Icon(Icons.edit), onPressed: () => _openForm(f)),
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _delete(f)),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}