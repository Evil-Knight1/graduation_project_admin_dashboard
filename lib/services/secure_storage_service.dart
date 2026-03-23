import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _tokenKey = 'jwt_token';
  static const _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  const SecureStorageService(this._storage);

  Future<void> saveTokens({required String token, String? refreshToken}) async {
    await _storage.write(key: _tokenKey, value: token);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
