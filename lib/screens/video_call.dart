import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../config/zego_config.dart';
import '../services/call_service.dart';

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

  // ZegoCloud room ID: only alphanumeric + _ -
  String get _callId =>
      channelName.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');

  // Unique user ID — use provided one or generate from timestamp
  String get _userId => currentUserId.isNotEmpty
      ? currentUserId.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_')
      : 'user_${DateTime.now().millisecondsSinceEpoch}';

  @override
  Widget build(BuildContext context) {
    // Show setup screen if credentials not added yet
    if (ZegoConfig.appId == 0 || ZegoConfig.appSign.isEmpty) {
      return _buildNoCredentials(context);
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
          try {
            await CallService().endCall(channelName);
          } catch (_) {}
          defaultAction.call();
        },
      ),
    );
  }

  Widget _buildNoCredentials(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.key_off_rounded,
                  color: Colors.orange, size: 56),
              const SizedBox(height: 24),
              const Text(
                'ZegoCloud Setup Required',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please add your App ID and App Sign\nfrom https://console.zegocloud.com\ninto lib/config/zego_config.dart',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
