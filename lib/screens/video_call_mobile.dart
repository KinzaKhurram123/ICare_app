import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../config/zego_config.dart';
import '../services/call_service.dart';

/// ZegoCloud prebuilt call — Android / iOS only
class VideoCall extends StatelessWidget {
  final String channelName;
  final String remoteUserName;
  final bool isAudioOnly;
  final String currentUserId;
  final String currentUserName;

  const VideoCall({
    super.key,
    required this.channelName,
    required this.remoteUserName,
    this.isAudioOnly = false,
    this.currentUserId = '',
    this.currentUserName = 'User',
  });

  String get _callId =>
      channelName.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');

  String get _userId => currentUserId.isNotEmpty
      ? currentUserId.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_')
      : 'user_${DateTime.now().millisecondsSinceEpoch}';

  @override
  Widget build(BuildContext context) {
    if (ZegoConfig.appId == 0 || ZegoConfig.appSign.isEmpty) {
      return _noCredentials(context);
    }
    return ZegoUIKitPrebuiltCall(
      appID: ZegoConfig.appId,
      appSign: ZegoConfig.appSign,
      userID: _userId,
      userName: currentUserName.isNotEmpty ? currentUserName : 'User',
      callID: _callId,
      config: isAudioOnly
          ? ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
          : ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
      events: ZegoUIKitPrebuiltCallEvents(
        onCallEnd: (event, defaultAction) async {
          try { await CallService().endCall(channelName); } catch (_) {}
          defaultAction.call();
        },
      ),
    );
  }

  Widget _noCredentials(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.key_off_rounded, color: Colors.orange, size: 56),
            const SizedBox(height: 20),
            const Text('ZegoCloud credentials missing',
                style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
