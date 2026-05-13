import 'dart:async';

import 'package:finly/features/auth/presentation/providers/auth_providers.dart';
import 'package:finly/features/sync/data/datasources/firestore_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final profileExtrasProvider =
    AsyncNotifierProvider<ProfileExtrasNotifier, ProfileExtras>(
  ProfileExtrasNotifier.new,
);

final syncEnabledProvider =
    AsyncNotifierProvider<SyncEnabledNotifier, bool>(SyncEnabledNotifier.new);

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
  static const _phoneKey = 'profile_phone';
  static const _addressKey = 'profile_address';

  @override
  Future<ProfileExtras> build() async {
    final prefs = await SharedPreferences.getInstance();
    return ProfileExtras(
      phone: prefs.getString(_phoneKey) ?? '',
      address: prefs.getString(_addressKey) ?? '',
    );
  }

  Future<void> save({required String phone, required String address}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneKey, phone);
    await prefs.setString(_addressKey, address);
    state = AsyncData(ProfileExtras(phone: phone, address: address));
  }
}

class SyncEnabledNotifier extends AsyncNotifier<bool> {
  static const _syncEnabledKey = 'sync_enabled_local';

  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    final localEnabled = prefs.getBool(_syncEnabledKey) ?? false;

    final firestore = ref.read(_firestoreSettingsProvider);
    if (firestore != null) {
      try {
        final remoteEnabled = await firestore.getSyncEnabled();
        await prefs.setBool(_syncEnabledKey, remoteEnabled);
        return remoteEnabled;
      } on Exception {
        return localEnabled;
      }
    }

    return localEnabled;
  }

  Future<void> toggle() async {
    final prefs = await SharedPreferences.getInstance();
    final current = state.asData?.value ?? false;
    final newValue = !current;

    await prefs.setBool(_syncEnabledKey, newValue);

    final firestore = ref.read(_firestoreSettingsProvider);
    if (firestore != null) {
      try {
        await firestore.setSyncEnabled(enabled: newValue);
      } on Exception {
        // Continue with local state if Firestore fails
      }
    }

    state = AsyncData(newValue);
  }
}
