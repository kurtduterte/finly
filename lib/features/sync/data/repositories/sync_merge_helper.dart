class SyncMergeHelper {
  const SyncMergeHelper._();

  static Future<Map<String, int>> merge<R, L>({
    required Future<List<R>> remoteItems,
    required Future<List<L>> localItems,
    required String? Function(L) localRemoteId,
    required int Function(L) localId,
    required String Function(R) remoteId,
    required DateTime Function(R) remoteUpdatedAt,
    required DateTime Function(L) localUpdatedAt,
    required Future<void> Function(L, R) onUpdate,
    required Future<int> Function(R) onInsert,
  }) async {
    final remote = await remoteItems;
    final local = await localItems;

    final idMap = <String, int>{};
    final byRemoteId = <String, L>{};

    for (final localItem in local) {
      final id = localRemoteId(localItem);
      if (id == null) continue;
      idMap[id] = localId(localItem);
      byRemoteId[id] = localItem;
    }

    for (final remoteItem in remote) {
      final id = remoteId(remoteItem);
      final localItem = byRemoteId[id];
      if (localItem == null) {
        idMap[id] = await onInsert(remoteItem);
        continue;
      }

      idMap[id] = localId(localItem);
      if (remoteUpdatedAt(remoteItem).isAfter(localUpdatedAt(localItem))) {
        await onUpdate(localItem, remoteItem);
      }
    }

    return idMap;
  }
}
