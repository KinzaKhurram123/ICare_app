import 'dart:convert';
import 'package:icare/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SharedPref {
  // Singleton
  static final SharedPref _instance = SharedPref._internal();
  factory SharedPref() => _instance;
  SharedPref._internal();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> setUserData(User userData) async {
    final SharedPreferences pref = await prefs;
    String userJson = jsonEncode(userData.toJson());
    await pref.setString('userData', userJson);
  }

  Future<User?> getUserData() async {
    final SharedPreferences pref = await prefs;
    String? userJson = pref.getString('userData');
    if (userJson != null) {
      final map = jsonDecode(userJson);
      return User.fromJson(map);
    }
    return null;
  }

  Future<void> setToken(String token) async {
    final SharedPreferences pref = await prefs;
    await pref.setString('token', token);
    debugPrint('✅ Token saved: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
  }

  Future<String?> getToken() async {
    final SharedPreferences pref = await prefs;
    final token = pref.getString('token');
    debugPrint('🔑 Token retrieved: ${token != null ? "Yes (length: ${token.length})" : "No"}');
    return token;
  }

  Future<void> setUserWalkthrough(bool value) async {
    final SharedPreferences pref = await prefs;
    debugPrint("Walkthrough saved: $value");
    await pref.setBool("walkthrough", value);
  }

  Future<bool?> getUserWalkthrough() async {
    final SharedPreferences pref = await prefs;
    return pref.getBool("walkthrough");
  }

  Future<void> setUserRole(String value) async {
    final SharedPreferences pref = await prefs;
    await pref.setString("userRole", value);
    debugPrint("User role saved: $value");
  }

  Future<String?> getUserRole() async {
    final SharedPreferences pref = await prefs;
    return pref.getString("userRole");
  }

  Future<void> remove(String key) async {
    final SharedPreferences pref = await prefs;
    await pref.remove(key);
    debugPrint("Removed key: $key");
  }

  Future<void> clearAll() async {
    final SharedPreferences pref = await prefs;
    await pref.clear();
    debugPrint("All shared preferences cleared");
  }

  Future<bool> isLoggedIn() async {
    final SharedPreferences pref = await prefs;
    final hasToken = pref.containsKey('token');
    debugPrint("Is logged in: $hasToken");
    return hasToken;
  }
}