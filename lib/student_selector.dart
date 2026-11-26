import 'package:flutter/material.dart';
import 'api.dart';
import 'models.dart';

class StudentSelector extends StatefulWidget {
  final void Function(Etudiant? etudiant) onChanged;

  const StudentSelector({Key? key, required this.onChanged}) : super(key: key);

  @override
  State<StudentSelector> createState() => _StudentSelectorState();
}

class _StudentSelectorState extends State<StudentSelector> {
  List<Departement> _depts = [];
  List<Classe> _classes = [];
  List<Etudiant> _etuds = [];
  int? _dept;
  int? _classe;
  int? _etud;
  final _nom = TextEditingController();
  final _prenom = TextEditingController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _error() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not load data'), backgroundColor: Colors.red));
  }

  void _fill(Etudiant? e) {
    _nom.text = e?.nom ?? '';
    _prenom.text = e?.prenom ?? '';
    widget.onChanged(e);
  }

  Future<void> _init() async {
    try {
      final d = await fetchDepartements();
      if (!mounted) return;
      setState(() => _depts = d);
      if (d.isNotEmpty) await _pickDept(d.first.codDept);
    } catch (e) {
      _error();
    }
  }

  Future<void> _pickDept(int? id) async {
    setState(() {
      _dept = id;
      _classes = [];
      _etuds = [];
      _classe = null;
      _etud = null;
    });
    _fill(null);
    if (id == null) return;
    try {
      final c = await fetchClassesByDept(id);
      if (!mounted) return;
      setState(() => _classes = c);
      if (c.isNotEmpty) await _pickClasse(c.first.codClass);
    } catch (e) {
      _error();
    }
  }

  Future<void> _pickClasse(int? id) async {
    setState(() {
      _classe = id;
      _etuds = [];
      _etud = null;
    });
    _fill(null);
    if (id == null) return;
    try {
      final list = await fetchEtudiants(id);
      if (!mounted) return;
      setState(() => _etuds = list);
      if (list.isNotEmpty) _pickEtud(list.first.id);
    } catch (e) {
      _error();
    }
  }

  void _pickEtud(int? id) {
    setState(() => _etud = id);
    Etudiant? found;
    for (final x in _etuds) {
      if (x.id == id) found = x;
    }
    _fill(found);
  }

  Widget _dd(String label, int? value, List<DropdownMenuItem<int>> items,
      void Function(int?) onChanged) {
    return Row(children: [
      SizedBox(
          width: 110,
          child:
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
      Expanded(
        child: DropdownButton<int>(
          isExpanded: true,
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        _dd(
            'Département :',
            _dept,
            _depts
                .map((d) => DropdownMenuItem<int>(
                value: d.codDept, child: Text(d.nomDept)))
                .toList(),
            _pickDept),
        _dd(
            'Classe :',
            _classe,
            _classes
                .map((c) => DropdownMenuItem<int>(
                value: c.codClass, child: Text(c.nomClass)))
                .toList(),
            _pickClasse),
        _dd(
            'Etudiant :',
            _etud,
            _etuds
                .map((e) => DropdownMenuItem<int>(
                value: e.id, child: Text('${e.nce} - ${e.nom}')))
                .toList(),
            _pickEtud),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _nom,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _prenom,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Prénom'),
            ),
          ),
        ]),
      ]),
    );
  }
}