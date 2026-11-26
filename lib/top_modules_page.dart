import 'package:flutter/material.dart';
import 'exam_api.dart';
import 'models.dart';

class TopModulesPage extends StatefulWidget {
  const TopModulesPage({Key? key}) : super(key: key);

  @override
  State<TopModulesPage> createState() => _TopModulesPageState();
}

class _TopModulesPageState extends State<TopModulesPage> {
  late Future<List<TopMatiere>> _future;

  @override
  void initState() {
    super.initState();
    _future = fetchTopMatieres();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Top 3 modules (absences)'),
          backgroundColor: Colors.purple),
      body: FutureBuilder<List<TopMatiere>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(child: Text('Could not load data'));
          }
          final list = snap.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                border: TableBorder.all(),
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('CodMat')),
                  DataColumn(label: Text('Intitulé')),
                  DataColumn(label: Text('Total NHA')),
                ],
                rows: [
                  for (var i = 0; i < list.length; i++)
                    DataRow(cells: [
                      DataCell(Text('${i + 1}')),
                      DataCell(Text(list[i].codMat)),
                      DataCell(Text(list[i].intMat)),
                      DataCell(Text(fmt(list[i].total))),
                    ]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}