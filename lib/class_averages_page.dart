import 'package:flutter/material.dart';
import 'api.dart';
import 'models.dart';

class _Row {
  final String nom;
  final String prenom;
  final double? moyenne;

  _Row(this.nom, this.prenom, this.moyenne);
}

class ClassAveragesPage extends StatefulWidget {
  const ClassAveragesPage({Key? key}) : super(key: key);

  @override
  State<ClassAveragesPage> createState() => _ClassAveragesPageState();
}

class _ClassAveragesPageState extends State<ClassAveragesPage> {
  List<Departement> _depts = [];
  List<Classe> _classes = [];
  int? _dept;
  int? _classe;
  List<_Row> _rows = [];
  bool _loading = false;

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
  double? _moy(Note n) {
    final isTp = n.tp1 != null || n.tp2 != null;
    final a = isTp ? n.tp1 : n.ds;
    final b = isTp ? n.tp2 : n.examen;
    if (a == null && b == null) return null;
    return ((a ?? 0) + (b ?? 0)) / 2;
  }

  String get _classeName {
    for (final c in _classes) {
      if (c.codClass == _classe) return c.nomClass;
    }
    return '';
  }

  String get _deptName {
    for (final d in _depts) {
      if (d.codDept == _dept) return d.nomDept;
    }
    return '';
  }

  Future<void> _init() async {
    try {
      final d = await fetchDepartements();
      if (!mounted) return;
      setState(() => _depts = d);
      if (d.isNotEmpty) await _pickDept(d.first.codDept);
    } catch (e) {
      _msg('Could not load departments');
    }
  }

  Future<void> _pickDept(int? id) async {
    setState(() {
      _dept = id;
      _classes = [];
      _classe = null;
      _rows = [];
    });
    if (id == null) return;
    try {
      final c = await fetchClassesByDept(id);
      if (!mounted) return;
      setState(() => _classes = c);
      if (c.isNotEmpty) await _pickClasse(c.first.codClass);
    } catch (e) {
      _msg('Could not load classes');
    }
  }

  Future<void> _pickClasse(int? id) async {
    setState(() {
      _classe = id;
      _rows = [];
      _loading = id != null;
    });
    if (id == null) return;
    try {
      final etuds = await fetchEtudiants(id);
      final cms = await fetchClassMats(id);
      final rows = <_Row>[];
      for (final e in etuds) {
        final notes = await fetchNotes(e.id!);
        double sum = 0, coefs = 0;
        for (final n in notes) {
          final m = _moy(n);
          if (m == null) continue;
          double coef = 1;
          for (final cm in cms) {
            if (cm.matiere?.codMat == n.matiere?.codMat) coef = cm.coef;
          }
          sum += m * coef;
          coefs += coef;
        }
        rows.add(_Row(e.nom, e.prenom, coefs == 0 ? null : sum / coefs));
      }
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      _msg('Could not load averages');
    }
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

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date = '${_two(now.day)}-${_two(now.month)}-${now.year}';
    return Scaffold(
      appBar: AppBar(
          title: const Text('Class averages'), backgroundColor: Colors.purple),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 12),
            Text('Classe : $_classeName     Département : $_deptName',
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text('Date : $date'),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  border: TableBorder.all(),
                  columns: const [
                    DataColumn(label: Text('Nom')),
                    DataColumn(label: Text('Prenom')),
                    DataColumn(label: Text('Moyenne')),
                  ],
                  rows: _rows
                      .map((r) => DataRow(cells: [
                    DataCell(Text(r.nom)),
                    DataCell(Text(r.prenom)),
                    DataCell(Text(r.moyenne == null
                        ? '-'
                        : r.moyenne!.toStringAsFixed(2))),
                  ]))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}