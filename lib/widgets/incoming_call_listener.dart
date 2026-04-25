import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/call_service.dart';
import '../utils/shared_pref.dart';
import '../utils/app_keys.dart';
import '../screens/video_call.dart';

/// Wraps the app and polls for incoming calls every 3 seconds.
/// When a call is detected it shows a full-screen incoming call dialog.
class IncomingCallListener extends StatefulWidget {
  final Widget child;

  const IncomingCallListener({super.key, required this.child});

  @override
  State<IncomingCallListener> createState() => _IncomingCallListenerState();
}

class _IncomingCallListenerState extends State<IncomingCallListener> {
  final CallService _callService = CallService();
  final SharedPref _sharedPref = SharedPref();
  Timer? _timer;
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _checkIncoming());
  }

  Future<void> _checkIncoming() async {
    if (_dialogShowing || !mounted) return;

    // Only poll if user is logged in
    final token = await _sharedPref.getToken();
    if (token == null || token.isEmpty) return;

    debugPrint('🔔 Polling for incoming calls...');
    final signal = await _callService.checkIncomingCall();
    if (signal == null || !mounted) return;

    debugPrint('📞 Incoming call detected: ${signal['callerName']}');
    _dialogShowing = true;
    try {
      await _showIncomingCallDialog(signal);
    } finally {
      _dialogShowing = false;
    }
  }

  Future<void> _showIncomingCallDialog(Map<String, dynamic> signal) async {
    final signalId = signal['id']?.toString() ?? '';
    final callerName = signal['callerName']?.toString() ?? 'Unknown';
    final channelName = signal['channelName']?.toString() ?? '';
    final callType = signal['callType']?.toString() ?? 'video';
    final isAudioOnly = callType == 'audio';

    final nav = appNavigatorKey.currentState;
    if (nav == null) {
      debugPrint('⚠️ Navigator not ready, skipping call dialog');
      return;
    }

    await nav.push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        barrierDismissible: false,
        pageBuilder: (ctx, _, __) => _IncomingCallDialog(
          callerName: callerName,
          isAudioOnly: isAudioOnly,
          onAccept: () async {
            await _callService.respondToCall(signalId, 'accepted');
            nav.pop();
            nav.push(
              MaterialPageRoute(
                builder: (_) => VideoCall(
                  channelName: channelName,
                  remoteUserName: callerName,
                  isAudioOnly: isAudioOnly,
                ),
              ),
            );
          },
          onDecline: () async {
            await _callService.respondToCall(signalId, 'rejected');
            nav.pop();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _IncomingCallDialog extends StatelessWidget {
  final String callerName;
  final bool isAudioOnly;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _IncomingCallDialog({
    required this.callerName,
    required this.isAudioOnly,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A5F), Color(0xFF0F172A)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white24,
              child: Text(
                callerName.isNotEmpty ? callerName[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              callerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isAudioOnly ? 'Incoming Audio Call' : 'Incoming Video Call',
              style: const TextStyle(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Decline
                GestureDetector(
                  onTap: onDecline,
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.call_end_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Decline',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Accept
                GestureDetector(
                  onTap: onAccept,
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isAudioOnly
                              ? Icons.call_rounded
                              : Icons.videocam_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Accept',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
