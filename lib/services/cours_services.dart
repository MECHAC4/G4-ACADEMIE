import 'package:cloud_firestore/cloud_firestore.dart';

class CoursServices{

  Future<String> saveCoursToFirestore(Map<String, dynamic> map)async{

    DocumentReference<Map<String, dynamic>> ref = await FirebaseFirestore.instance
        .collection('users')
        .doc(map['appUserId'])
        .collection('profil')
        .doc(map['profilId'])
        .collection('courses')
        .add({
      'adresse':map['adresse'],
      'appUserId': map['appUserId'],
      'profilId': map['profilId'],
      'subject': map['subject'],
      'studentFullName': map['studentFullName'],
      'studentID': map['profilId'],
      'state': map['state'],
      'weekDuration': map['weekDuration'],
      'hoursPerWeek': map['hoursPerWeek'],
    });
    return ref.id;

  }


}
