import 'package:flutter/material.dart';
import 'api.dart';
import 'crud_page.dart';
import 'models.dart';

class MatieresPage extends StatelessWidget {
  const MatieresPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CrudPage<Matiere>(
      title: 'Subjects',
      fields: const [
        FieldDef('Code (ex: AFCP)', lockedOnEdit: true),
        FieldDef('Title'),
        FieldDef('Description'),
      ],
      load: fetchMatieres,
      save: (old, v) => saveMatiere(
          Matiere(codMat: v[0].trim(), intMat: v[1], description: v[2]),
          old == null),
      remove: (m) => deleteMatiere(m.codMat),
      values: (m) => [m.codMat, m.intMat, m.description],
      titleOf: (m) => '${m.codMat} - ${m.intMat}',
      subtitleOf: (m) => m.description,
    );
  }
}