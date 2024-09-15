import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  String id;
  int amount;
  String transactionId;
  String monthOfTransaction;
  String course;
  String fullName;
  String coursePath;
  String? state;
  DateTime transactionDateTime;

  Payment(
      {required this.amount,
        this.state,
      required this.transactionId,
      required this.id,
      required this.monthOfTransaction,
        required this.course,
        required this.fullName,
        required this.coursePath,
      required this.transactionDateTime});

  factory Payment.fromMap(Map<String, dynamic> map,String docId) {
    Timestamp? timestamp = map['transactionDateTime'];
    DateTime? dateTime = timestamp?.toDate();
    return Payment(
      state: map['state'],
      coursePath: map['coursePath'],
      course: map['course'],
        fullName: map['fullName'],
        amount: map['amount'] ?? 0,
        transactionId: map['transactionId'] ?? '',
        id: docId,
        monthOfTransaction: map['monthOfTransaction'] ?? '',
        transactionDateTime: dateTime ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'state':state,
      'coursePath':coursePath,
      'course':course,
      'fullName': fullName,
      'amount': amount,
      'transactionId': transactionId,
      'id': id,
      'monthOfTransaction': monthOfTransaction,
      'transactionDateTime': transactionDateTime,
    };
  }
}

