import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _userEmailKey = 'user_email';
  static const _userNameKey = 'user_name';

  final FlutterSecureStorage _storage;

  AuthStorage()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> saveUser({
    required String id,
    required String email,
    String? name,
  }) async {
    await _storage.write(key: _userIdKey, value: id);
    await _storage.write(key: _userEmailKey, value: email);
    if (name != null) {
      await _storage.write(key: _userNameKey, value: name);
    }
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);
  Future<String?> getUserId() => _storage.read(key: _userIdKey);
  Future<String?> getUserEmail() => _storage.read(key: _userEmailKey);
  Future<String?> getUserName() => _storage.read(key: _userNameKey);

  Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }
}
