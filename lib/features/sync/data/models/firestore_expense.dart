import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreExpense {
  const FirestoreExpense({
    required this.remoteId,
    required this.amountCentavos,
    required this.description,
    required this.date,
    required this.categoryRemoteId,
    required this.accountRemoteId,
    required this.updatedAt,
    this.receiptRemoteId,
  });

  factory FirestoreExpense.fromMap(String remoteId, Map<String, dynamic> map) {
    return FirestoreExpense(
      remoteId: remoteId,
      amountCentavos: (map['amountCentavos'] as num).toInt(),
      description: map['description'] as String,
      date: (map['date'] as Timestamp).toDate(),
      categoryRemoteId: map['categoryRemoteId'] as String,
      accountRemoteId: map['accountRemoteId'] as String,
      receiptRemoteId: map['receiptRemoteId'] as String?,
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  final String remoteId;
  final int amountCentavos;
  final String description;
  final DateTime date;
  final String categoryRemoteId;
  final String accountRemoteId;
  final String? receiptRemoteId;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() => {
    'amountCentavos': amountCentavos,
    'description': description,
    'date': Timestamp.fromDate(date),
    'categoryRemoteId': categoryRemoteId,
    'accountRemoteId': accountRemoteId,
    'receiptRemoteId': receiptRemoteId,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
