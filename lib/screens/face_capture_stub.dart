import 'package:flutter/material.dart';

/// Web stand-in for [FaceCaptureScreen].
///
/// The real screen pulls in `camera` and `google_mlkit_face_detection`, both of
/// which are native-only — on web they do nothing but still compile into
/// main.dart.js, which every visitor downloads before the landing page paints.
/// The client asked for Face ID to be removed from the web build and kept on
/// phones, so `face_capture.dart` exports this file on web and the real screen
/// everywhere else.
///
/// Callers are expected to hide their Face ID entry points behind `kIsWeb`, so
/// this should never be reached. It stays a real screen rather than a `throw`
/// so a missed guard degrades into a message instead of a crash.
enum FaceCaptureMode { register, verify }

class FaceCaptureScreen extends StatelessWidget {
  final FaceCaptureMode mode;
  const FaceCaptureScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face ID')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.phone_iphone_rounded, size: 48, color: Color(0xFF94A3B8)),
              SizedBox(height: 12),
              Text(
                'Face ID is available on the mobile app',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Text(
                'Please sign in with your password here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
