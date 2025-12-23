import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static final _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true, // 🔥 PREVENTS CRASH
    ),
  );

  static Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  static Future<void> getfcmtoken(String token) async {
    await _storage.write(key: 'fcm_token', value: token);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'fcm_token');
  }
}
