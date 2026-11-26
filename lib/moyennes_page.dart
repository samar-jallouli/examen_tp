import 'package:flutter/material.dart';
import 'api.dart';
import 'models.dart';
import 'student_selector.dart';

class MoyennesPage extends StatefulWidget {
  const MoyennesPage({Key? key}) : super(key: key);

  @override
  State<MoyennesPage> createState() => _MoyennesPageState();
}

class _MoyennesPageState extends State<MoyennesPage> {
  Etudiant? _etud;
  List<Note>? _notes;
  double? _general;

  void _msg(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m), backgroundColor: Colors.red));
  }

  // Module TP (TP1/TP2 saisis) : moyenne de TP1 et TP2
  // Sinon : moyenne de DS et Examen
  double? _moy(Note n) {
    final isTp = n.tp1 != null || n.tp2 != null;
    final a = isTp ? n.tp1 : n.ds;
    final b = isTp ? n.tp2 : n.examen;
    if (a == null && b == null) return null;
    return ((a ?? 0) + (b ?? 0)) / 2;
  }

  Future<void> _calculate() async {
    final e = _etud;
    if (e == null) {
      _msg('Select a student first');
      return;
    }
    try {
      final notes = await fetchNotes(e.id!);
      final codClass = e.classe?.codClass;
      final List<ClassMat> cms =
      codClass == null ? <ClassMat>[] : await fetchClassMats(codClass);
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
      if (!mounted) return;
      setState(() {
        _notes = notes;
        _general = coefs == 0 ? null : sum / coefs;
      });
    } catch (err) {
      _msg('Could not load grades');
    }
  }

  Widget _c(double? v) => Text(v == null ? '-' : fmt(v));

  @override
  Widget build(BuildContext context) {
    final notes = _notes;
    return Scaffold(
      appBar: AppBar(title: const Text('Averages'), backgroundColor: Colors.purple),
      body: SingleChildScrollView(
        child: Column(children: [
          StudentSelector(onChanged: (e) {
            setState(() {
              _etud = e;
              _notes = null;
              _general = null;
            });
          }),
          ElevatedButton(onPressed: _calculate, child: const Text('Calculer')),
          const SizedBox(height: 12),
          if (notes != null) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 18,
                columns: const [
                  DataColumn(label: Text('Module')),
                  DataColumn(label: Text('TP1')),
                  DataColumn(label: Text('TP2')),
                  DataColumn(label: Text('DS')),
                  DataColumn(label: Text('Exam')),
                  DataColumn(label: Text('Moyenne')),
                ],
                rows: notes.map((n) {
                  final m = _moy(n);
                  return DataRow(cells: [
                    DataCell(Text(n.matiere?.codMat ?? '')),
                    DataCell(_c(n.tp1)),
                    DataCell(_c(n.tp2)),
                    DataCell(_c(n.ds)),
                    DataCell(_c(n.examen)),
                    DataCell(Text(m == null ? '-' : m.toStringAsFixed(2),
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                  ]);
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                  'Moyenne générale : ${_general == null ? '-' : _general!.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}