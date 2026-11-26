import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'absences_page.dart';
import 'class_averages_page.dart';
import 'classes_page.dart';
import 'departements_page.dart';
import 'etudiants_page.dart';
import 'formations_page.dart';
import 'matieres_page.dart';
import 'moyennes_page.dart';
import 'notes_page.dart';
import 'top_modules_page.dart';
import 'total_absences_page.dart';
import 'users_page.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  Widget _item(BuildContext context, IconData icon, String text, Widget? page) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepOrange),
      title: Text(text),
      onTap: () {
        Navigator.pop(context);
        if (page != null) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => page));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8A5DE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.purple),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/images/logo.png'),
                  ),
                  Text(
                    'Exercise for groups :\nDSI33 and DSI31',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            _item(context, Icons.apartment, 'Manage departments',
                const DepartementsPage()),
            _item(context, Icons.groups, 'Manage classes', const ClassesPage()),
            _item(context, Icons.school, 'Manage students',
                const EtudiantsPage()),
            _item(context, Icons.menu_book, 'Manage trainings',
                const FormationsPage()),
            _item(context, Icons.book, 'Manage subjects', const MatieresPage()),
            _item(context, Icons.grade, 'Manage grades', const NotesPage()),
            _item(context, Icons.person, 'Manage users', const UsersPage()),
            const Divider(),
            _item(context, Icons.event_busy, 'Absences', const AbsencesPage()),
            _item(context, Icons.bar_chart, 'Total absences',
                const TotalAbsencesPage()),
            _item(context, Icons.calculate, 'Averages', const MoyennesPage()),
            const Divider(),
            _item(context, Icons.table_chart, 'Class averages',
                const ClassAveragesPage()),
            _item(context, Icons.warning_amber, 'Top 3 modules (absences)',
                const TopModulesPage()),
            const Divider(),
            _item(context, Icons.cancel, 'Close', null),
          ],
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Text('Dashboard',
              style: GoogleFonts.pacifico(fontSize: 50, color: Colors.white)),
        ),
      ),
    );
  }
}