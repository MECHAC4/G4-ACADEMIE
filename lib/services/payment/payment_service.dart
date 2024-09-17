import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g4_academie/payment.dart';

class PaymentService {
  void saveSuccessfulPaymentToFirestore(
      {required Payment payment, required String coursePath}) async {
    List<String> idList = coursePath.split('/');
    await FirebaseFirestore.instance
        .collection('users')
        .doc(idList.first)
        .collection('profil')
        .doc(idList[1])
        .collection('courses')
        .doc(idList.last)
        .collection('request_payment')
        .doc(payment.id)
        .update({'state': 'Reussite'});

    // delete payment in requestPayment

    /*QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(idList.first)
        .collection('profil')
        .doc(idList[1])
        .collection('courses')
        .doc(idList.last)
        .collection('request_payment').where(
      'monthOfTransaction', isEqualTo: monthList[payment.transactionDateTime.month-1]
    ).where('amount', isEqualTo: payment.amount).where('fullName', isEqualTo: payment.fullName).where('course', isEqualTo: payment.course).get();
    if(snapshot.docs.isNotEmpty){
      for( QueryDocumentSnapshot doc in snapshot.docs){
        await doc.reference.delete();
      }
    }*/
  }

  Future<List<Payment>> getSuccessfulPaymentsFromFirestore(
      List<String> coursesPath) async {
    List<Payment> allPayment = [];

    for (int i = 0; i < coursesPath.length; i++) {
      List<String> idList = coursesPath[i].split('/');
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(idList.first)
          .collection('profil')
          .doc(idList[1])
          .collection('courses')
          .doc(idList.last)
          .collection('request_payment')
          .where('state', isNotEqualTo: 'Unpaid')
          .orderBy('transactionDateTime', descending: true)
          .get();

      allPayment.addAll(snapshot.docs.map(
        (e) {
          final doc = e.data() as Map<String, dynamic>;
          return Payment.fromMap({
            'fullName': doc['fullName'],
            'course': doc['course'],
            'coursePath': doc['coursePath'],
            'transactionId': doc['transactionId'],
            'monthOfTransaction': doc['monthOfTransaction'],
            'amount': doc['amount'],
            'transactionDateTime': doc['transactionDateTime']
          }, e.id);
        },
      ).toList());
    }

    return allPayment;
  }

  Future<List<Payment>> getRequestPaymentsFromFirestore(
      List<String> coursesPath) async {
    List<Payment> allPayment = [];

    for (int i = 0; i < coursesPath.length; i++) {
      List<String> idList = coursesPath[i].split('/');
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(idList.first)
          .collection('profil')
          .doc(idList[1])
          .collection('courses')
          .doc(idList.last)
          .collection('request_payment')
          .where('state', isEqualTo: 'Unpaid')
          .orderBy('transactionDateTime', descending: true)
          .get();

      allPayment.addAll(snapshot.docs.map(
        (e) {
          final doc = e.data() as Map<String, dynamic>;
          return Payment.fromMap(doc, e.id);
        },
      ).toList());
    }
    return allPayment;
  }

  Future<void> saveRequestForPayment(
      Payment payment, String paymentMethod, String phoneNumber) async {
    Map<String, dynamic> saveInfo = payment.toMap();
    saveInfo['paymentMethod'] = paymentMethod;
    saveInfo['phoneNumber'] = phoneNumber;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(payment.coursePath.split('/').first)
        .collection('profil')
        .doc(payment.coursePath.split('/')[1])
        .collection('courses')
        .doc(payment.coursePath.split('/').last)
        .collection('request_payment')
        .doc(payment.id)
        .update({'state': 'Attente', 'transactionDateTime': DateTime.now()});

    await FirebaseFirestore.instance
        .collection('request_for_payment')
        .add(saveInfo);
  }
}
