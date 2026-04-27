import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final profileExtrasProvider =
    AsyncNotifierProvider<ProfileExtrasNotifier, ProfileExtras>(
  ProfileExtrasNotifier.new,
);

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
