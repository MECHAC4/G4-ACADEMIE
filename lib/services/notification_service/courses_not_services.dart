import 'package:cloud_firestore/cloud_firestore.dart';

import '../../courses_notification.dart';

class CoursesNotificationService {
  final CollectionReference notificationsCollection =
  FirebaseFirestore.instance.collection('notifications');

  // Envoyer une notification
  Future<void> envoyerNotification(CoursesNotification notification) async {
    await notificationsCollection.add(notification.toMap());
  }

  // Récupérer les notifications pour un utilisateur spécifique
  Future<List<CoursesNotification>> getNotificationsForUser(String userId) async {
    QuerySnapshot querySnapshot = await notificationsCollection
        .where('idTo', isEqualTo: userId).orderBy('dateEnvoi', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => CoursesNotification.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }


  Future<List<CoursesNotification>> getAskForUser(String userId) async {
    QuerySnapshot querySnapshot = await notificationsCollection
        .where('idFrom', isEqualTo: userId).orderBy('dateEnvoi', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) {
          return CoursesNotification.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        })
        .toList();
  }


  // Marquer une notification comme vue
  Future<void> marquerCommeVue(String notificationId) async {
    await notificationsCollection.doc(notificationId).update({'estVue': true});
  }
}
