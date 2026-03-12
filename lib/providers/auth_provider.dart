import 'dart:developer';

import 'package:flutter_riverpod/legacy.dart';
import 'package:icare/models/auth.dart';
import 'package:icare/models/user.dart';

class AuthNotifier extends StateNotifier<Auth> {
   AuthNotifier () : super(Auth(
    token: null,
    fcmToken: null,
    userWalkthrough: false,
    isLoggedIn: false,
    userRole: '',
    user: null,
   ));


   void setUserToken(String _token) {
    state= state.copyWith(token: _token, isLoggedIn: true);
   }
   
   void setUserWalkthrough(bool value){
    state = state.copyWith(userWalkthrough: value);
   }

    void setUserRole(String role) {
      log(role);
      state = state.copyWith(userRole: role);
    }

   void setFcmToken(String _token){
    state = state.copyWith(fcmToken: _token);
   }

   void setUser(User user) {
     // Convert role to lowercase to match frontend expectations
     final normalizedRole = user.role.toLowerCase();
     state = state.copyWith(user: user, userRole: normalizedRole);
   }

   void setUserLogout(){
    state= Auth();
   }
}


final authProvider = StateNotifierProvider<AuthNotifier, Auth>((ref) {
  return AuthNotifier();
});