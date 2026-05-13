import 'dart:async';

import 'package:finly/core/db/app_database.dart';
import 'package:finly/features/auth/presentation/providers/auth_providers.dart';
import 'package:finly/features/sync/data/datasources/firestore_datasource.dart';
import 'package:finly/features/sync/data/repositories/sync_download_repository.dart';
import 'package:finly/features/sync/data/repositories/sync_upload_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncState {
  const SyncState({
    this.isSyncing = false,
    this.lastSyncAt,
    this.error,
    this.isSuccess = false,
  });

  final bool isSyncing;
  final DateTime? lastSyncAt;
  final String? error;
  final bool isSuccess;

  SyncState copyWith({
    bool? isSyncing,
    DateTime? lastSyncAt,
    String? error,
    bool? isSuccess,
  }) =>
      SyncState(
        isSyncing: isSyncing ?? this.isSyncing,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        error: error,
        isSuccess: isSuccess ?? this.isSuccess,
      );
}

class SyncNotifier extends Notifier<SyncState> {
  @override
  SyncState build() {
    ref.listen(authStateProvider, (prev, next) {
      final wasGuest = prev?.asData?.value == null;
      final isNowSignedIn = next.asData?.value != null;
      if (wasGuest && isNowSignedIn) unawaited(syncNow());
    });
    return const SyncState();
  }

  Future<void> syncNow() async {
    if (state.isSyncing) return;
    final upload = ref.read(_syncUploadProvider);
    final download = ref.read(_syncDownloadProvider);
    if (upload == null || download == null) {
      state = state.copyWith(error: 'Sign in to sync');
      return;
    }
    state = const SyncState(isSyncing: true);
    try {
      await upload.uploadAll();
      await download.downloadAll();
      state = SyncState(lastSyncAt: DateTime.now(), isSuccess: true);
    } on Exception catch (e) {
      state = SyncState(error: e.toString());
    }
  }
}

final _firestoreDataSourceProvider = Provider<FirestoreDataSource?>((ref) {
  final uid = ref.watch(authStateProvider).asData?.value?.uid;
  return uid != null ? FirestoreDataSource(userId: uid) : null;
});

final _syncUploadProvider = Provider<SyncUploadRepository?>((ref) {
  final remote = ref.watch(_firestoreDataSourceProvider);
  if (remote == null) return null;
  return SyncUploadRepository(
    db: ref.watch(appDatabaseProvider),
    remote: remote,
  );
});

final _syncDownloadProvider = Provider<SyncDownloadRepository?>((ref) {
  final remote = ref.watch(_firestoreDataSourceProvider);
  if (remote == null) return null;
  return SyncDownloadRepository(
    db: ref.watch(appDatabaseProvider),
    remote: remote,
  );
});

final syncNotifierProvider = NotifierProvider<SyncNotifier, SyncState>(
  SyncNotifier.new,
);
