import 'package:flutter/material.dart';

class FieldDef {
  final String label;
  final bool numeric;
  final bool obscure;
  final bool lockedOnEdit;

  const FieldDef(this.label,
      {this.numeric = false, this.obscure = false, this.lockedOnEdit = false});
}

class CrudPage<T> extends StatefulWidget {
  final String title;
  final List<FieldDef> fields;
  final Future<List<T>> Function() load;
  final Future<void> Function(T? old, List<String> values) save;
  final Future<void> Function(T item) remove;
  final List<String> Function(T item) values;
  final String Function(T item) titleOf;
  final String Function(T item) subtitleOf;

  const CrudPage({
    Key? key,
    required this.title,
    required this.fields,
    required this.load,
    required this.save,
    required this.remove,
    required this.values,
    required this.titleOf,
    required this.subtitleOf,
  }) : super(key: key);

  @override
  State<CrudPage<T>> createState() => _CrudPageState<T>();
}

class _CrudPageState<T> extends State<CrudPage<T>> {
  late Future<List<T>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.load();
  }

  void _reload() => setState(() {
    _future = widget.load();
  });

  void _msg(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m), backgroundColor: Colors.red));
  }

  Future<void> _openForm([T? item]) async {
    final n = widget.fields.length;
    final vals = item == null ? List<String>.filled(n, '') : widget.values(item);
    final ctrls = [
      for (var i = 0; i < n; i++) TextEditingController(text: vals[i])
    ];
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item == null ? 'Add' : 'Edit'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            for (var i = 0; i < n; i++)
              TextField(
                controller: ctrls[i],
                readOnly: item != null && widget.fields[i].lockedOnEdit,
                obscureText: widget.fields[i].obscure,
                keyboardType: widget.fields[i].numeric
                    ? TextInputType.number
                    : TextInputType.text,
                decoration: InputDecoration(labelText: widget.fields[i].label),
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
    );
    if (ok != true) return;
    try {
      await widget.save(item, ctrls.map((c) => c.text).toList());
      _reload();
    } catch (e) {
      _msg('Could not save');
    }
  }

  Future<void> _delete(T item) async {
    try {
      await widget.remove(item);
      _reload();
    } catch (e) {
      _msg('Could not delete (still used by other data?)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.purple),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<T>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(child: Text('Could not load data'));
          }
          final list = snap.data!;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final item = list[i];
              return ListTile(
                title: Text(widget.titleOf(item)),
                subtitle: Text(widget.subtitleOf(item)),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openForm(item)),
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _delete(item)),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}