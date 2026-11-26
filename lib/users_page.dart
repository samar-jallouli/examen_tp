import 'package:flutter/material.dart';
import 'api.dart';
import 'crud_page.dart';
import 'models.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CrudPage<Utilisateur>(
      title: 'Users',
      fields: const [FieldDef('Email'), FieldDef('Password', obscure: true)],
      load: fetchUsers,
      save: (old, v) =>
          saveUser(Utilisateur(id: old?.id, email: v[0].trim(), password: v[1])),
      remove: (u) => deleteUser(u.id!),
      values: (u) => [u.email, u.password],
      titleOf: (u) => u.email,
      subtitleOf: (u) => 'id: ${u.id}',
    );
  }
}