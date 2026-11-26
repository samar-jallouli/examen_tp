import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'api.dart';
import 'models.dart';
import 'student_selector.dart';

class TotalAbsencesPage extends StatefulWidget {
  const TotalAbsencesPage({Key? key}) : super(key: key);

  @override
  State<TotalAbsencesPage> createState() => _TotalAbsencesPageState();
}

class _TotalAbsencesPageState extends State<TotalAbsencesPage> {
  Etudiant? _etud;
  Map<String, double>? _totals;

  void _msg(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m), backgroundColor: Colors.red));
  }

  Future<void> _calculate() async {
    if (_etud == null) {
      _msg('Select a student first');
      return;
    }
    try {
      final abs = await fetchAbsences(_etud!.id!);
      final Map<String, double> t = {};
      for (final a in abs) {
        final k = a.matiere?.codMat ?? '?';
        t[k] = (t[k] ?? 0) + a.nha;
      }
      final sorted = Map<String, double>.fromEntries(
          t.entries.toList()..sort((x, y) => x.key.compareTo(y.key)));
      if (mounted) setState(() => _totals = sorted);
    } catch (e) {
      _msg('Could not load absences');
    }
  }

  Widget _chart() {
    final keys = _totals!.keys.toList();
    final spots = [
      for (var i = 0; i < keys.length; i++)
        FlSpot(i.toDouble(), _totals![keys[i]]!)
    ];
    final maxY = _totals!.values.fold<double>(0, (a, b) => a > b ? a : b) + 2;
    return SizedBox(
      height: 240,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 24, 8),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: keys.length > 1 ? (keys.length - 1).toDouble() : 1,
            minY: 0,
            maxY: maxY,
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: true),
            titlesData: FlTitlesData(
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 36)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (value != i.toDouble() || i < 0 || i >= keys.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child:
                      Text(keys[i], style: const TextStyle(fontSize: 12)),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: false,
                barWidth: 3,
                color: Colors.purple,
                dotData: FlDotData(show: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totals = _totals;
    double sum = 0;
    if (totals != null) {
      for (final v in totals.values) {
        sum += v;
      }
    }
    return Scaffold(
      appBar: AppBar(
          title: const Text('Total absences'), backgroundColor: Colors.purple),
      body: SingleChildScrollView(
        child: Column(children: [
          StudentSelector(onChanged: (e) {
            setState(() {
              _etud = e;
              _totals = null;
            });
          }),
          ElevatedButton(onPressed: _calculate, child: const Text('Calculer')),
          const SizedBox(height: 12),
          if (totals != null) ...[
            DataTable(
              columns: const [
                DataColumn(label: Text('CodMat')),
                DataColumn(label: Text('Total NHA')),
              ],
              rows: totals.entries
                  .map((e) => DataRow(cells: [
                DataCell(Text(e.key)),
                DataCell(Text(fmt(e.value))),
              ]))
                  .toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Total des absences / semestre : ${fmt(sum)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            if (totals.isNotEmpty) _chart(),
          ],
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}