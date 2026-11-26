import 'package:flutter/material.dart';
import 'api.dart';
import 'crud_page.dart';
import 'models.dart';

class DepartementsPage extends StatelessWidget {
  const DepartementsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CrudPage<Departement>(
      title: 'Departments',
      fields: const [FieldDef('Department name')],
      load: fetchDepartements,
      save: (old, v) =>
          saveDepartement(Departement(codDept: old?.codDept, nomDept: v[0])),
      remove: (d) => deleteDepartement(d.codDept!),
      values: (d) => [d.nomDept],
      titleOf: (d) => d.nomDept,
      subtitleOf: (d) => 'Code: ${d.codDept}',
    );
  }
}