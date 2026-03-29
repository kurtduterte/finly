import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreCategory {
  const FirestoreCategory({
    required this.remoteId,
    required this.name,
    required this.iconCodepoint,
    required this.color,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FirestoreCategory.fromMap(
    String remoteId,
    Map<String, dynamic> map,
  ) {
    return FirestoreCategory(
      remoteId: remoteId,
      name: map['name'] as String,
      iconCodepoint: (map['iconCodepoint'] as num).toInt(),
      color: map['color'] as String,
      isDefault: map['isDefault'] as bool,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  final String remoteId;
  final String name;
  final int iconCodepoint;
  final String color;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() => {
    'name': name,
    'iconCodepoint': iconCodepoint,
    'color': color,
    'isDefault': isDefault,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
