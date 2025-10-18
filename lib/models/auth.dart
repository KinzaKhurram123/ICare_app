class Auth {
  final String? token;
  final String? fcmToken;
  final bool userWalkthrough;
  final bool isLoggedIn;

  Auth({
    this.token,
    this.fcmToken,
    this.userWalkthrough = false,
    this.isLoggedIn = false,
  });

  // 🔹 This lets you update one or more fields easily
  Auth copyWith({
    String? token,
    String? fcmToken,
    bool? userWalkthrough,
    bool? isLoggedIn,
  }) {
    return Auth(
      token: token ?? this.token,
      fcmToken: fcmToken ?? this.fcmToken,
      userWalkthrough: userWalkthrough ?? this.userWalkthrough,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}
