import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/call_service.dart';
import '../utils/app_keys.dart';
import '../utils/jitsi_launcher.dart';

class VideoCall extends StatefulWidget {
  final String channelName;
  final String remoteUserName;
  final bool isAudioOnly;

  const VideoCall({
    super.key,
    required this.channelName,
    required this.remoteUserName,
    this.isAudioOnly = false,
  });

  @override
  State<VideoCall> createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  final CallService _callService = CallService();

  bool _launching = true;
  bool _callStarted = false;
  int _callDuration = 0;
  StreamSubscription<int>? _timerSubscription;

  // Sanitize channel name for Jitsi (only alphanumeric + hyphens)
  String get _jitsiRoom =>
      'icare-${widget.channelName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '-')}';

  @override
  void initState() {
    super.initState();
    _startCall();
  }

  Future<void> _startCall() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() => _launching = false);

    // On web: redirects the browser tab to Jitsi (page changes — code below won't run on web)
    // On mobile: opens Jitsi in browser/app and returns control here
    await launchJitsiMeet(_jitsiRoom);

    if (!mounted) return;
    // Mobile only reaches here — show "in call" screen
    setState(() => _callStarted = true);
    _startTimer();
  }

  void _startTimer() {
    _timerSubscription =
        Stream.periodic(const Duration(seconds: 1), (i) => i + 1)
            .listen((s) {
      if (mounted) setState(() => _callDuration = s);
    });
  }

  String _formatDuration(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  Future<void> _endCall() async {
    _timerSubscription?.cancel();
    try {
      await _callService.endCall(widget.channelName);
    } catch (_) {}
    if (appNavigatorKey.currentState?.canPop() == true) {
      appNavigatorKey.currentState?.pop();
    } else if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  void dispose() {
    _timerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_launching) return _buildLaunching();
    // Web redirects the browser so this screen is only visible briefly
    if (kIsWeb) return _buildWebRedirecting();
    // Mobile: show in-call screen while Jitsi is open in browser
    return _buildMobileInCall();
  }

  Widget _buildLaunching() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _avatar(size: 56),
            const SizedBox(height: 24),
            Text(
              widget.remoteUserName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isAudioOnly ? 'Audio Call' : 'Video Call',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 36,
              height: 36,
              child:
                  CircularProgressIndicator(color: Color(0xFF3B82F6), strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            const Text('Connecting...',
                style: TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // On web: the browser will redirect to Jitsi — this is shown very briefly
  Widget _buildWebRedirecting() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withAlpha(80),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.video_call_rounded,
                  color: Color(0xFF3B82F6), size: 56),
            ),
            const SizedBox(height: 24),
            const Text(
              'Opening Video Call...',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'You will be redirected to the call room',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
                color: Color(0xFF3B82F6), strokeWidth: 3),
          ],
        ),
      ),
    );
  }

  // Mobile: Jitsi opened in browser, show status screen with end button
  Widget _buildMobileInCall() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  _avatar(size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.remoteUserName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        Text(
                          _callStarted
                              ? _formatDuration(_callDuration)
                              : 'Connecting...',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Center info
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.isAudioOnly
                        ? Icons.call_rounded
                        : Icons.video_call_rounded,
                    color: Colors.white,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Call in Progress',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your call is open in the browser.\nReturn here to end the session.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),

            const Spacer(),

            // End call button
            Padding(
              padding: const EdgeInsets.only(bottom: 52),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _endCall,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withAlpha(80),
                            blurRadius: 20,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: const Icon(Icons.call_end_rounded,
                          color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('End Call',
                      style: TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar({required double size}) {
    return CircleAvatar(
      radius: size,
      backgroundColor: const Color(0xFF1E3A8A),
      child: Text(
        widget.remoteUserName.isNotEmpty
            ? widget.remoteUserName[0].toUpperCase()
            : '?',
        style: TextStyle(
            fontSize: size * 0.7,
            color: Colors.white,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}
