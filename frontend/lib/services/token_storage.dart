import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _accessTokenKey = 'ACCESS_TOKEN';
  static const _refreshTokenKey = 'REFRESH_TOKEN';
  static const _tokenTypeKey = 'TOKEN_TYPE';

  /// Save the JWT access token
  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  /// Read the stored access token, or null if none
  static Future<String?> readAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Delete the stored access token
  static Future<void> clearAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
  }

  /// Save the refresh token
  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  /// Read the stored refresh token, or null if none
  static Future<String?> readRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Delete the stored refresh token
  static Future<void> clearRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_refreshTokenKey);
  }

  /// Save the token type (e.g., "Bearer")
  static Future<void> saveTokenType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenTypeKey, type);
  }

  /// Read the stored token type, or null if none
  static Future<String?> readTokenType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenTypeKey);
  }

  /// Delete the stored token type
  static Future<void> clearTokenType() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenTypeKey);
  }
}
