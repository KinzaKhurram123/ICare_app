import 'package:flutter_riverpod/legacy.dart';
import 'package:icare/models/auth.dart';
import 'package:icare/models/coomon.dart';
import 'package:icare/models/user.dart';

class CommonNotifier extends StateNotifier<CommonData> {
   CommonNotifier () : super(CommonData(
    cartData: [],
    userData: null, 
    profileCreated: false,
  selectedReason: "",
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
    
    void setSelectedReason(String? reason){
    state = state.copyWith(selectedReason: reason);
    }  
    
    // void setSelectedReason(String reason){
    // state = state.copyWith(selectedReason: reason);
    // }  

}


final commonProvider = StateNotifierProvider<CommonNotifier, CommonData>((ref) {
  return CommonNotifier();
});