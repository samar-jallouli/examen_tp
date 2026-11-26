String fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

String showDate(String iso) {
  final p = iso.split('-');
  return p.length == 3 ? '${p[2]}-${p[1]}-${p[0]}' : iso;
}

double? _d(dynamic v) => v == null ? null : (v as num).toDouble();

class Departement {
  int? codDept;
  String nomDept;

  Departement({this.codDept, this.nomDept = ''});

  factory Departement.fromMap(Map<String, dynamic> m) =>
      Departement(codDept: m['codDept'], nomDept: m['nomDept'] ?? '');

  Map<String, dynamic> toMap() => {'codDept': codDept, 'nomDept': nomDept};
}

class Classe {
  int? codClass;
  int nbreEtud;
  String nomClass;
  Departement? departement;

  Classe({
    this.codClass,
    this.nbreEtud = 0,
    this.nomClass = '',
    this.departement,
  });

  factory Classe.fromMap(Map<String, dynamic> m) => Classe(
    codClass: m['codClass'],
    nbreEtud: m['nbreEtud'] ?? 0,
    nomClass: m['nomClass'] ?? '',
    departement: m['departement'] != null
        ? Departement.fromMap(m['departement'])
        : null,
  );

  Map<String, dynamic> toMap() => {
    'codClass': codClass,
    'nbreEtud': nbreEtud,
    'nomClass': nomClass,
    'departement':
    departement == null ? null : {'codDept': departement!.codDept},
  };
}

class Formation {
  int? id;
  int duree;
  String nom;

  Formation({this.id, this.duree = 0, this.nom = ''});

  factory Formation.fromMap(Map<String, dynamic> m) => Formation(
    id: m['id'],
    duree: m['duree'] ?? 0,
    nom: m['nom'] ?? '',
  );

  Map<String, dynamic> toMap() => {'id': id, 'duree': duree, 'nom': nom};
}

class Etudiant {
  int? id;
  String nce;
  String nom;
  String prenom;
  String dateNais; // format yyyy-MM-dd
  String lieuNais;
  Classe? classe;
  Formation? formation;

  Etudiant({
    this.id,
    this.nce = '',
    this.nom = '',
    this.prenom = '',
    this.dateNais = '',
    this.lieuNais = '',
    this.classe,
    this.formation,
  });

  factory Etudiant.fromMap(Map<String, dynamic> m) {
    final d = (m['dateNais'] ?? '').toString();
    return Etudiant(
      id: m['id'],
      nce: m['nce'] ?? '',
      nom: m['nom'] ?? '',
      prenom: m['prenom'] ?? '',
      dateNais: d.length >= 10 ? d.substring(0, 10) : '',
      lieuNais: m['lieuNais'] ?? '',
      classe: m['classe'] != null ? Classe.fromMap(m['classe']) : null,
      formation:
      m['formation'] != null ? Formation.fromMap(m['formation']) : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'nce': nce.isEmpty ? null : nce,
    'nom': nom,
    'prenom': prenom,
    'dateNais': dateNais.isEmpty ? null : dateNais,
    'lieuNais': lieuNais,
    'classe': classe == null ? null : {'codClass': classe!.codClass},
    'formation': formation == null ? null : {'id': formation!.id},
  };
}

class Matiere {
  String codMat;
  String intMat;
  String description;

  Matiere({this.codMat = '', this.intMat = '', this.description = ''});

  factory Matiere.fromMap(Map<String, dynamic> m) => Matiere(
    codMat: m['codMat'] ?? '',
    intMat: m['intMat'] ?? '',
    description: m['description'] ?? '',
  );

  Map<String, dynamic> toMap() =>
      {'codMat': codMat, 'intMat': intMat, 'description': description};
}

class Absence {
  int? id;
  Etudiant? etudiant;
  Matiere? matiere;
  String dateA; // format yyyy-MM-dd
  double nha;

  Absence({this.id, this.etudiant, this.matiere, this.dateA = '', this.nha = 0});

  factory Absence.fromMap(Map<String, dynamic> m) {
    final d = (m['dateA'] ?? '').toString();
    return Absence(
      id: m['id'],
      etudiant: m['etudiant'] != null ? Etudiant.fromMap(m['etudiant']) : null,
      matiere: m['matiere'] != null ? Matiere.fromMap(m['matiere']) : null,
      dateA: d.length >= 10 ? d.substring(0, 10) : '',
      nha: _d(m['nha']) ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'etudiant': etudiant == null ? null : {'id': etudiant!.id},
    'matiere': matiere == null ? null : {'codMat': matiere!.codMat},
    'dateA': dateA,
    'nha': nha,
  };
}

class Note {
  int? id;
  Etudiant? etudiant;
  Matiere? matiere;
  double? tp1;
  double? tp2;
  double? ds;
  double? examen;

  Note({
    this.id,
    this.etudiant,
    this.matiere,
    this.tp1,
    this.tp2,
    this.ds,
    this.examen,
  });

  factory Note.fromMap(Map<String, dynamic> m) => Note(
    id: m['id'],
    etudiant:
    m['etudiant'] != null ? Etudiant.fromMap(m['etudiant']) : null,
    matiere: m['matiere'] != null ? Matiere.fromMap(m['matiere']) : null,
    tp1: _d(m['tp1']),
    tp2: _d(m['tp2']),
    ds: _d(m['ds']),
    examen: _d(m['examen']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'etudiant': etudiant == null ? null : {'id': etudiant!.id},
    'matiere': matiere == null ? null : {'codMat': matiere!.codMat},
    'tp1': tp1,
    'tp2': tp2,
    'ds': ds,
    'examen': examen,
  };
}

class ClassMat {
  int? id;
  Matiere? matiere;
  double coef;
  double chsm;

  ClassMat({this.id, this.matiere, this.coef = 1, this.chsm = 0});

  factory ClassMat.fromMap(Map<String, dynamic> m) => ClassMat(
    id: m['id'],
    matiere: m['matiere'] != null ? Matiere.fromMap(m['matiere']) : null,
    coef: _d(m['coef']) ?? 1,
    chsm: _d(m['chsm']) ?? 0,
  );
}

class Utilisateur {
  int? id;
  String email;
  String password;

  Utilisateur({this.id, this.email = '', this.password = ''});

  factory Utilisateur.fromMap(Map<String, dynamic> m) => Utilisateur(
    id: m['id'],
    email: m['email'] ?? '',
    password: m['password'] ?? '',
  );

  Map<String, dynamic> toMap() =>
      {'id': id, 'email': email, 'password': password};
}