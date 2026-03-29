import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreReceipt {
  const FirestoreReceipt({
    required this.remoteId,
    required this.imagePath,
    required this.createdAt,
    required this.updatedAt,
    this.aiRawResponse,
    this.extractedAmountCentavos,
    this.extractedMerchant,
  });

  factory FirestoreReceipt.fromMap(String remoteId, Map<String, dynamic> map) {
    return FirestoreReceipt(
      remoteId: remoteId,
      imagePath: map['imagePath'] as String,
      aiRawResponse: map['aiRawResponse'] as String?,
      extractedAmountCentavos:
          (map['extractedAmountCentavos'] as num?)?.toInt(),
      extractedMerchant: map['extractedMerchant'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  final String remoteId;
  final String imagePath;
  final String? aiRawResponse;
  final int? extractedAmountCentavos;
  final String? extractedMerchant;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() => {
    'imagePath': imagePath,
    'aiRawResponse': aiRawResponse,
    'extractedAmountCentavos': extractedAmountCentavos,
    'extractedMerchant': extractedMerchant,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
