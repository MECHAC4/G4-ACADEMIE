class Payment {
  String paymentId;
  String appUserId;
  String profilId;
  double amount;
  String paymentMethod; // Exemple : "Credit Card", "PayPal", etc.
  String paymentStatus; // Exemple : "Completed", "Pending", "Failed"
  DateTime paymentDate;
  String? transactionId; // ID de la transaction externe (optionnel)
  String? notes; // Notes ou commentaires sur le paiement (optionnel)

  Payment({
    required this.paymentId,
    required this.appUserId,
    required this.profilId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paymentDate,
    this.transactionId,
    this.notes,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      paymentId: map['paymentId'] ?? '',
      appUserId: map['appUserId'] ?? '',
      profilId: map['profilId'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'Unknown',
      paymentStatus: map['paymentStatus'] ?? 'Pending',
      paymentDate: DateTime.parse(map['paymentDate']),
      transactionId: map['transactionId'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentId': paymentId,
      'appUserId': appUserId,
      'profilId': profilId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'paymentDate': paymentDate.toIso8601String(),
      'transactionId': transactionId,
      'notes': notes,
    };
  }
}
