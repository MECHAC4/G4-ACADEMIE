import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g4_academie/services/rapport_service/rapport.dart';

class RapportDatabaseService {

  List<Rapport> _rapportListFromSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    print("Nombre de rapport:${snapshot.size}");
    return snapshot.docs.map((doc) {
      return _rapportFromSnapshot(doc);
    }).toList();
  }

  Rapport _rapportFromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data();
    if (data == null) throw Exception("rapport non trouvé");
    return Rapport.fromMap(data, snapshot.reference.path);
  }

  Stream<List<Rapport>> getRapport(String groupChatId, int limit) {
    return FirebaseFirestore.instance
        .collection('rapports')
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots().map(_rapportListFromSnapshot);
  }

  void onSendRapport(String groupChatId, Rapport rapport) {
    var documentReference = FirebaseFirestore.instance
        .collection('rapports')
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(documentReference,rapport.toHashMap());
    });
  }
}
