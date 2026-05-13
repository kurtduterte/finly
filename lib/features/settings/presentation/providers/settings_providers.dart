import 'dart:async';

import 'package:finly/features/auth/presentation/providers/auth_providers.dart';
import 'package:finly/features/sync/data/datasources/firestore_datasource.dart';
import 'package:finly/features/sync/presentation/providers/sync_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final profileExtrasProvider =
    AsyncNotifierProvider<ProfileExtrasNotifier, ProfileExtras>(
      ProfileExtrasNotifier.new,
    );

final syncEnabledProvider = AsyncNotifierProvider<SyncEnabledNotifier, bool>(
  SyncEnabledNotifier.new,
);

final _firestoreSettingsProvider = Provider<FirestoreDataSource?>((ref) {
  final uid = ref.watch(authStateProvider).asData?.value?.uid;
  return uid != null ? FirestoreDataSource(userId: uid) : null;
});

class ProfileExtras {
  const ProfileExtras({this.phone = '', this.address = ''});

  final String phone;
  final String address;

  ProfileExtras copyWith({String? phone, String? address}) => ProfileExtras(
    phone: phone ?? this.phone,
    address: address ?? this.address,
  );
}

class ProfileExtrasNotifier extends AsyncNotifier<ProfileExtras> {
  static const _phoneKeyBase = 'profile_phone';
  static const _addressKeyBase = 'profile_address';

  @override
  Future<ProfileExtras> build() async {
    final uid = ref.watch(authStateProvider).asData?.value?.uid;
    final prefs = await SharedPreferences.getInstance();
    final phoneKey = _scopedPrefsKey(_phoneKeyBase, uid);
    final addressKey = _scopedPrefsKey(_addressKeyBase, uid);
    return ProfileExtras(
      phone: prefs.getString(phoneKey) ?? '',
      address: prefs.getString(addressKey) ?? '',
    );
  }

  Future<void> save({required String phone, required String address}) async {
    final uid = ref.read(authStateProvider).asData?.value?.uid;
    final prefs = await SharedPreferences.getInstance();
    final phoneKey = _scopedPrefsKey(_phoneKeyBase, uid);
    final addressKey = _scopedPrefsKey(_addressKeyBase, uid);
    await prefs.setString(phoneKey, phone);
    await prefs.setString(addressKey, address);
    state = AsyncData(ProfileExtras(phone: phone, address: address));
  }
}

class SyncEnabledNotifier extends AsyncNotifier<bool> {
  static const _syncEnabledKeyBase = 'sync_enabled_local';

  @override
  Future<bool> build() async {
    final uid = ref.watch(authStateProvider).asData?.value?.uid;
    final prefs = await SharedPreferences.getInstance();
    final syncEnabledKey = _scopedPrefsKey(_syncEnabledKeyBase, uid);
    final localEnabled = prefs.getBool(syncEnabledKey) ?? false;

    final firestore = ref.read(_firestoreSettingsProvider);
    if (firestore != null) {
      try {
        final remoteEnabled = await firestore.getSyncEnabled();
        await prefs.setBool(syncEnabledKey, remoteEnabled);
        return remoteEnabled;
      } on Exception {
        return localEnabled;
      }
    }

    return localEnabled;
  }

  Future<void> toggle() async {
    final uid = ref.read(authStateProvider).asData?.value?.uid;
    final prefs = await SharedPreferences.getInstance();
    final syncEnabledKey = _scopedPrefsKey(_syncEnabledKeyBase, uid);
    final current = state.asData?.value ?? false;
    final newValue = !current;

    await prefs.setBool(syncEnabledKey, newValue);

    final firestore = ref.read(_firestoreSettingsProvider);
    if (firestore != null) {
      try {
        await firestore.setSyncEnabled(enabled: newValue);
      } on Exception {
        // Continue with local state if Firestore fails
      }
    }

    state = AsyncData(newValue);

    if (newValue) {
      await ref.read(syncNotifierProvider.notifier).syncNow();
    }
  }
}

String _scopedPrefsKey(String baseKey, String? uid) {
  final scope = uid == null || uid.isEmpty
      ? 'guest'
      : uid.replaceAll(RegExp('[^a-zA-Z0-9_]'), '_');
  return '${baseKey}_$scope';
}
