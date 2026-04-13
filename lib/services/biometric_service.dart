import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:icare/utils/shared_pref.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _auth = LocalAuthentication();
  final SharedPref _prefs = SharedPref();

  /// Check if device supports biometrics
  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Get available biometric types (fingerprint, face, etc.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticate({String reason = 'Authenticate to access iCare'}) async {
    if (kIsWeb) return false;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // allow PIN fallback
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  /// Whether biometric login is enabled by user
  Future<bool> isEnabled() => _prefs.getBiometricEnabled();

  /// Enable biometric login (call after successful password login)
  Future<void> enable() => _prefs.setBiometricEnabled(true);

  /// Disable biometric login
  Future<void> disable() => _prefs.setBiometricEnabled(false);

  /// Get icon based on available biometric type
  Future<String> getBiometricLabel() async {
    final types = await getAvailableBiometrics();
    if (types.contains(BiometricType.face)) return 'Face ID';
    if (types.contains(BiometricType.fingerprint)) return 'Fingerprint';
    return 'Biometric';
  }
}
