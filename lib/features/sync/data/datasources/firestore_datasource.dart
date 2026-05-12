import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finly/features/sync/data/models/firestore_account.dart';
import 'package:finly/features/sync/data/models/firestore_category.dart';
import 'package:finly/features/sync/data/models/firestore_expense.dart';
import 'package:finly/features/sync/data/models/firestore_receipt.dart';

class FirestoreDataSource {
  FirestoreDataSource({required this.userId, FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  final String userId;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String name) =>
      _db.collection('users').doc(userId).collection(name);

  Future<void> _upsert(
    String collection,
    String remoteId,
    Map<String, dynamic> data,
  ) => _col(collection).doc(remoteId).set(data);

  Future<void> _delete(String collection, String remoteId) =>
      _col(collection).doc(remoteId).delete();

  Stream<List<T>> _watchCollection<T>(
    String collection,
    T Function(String id, Map<String, dynamic> data) fromMap,
  ) {
    return _col(collection).snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => fromMap(doc.id, doc.data())).toList(),
    );
  }

  Future<void> upsertExpense(FirestoreExpense expense) =>
      _upsert('expenses', expense.remoteId, expense.toMap());

  Future<void> deleteExpense(String remoteId) => _delete('expenses', remoteId);

  Stream<List<FirestoreExpense>> watchExpenses() =>
      _watchCollection('expenses', FirestoreExpense.fromMap);

  Future<void> upsertAccount(FirestoreAccount account) =>
      _upsert('accounts', account.remoteId, account.toMap());

  Future<void> deleteAccount(String remoteId) => _delete('accounts', remoteId);

  Stream<List<FirestoreAccount>> watchAccounts() =>
      _watchCollection('accounts', FirestoreAccount.fromMap);

  Future<void> upsertCategory(FirestoreCategory category) =>
      _upsert('categories', category.remoteId, category.toMap());

  Future<void> deleteCategory(String remoteId) =>
      _delete('categories', remoteId);

  Stream<List<FirestoreCategory>> watchCategories() =>
      _watchCollection('categories', FirestoreCategory.fromMap);

  Future<void> upsertReceipt(FirestoreReceipt receipt) =>
      _upsert('receipts', receipt.remoteId, receipt.toMap());

  Future<void> deleteReceipt(String remoteId) => _delete('receipts', remoteId);

  Stream<List<FirestoreReceipt>> watchReceipts() =>
      _watchCollection('receipts', FirestoreReceipt.fromMap);
}
