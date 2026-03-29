import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreAccount {
  const FirestoreAccount({
    required this.remoteId,
    required this.name,
    required this.type,
    required this.balanceCentavos,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FirestoreAccount.fromMap(String remoteId, Map<String, dynamic> map) {
    return FirestoreAccount(
      remoteId: remoteId,
      name: map['name'] as String,
      type: map['type'] as String,
      balanceCentavos: (map['balanceCentavos'] as num).toInt(),
      color: map['color'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  final String remoteId;
  final String name;
  final String type;
  final int balanceCentavos;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() => {
    'name': name,
    'type': type,
    'balanceCentavos': balanceCentavos,
    'color': color,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
