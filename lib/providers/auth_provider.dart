import 'dart:developer';

import 'package:flutter_riverpod/legacy.dart';
import 'package:icare/models/auth.dart';
import 'package:icare/models/user.dart';
import 'package:icare/utils/shared_pref.dart';

class AuthNotifier extends StateNotifier<Auth> {
  AuthNotifier()
    : super(
        Auth(
          token: null,
          fcmToken: null,
          userWalkthrough: false,
          isLoggedIn: false,
          userRole: '',
          user: null,
        ),
      );

  void setUserToken(String _token) {
    state = state.copyWith(token: _token, isLoggedIn: true);
  }

  void setUserWalkthrough(bool value) {
    state = state.copyWith(userWalkthrough: value);
  }

  void setUserRole(String role) {
    log(role);
    SharedPref().setUserRole(role);
    state = state.copyWith(userRole: role);
  }

  void setFcmToken(String _token) {
    state = state.copyWith(fcmToken: _token);
  }

  void setUser(User user) {
    // Keep the original role case from backend and normalize it
    final normalizedRole = _normalizeRole(user.role);
    SharedPref().setUserRole(normalizedRole);
    SharedPref().setUserData(user);
    state = state.copyWith(user: user, userRole: normalizedRole);
  }

  String _normalizeRole(String role) {
    // Normalize role to match backend format (capitalize first letter)
    if (role.isEmpty) return role;
    final normalized = role[0].toUpperCase() + role.substring(1).toLowerCase();
    // Handle special cases
    if (normalized == 'Laboratory') return 'Laboratory';
    if (normalized == 'Pharmacy') return 'Pharmacy';
    return normalized;
  }

  void setUserLogout() {
    SharedPref().remove("userRole");
    SharedPref().remove("token");
    SharedPref().remove("userData");
    state = Auth();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, Auth>((ref) {
  return AuthNotifier();
});
