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

  // --- Expenses ---

  Future<void> upsertExpense(FirestoreExpense expense) =>
      _col('expenses').doc(expense.remoteId).set(expense.toMap());

  Future<void> deleteExpense(String remoteId) =>
      _col('expenses').doc(remoteId).delete();

  Stream<List<FirestoreExpense>> watchExpenses() =>
      _col('expenses').snapshots().map(
        (s) => s.docs
            .map((d) => FirestoreExpense.fromMap(d.id, d.data()))
            .toList(),
      );

  // --- Accounts ---

  Future<void> upsertAccount(FirestoreAccount account) =>
      _col('accounts').doc(account.remoteId).set(account.toMap());

  Future<void> deleteAccount(String remoteId) =>
      _col('accounts').doc(remoteId).delete();

  Stream<List<FirestoreAccount>> watchAccounts() =>
      _col('accounts').snapshots().map(
        (s) => s.docs
            .map((d) => FirestoreAccount.fromMap(d.id, d.data()))
            .toList(),
      );

  // --- Categories ---

  Future<void> upsertCategory(FirestoreCategory category) =>
      _col('categories').doc(category.remoteId).set(category.toMap());

  Future<void> deleteCategory(String remoteId) =>
      _col('categories').doc(remoteId).delete();

  Stream<List<FirestoreCategory>> watchCategories() =>
      _col('categories').snapshots().map(
        (s) => s.docs
            .map((d) => FirestoreCategory.fromMap(d.id, d.data()))
            .toList(),
      );

  // --- Receipts ---

  Future<void> upsertReceipt(FirestoreReceipt receipt) =>
      _col('receipts').doc(receipt.remoteId).set(receipt.toMap());

  Future<void> deleteReceipt(String remoteId) =>
      _col('receipts').doc(remoteId).delete();

  Stream<List<FirestoreReceipt>> watchReceipts() =>
      _col('receipts').snapshots().map(
        (s) => s.docs
            .map((d) => FirestoreReceipt.fromMap(d.id, d.data()))
            .toList(),
      );
}
