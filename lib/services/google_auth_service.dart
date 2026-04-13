import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:icare/services/api_service.dart';
import 'package:icare/utils/shared_pref.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '564788374793-1eptqsl65ohkvsquqhc4qnhlia592v2f.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );
  // Lazy getter — avoids accessing FirebaseAuth before Firebase.initializeApp() completes on web
  FirebaseAuth get _firebaseAuth => FirebaseAuth.instance;
  final ApiService _apiService = ApiService();
  final SharedPref _prefs = SharedPref();

  /// Sign in with Google and return user data + token
  Future<Map<String, dynamic>> signInWithGoogle() async {
    if (kIsWeb) {
      return {'success': false, 'message': 'Google Sign-In is not supported on web in this build'};
    }
    try {
      // Trigger Google sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'Sign in cancelled'};
      }

      // Get auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      // Get Firebase ID token to send to our backend
      final String? firebaseIdToken = await userCredential.user?.getIdToken();
      if (firebaseIdToken == null) {
        return {'success': false, 'message': 'Failed to get auth token'};
      }

      // Send to our backend for JWT
      final response = await _apiService.post('/auth/google', {
        'idToken': firebaseIdToken,
        'name': googleUser.displayName ?? '',
        'email': googleUser.email,
        'photoUrl': googleUser.photoUrl ?? '',
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final token = data['token']?.toString() ?? '';
        if (token.isNotEmpty) {
          await _prefs.setToken(token);
        }
        return {'success': true, 'data': data, 'user': data['user']};
      }

      return {'success': false, 'message': 'Backend authentication failed'};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': e.message ?? 'Firebase auth error'};
    } catch (e) {
      return {'success': false, 'message': 'Google sign in failed: ${e.toString()}'};
    }
  }

  Future<void> signOut() async {
    if (kIsWeb) return;
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
