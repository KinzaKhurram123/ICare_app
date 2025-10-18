import 'package:flutter_riverpod/legacy.dart';
import 'package:icare/models/auth.dart';

class AuthNotifier extends StateNotifier<Auth> {
   AuthNotifier () : super(Auth(
    token: null,
    fcmToken: null,
    userWalkthrough: false,
    isLoggedIn: false
   ));


   void setUserToken(String _token) {
    state= state.copyWith(token: _token, isLoggedIn: true);
   }
   
   void setUserWalkthrough(bool value){
    state = state.copyWith(userWalkthrough: value);
   }

   void setFcmToken(String _token){
    state = state.copyWith(fcmToken: _token);
   }

   void setUserLogout(){
    state= Auth();
   }
}


final authProvider = StateNotifierProvider<AuthNotifier, Auth>((ref) {
  return AuthNotifier();
});