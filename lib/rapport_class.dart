class RapporClass {
  // Attributs obligatoires
  final String id;
  final String date;
  final String studentName;
  final String level;
  final String teacherName;
  final String subject;
  final String theme;
  final String content;
  final String participation;
  final String difficulties;
  final String improvement;
  final String nextCourse;
  final String homework;
  final String parentNote;
  final String studentCoursePath;
  final String teacherCoursePath;
  //final String startTime;

  // Attributs facultatifs
  final String? parentCommentaire;

  // Constructeur
  RapporClass({
    required this.id,
    required this.date,
    required this.studentCoursePath,
    required this.teacherCoursePath,
    required this.teacherName,
    required this.studentName,
    required this.level,
    required this.subject,
    required this.theme,
    required this.content,
    required this.participation,
    required this.difficulties,
    required this.improvement,
    required this.nextCourse,
    required this.homework,
    required this.parentNote,
    this.parentCommentaire,
  });

  // Méthode pour convertir les attributs en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'teacherCoursePath': teacherCoursePath,
      'studentCoursePath': studentCoursePath,
      'teacherName': teacherName,
      'studentName': studentName,
      'level': level,
      'subject': subject,
      'theme': theme,
      'content': content,
      'participation': participation,
      'difficulties': difficulties,
      'improvement': improvement,
      'nextCourse': nextCourse,
      'homework': homework,
      'parentNote': parentNote,
      'parentCommentaire': parentCommentaire,
    };
  }

  factory RapporClass.fromMap(Map<String, dynamic> map, String id) {
    return RapporClass(
      id: id,
      studentCoursePath: map['studentCoursePath'],
      teacherCoursePath: map['teacherCoursePath'],
      date: map['date'],
      studentName: map['studentName'],
      teacherName: map['teacherName'],
      level: map['level'],
      subject: map['subject'],
      theme: map['theme'],
      content: map['content'],
      participation: map['participation'],
      difficulties: map['difficulties'],
      improvement: map['improvement'],
      nextCourse: map['nextCourse'],
      homework: map['homework'],
      parentNote: map['parentNote'],
      parentCommentaire: map['parentCommentaire'],
    );
  }
}