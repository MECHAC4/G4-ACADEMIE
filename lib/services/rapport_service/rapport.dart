import 'package:cloud_firestore/cloud_firestore.dart';

class Rapport {
  final String path;
  final String idFrom;
  final String idTo;
  final Timestamp timestamp;
  final Map<String, dynamic> content;

  // type: 0 = text, 1 = image
  final int type;

  Rapport(
      {required this.idFrom,
        required this.path,
        required this.idTo,
        required this.timestamp,
        required this.content,
        required this.type});

  Map<String, dynamic> toHashMap() {
    return {
      'idFrom': idFrom,
      'idTo': idTo,
      'timestamp': timestamp,
      'content': content,
      'type': type
    };
  }

  factory Rapport.fromMap(Map<String, dynamic> data, String path){
    return Rapport(
      path: path,
        idFrom: data['idFrom'],
        idTo: data['idTo'],
        timestamp: data['timestamp'],
        content: data['content'],
        type: data['type']
    );
  }
}
