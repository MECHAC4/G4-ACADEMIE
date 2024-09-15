
class Cours {
  String? courseId;
  String adresse;
  String appUserId;
  String profilId;
  String subject;
  String state;
  String studentID;
  String studentFullName;
  String? teacherFullName;
  String? teacherID;
  List<Map<String, String>>? weekDuration;
  String? hoursPerWeek;
  String? startMonth;
  String? endMonth;
  int? price;

  Cours({
    this.courseId,
    this.price,
    required this.adresse,
    required this.appUserId,
    required this.profilId,
    required this.subject,
    this.teacherFullName,
    this.teacherID,
    this.endMonth,
    this.startMonth,
    required this.studentFullName,
    required this.studentID,
    this.weekDuration,
    this.hoursPerWeek,
    required this.state,
  });

  factory Cours.fromMap(Map<String, dynamic> map, String id) {
    //print("Valeur reçue : $map");

    List<Map<String, String>>? convertWeekDuration(dynamic value) {
      if (value == null) return null;

      try {
        return List<Map<String, String>>.from(value.map((e) {
          return Map<String, String>.from(e as Map<String, dynamic>);
        }));
      } catch (e) {
        //debugPrint("Erreur de conversion pour weekDuration : $e");
        return null;
      }
    }

    return Cours(
      courseId: id,
      price: map['price'],
      adresse: map['adresse'] ?? '',
      appUserId: map['appUserId'] ?? '',
      profilId: map['profilId'] ?? '',
      subject: map['subject'] ?? '',
      studentFullName: map['studentFullName'] ?? '',
      studentID: map['studentID'] ?? '',
      state: map['state'] ?? 'Non spécifié',
      endMonth: map['endMonth'] ?? '',
      hoursPerWeek: map['hoursPerWeek'],
      startMonth: map['startMonth'] ?? '',
      teacherFullName: map['teacherFullName'],
      teacherID: map['teacherID'],
      weekDuration: convertWeekDuration(map['weekDuration']),
    );
  }
}
