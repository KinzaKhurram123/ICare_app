import 'package:flutter_riverpod/legacy.dart';
import 'package:icare/models/auth.dart';
import 'package:icare/models/coomon.dart';
import 'package:icare/models/user.dart';

class CommonNotifier extends StateNotifier<CommonData> {
   CommonNotifier () : super(CommonData(
    cartData: [],
    userData: null, 
    profileCreated: false
   ));


   void setUserData(User _userData) {
    state= state.copyWith(userData: _userData);
   }
   
   void setProfileCreated(bool value){
    state = state.copyWith(profileCreated: value);
   }

   void setCartData(List<Map<dynamic, dynamic>> _cartData){
    state = state.copyWith(cartData: _cartData);
   }

  
}


final commonProvider = StateNotifierProvider<CommonNotifier, CommonData>((ref) {
  return CommonNotifier();
});