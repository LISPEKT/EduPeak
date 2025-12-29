import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurePrefs {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static Future<void> saveAuthToken(String? token) async {
    if (token == null || token.isEmpty) return;
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getAuthToken() async =>
      await _storage.read(key: 'auth_token');

  static Future<void> clear() async => await _storage.deleteAll();
}