import 'package:cloud_firestore/cloud_firestore.dart';

import '../../payment.dart';


class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Nom de la collection de paiements dans Firestore
  final String paymentCollection = 'payments';

  // Enregistrer un nouveau paiement dans Firestore
  Future<void> addPayment(Payment payment) async {
    try {
      await _firestore
          .collection(paymentCollection)
          .doc(payment.paymentId)
          .set(payment.toMap());
      print("Paiement enregistré avec succès");
    } catch (e) {
      print("Erreur lors de l'enregistrement du paiement : $e");
      throw Exception("Erreur lors de l'enregistrement du paiement");
    }
  }

  // Récupérer tous les paiements depuis Firestore
  Future<List<Payment>> getAllPayments() async {
    try {
      QuerySnapshot snapshot =
      await _firestore.collection(paymentCollection).get();
      List<Payment> payments = snapshot.docs.map((doc) {
        return Payment.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
      return payments;
    } catch (e) {
      print("Erreur lors de la récupération des paiements : $e");
      throw Exception("Erreur lors de la récupération des paiements");
    }
  }

  // Récupérer un paiement spécifique par son ID
  Future<Payment?> getPaymentById(String paymentId) async {
    try {
      DocumentSnapshot doc =
      await _firestore.collection(paymentCollection).doc(paymentId).get();
      if (doc.exists) {
        return Payment.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Erreur lors de la récupération du paiement : $e");
      throw Exception("Erreur lors de la récupération du paiement");
    }
  }

  // Mettre à jour un paiement
  Future<void> updatePayment(Payment payment) async {
    try {
      await _firestore
          .collection(paymentCollection)
          .doc(payment.paymentId)
          .update(payment.toMap());
      print("Paiement mis à jour avec succès");
    } catch (e) {
      print("Erreur lors de la mise à jour du paiement : $e");
      throw Exception("Erreur lors de la mise à jour du paiement");
    }
  }

  // Supprimer un paiement par son ID
  Future<void> deletePayment(String paymentId) async {
    try {
      await _firestore.collection(paymentCollection).doc(paymentId).delete();
      print("Paiement supprimé avec succès");
    } catch (e) {
      print("Erreur lors de la suppression du paiement : $e");
      throw Exception("Erreur lors de la suppression du paiement");
    }
  }

  // Récupérer tous les paiements d'un utilisateur spécifique
  Future<List<Payment>> getPaymentsByUserId(String appUserId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(paymentCollection)
          .where('appUserId', isEqualTo: appUserId)
          .get();
      List<Payment> payments = snapshot.docs.map((doc) {
        return Payment.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
      return payments;
    } catch (e) {
      print("Erreur lors de la récupération des paiements de l'utilisateur : $e");
      throw Exception("Erreur lors de la récupération des paiements de l'utilisateur");
    }
  }

  // Exemple de récupération des paiements par profil ID
  Future<List<Payment>> getPaymentsByProfilId(String profilId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(paymentCollection)
          .where('profilId', isEqualTo: profilId)
          .get();
      List<Payment> payments = snapshot.docs.map((doc) {
        return Payment.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
      return payments;
    } catch (e) {
      print("Erreur lors de la récupération des paiements par profil ID : $e");
      throw Exception("Erreur lors de la récupération des paiements par profil ID");
    }
  }
}
