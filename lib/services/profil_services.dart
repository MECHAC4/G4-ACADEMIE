import 'package:cloud_firestore/cloud_firestore.dart';

import '../profil_class.dart';

class ProfilServices {
  void saveProfileToFirestore(
      Map<String, dynamic> profil, String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference users = firestore.collection('users');

    await users
        .doc(userId)
        .collection('profil')
        .add({
          'isGroup': profil["isGroup"],
          'firstName': profil["firstName"],
          'lastName': profil["lastName"],
          'groupName': profil["groupName"],
          'studentClass': profil["studentClass"],
          'studentCount': profil["studentCount"],
          'adresse': profil["adresse"],
        })
        .then((value) => print("Profil ajouté"))
        .catchError((error) => print("Erreur: $error"));
  }

  Future<List<ProfilClass>> fetchProfiles(String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference users = firestore.collection('users');

    QuerySnapshot snapshot = await users.doc(userId).collection('profil').get();
    final List<ProfilClass> profiles = snapshot.docs
        .map((doc) {
          final value = doc.data() as Map<String, dynamic>;
          return ProfilClass.fromMap({
            "id": doc.id,
            "isGroup": value["isGroup"],
            "firstName": value["isGroup"] ? null : value["firstName"],
            "lastName": value["isGroup"] ? null : value["lastName"],
            "groupName": value["isGroup"] ? value["groupName"] : null,
            "studentClass": value["studentClass"],
            "studentCount": value["isGroup"] ? value["studentCount"] : null,
            "adresse": value["adresse"],
          });
        })
        .toList();
    return profiles;
  }


  Future<ProfilClass?> getProfileById(String userId, String profileId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference users = firestore.collection('users');

    DocumentSnapshot docSnapshot = await users
        .doc(userId)
        .collection('profil')
        .doc(profileId)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      return ProfilClass.fromMap({
        "id": docSnapshot.id,
        "isGroup": data["isGroup"],
        "firstName": data["isGroup"] ? null : data["firstName"],
        "lastName": data["isGroup"] ? null : data["lastName"],
        "groupName": data["isGroup"] ? data["groupName"] : null,
        "studentClass": data["studentClass"],
        "studentCount": data["isGroup"] ? data["studentCount"] : null,
        "adresse": data["adresse"],
      });
    } else {
      return null;
    }
  }



}
