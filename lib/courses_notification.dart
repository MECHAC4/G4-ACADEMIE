class CoursesNotification {
  final String id;
  final String nom;
  final String prenom;
  final String adresse;
  final String classe;
  final String matiere; // Une seule matière
  final String nombreHeuresParSemaine;
  final List<Map<String, dynamic>> emploiDuTemps; // Liste pour l'emploi du temps
  final String eleveId;
  final String compteId;
  bool estVue; // Spécifie si la notification a été vue ou pas
  final DateTime dateEnvoi;
  final int? type;

  CoursesNotification({
    required this.type,
    required this.id,
    required this.nom,
    required this.prenom,
    required this.adresse,
    required this.classe,
    required this.matiere,
    required this.nombreHeuresParSemaine,
    required this.emploiDuTemps,
    required this.eleveId,
    required this.compteId,
    this.estVue = false,
    required this.dateEnvoi,
  });

  // Méthode pour convertir en Map pour Firebase
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'adresse': adresse,
      'classe': classe,
      'matiere': matiere,
      'nombreHeuresParSemaine': nombreHeuresParSemaine,
      'emploiDuTemps': emploiDuTemps,
      'eleveId': eleveId,
      'compteId': compteId,
      'estVue': estVue,
      'dateEnvoi': dateEnvoi.toIso8601String(),
    };
  }

  // Méthode pour créer une instance depuis un Map
  factory CoursesNotification.fromMap(Map<String, dynamic> map, String id) {
    return CoursesNotification(
      type: map['type'],
      id: id,
      nom: map['nom'],
      prenom: map['prenom'],
      adresse: map['adresse'],
      classe: map['classe'],
      matiere: map['matiere'],
      nombreHeuresParSemaine: map['nombreHeuresParSemaine'],
      emploiDuTemps: List<Map<String, dynamic>>.from(map['emploiDuTemps']),
      eleveId: map['eleveId'],
      compteId: map['compteId'],
      estVue: map['estVue'],
      dateEnvoi: DateTime.parse(map['dateEnvoi']),
    );
  }
}
