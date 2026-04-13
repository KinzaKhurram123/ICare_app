import 'dart:convert';
import 'package:icare/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  // Singleton
  static final SharedPref _instance = SharedPref._internal();
  factory SharedPref() => _instance;
  SharedPref._internal();

  SharedPreferencesWithCache? _cache;

  Future<SharedPreferencesWithCache> get _prefs async {
    _cache ??= await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: <String>{
          'auth',
          'userData',
          'token',
          'userRole',
          'walkthrough',
          'biometric_enabled',
        },
      ),
    );
    return _cache!;
  }

  Future<void> setUserData(User userData) async {
    final SharedPreferencesWithCache pref = await _prefs;
    String userJson = jsonEncode(userData);
    await pref.setString('userData', userJson);
  }

  /// Get user data (returns Map or null)
  Future<User?> getUserData() async {
    final SharedPreferencesWithCache pref = await _prefs;
    String? userJson = pref.getString('userData');
    if (userJson != null) {
      final map = jsonDecode(userJson);
      return User.fromJson(map);
    }
    return null;
  }

  /// Set authentication token
  Future<void> setToken(String token) async {
    final SharedPreferencesWithCache pref = await _prefs;
    await pref.setString('token', token);
  }

  /// Get authentication token
  Future<String?> getToken() async {
    final SharedPreferencesWithCache pref = await _prefs;
    return pref.getString('token');
  }

  Future<void> setUserWalkthrough(bool value) async {
    final SharedPreferencesWithCache pref = await _prefs;
    print("walkthrough == > " + value.toString());
    await pref.setBool("walkthrough", value);
  }

  Future<bool?> getUserWalkthrough() async {
    final SharedPreferencesWithCache pref = await _prefs;
    return pref.getBool("walkthrough");
  }

  Future<void> setUserRole(String value) async {
    final SharedPreferencesWithCache pref = await _prefs;
    await pref.setString("userRole", value);
  }

  Future<String?> getUserRole() async {
    final SharedPreferencesWithCache pref = await _prefs;
    return pref.getString("userRole");
  }

  Future<void> remove(String key) async {
    final SharedPreferencesWithCache pref = await _prefs;
    await pref.remove(key);
  }

  /// Clear all stored preferences
  Future<void> clearAll() async {
    final SharedPreferencesWithCache pref = await _prefs;
    await pref.clear();
  }

  /// Check if user is logged in (based on token existence)
  Future<bool> isLoggedIn() async {
    final SharedPreferencesWithCache pref = await _prefs;
    return pref.containsKey('token');
  }

  Future<void> setBiometricEnabled(bool value) async {
    final pref = await _prefs;
    await pref.setBool('biometric_enabled', value);
  }

  Future<bool> getBiometricEnabled() async {
    final pref = await _prefs;
    return pref.getBool('biometric_enabled') ?? false;
  }
}
