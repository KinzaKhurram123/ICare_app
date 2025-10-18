import 'package:icare/models/user.dart';

class CommonData {
  final User? userData;
  final List<Map<dynamic, dynamic>>? cartData;
  final bool profileCreated;

  const CommonData({
    this.userData,
    this.cartData,
    this.profileCreated = false,
  });

  CommonData copyWith({
    User? userData,
    List<Map<dynamic, dynamic>>? cartData,
    bool? profileCreated,
  }) {
    return CommonData(
      userData: userData ?? this.userData,
      cartData: cartData ?? this.cartData,
      profileCreated: profileCreated ?? this.profileCreated,
    );
  }
}
