// Web-only video call — Jitsi Meet embedded in an iframe (Flutter web only)
// User stays on the iCare URL — no redirect, no external tab.
// Mobile/Desktop uses video_call_mobile.dart (ZegoCloud) instead.
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui;
import 'package:web/web.dart' as web;
import '../services/call_service.dart';

class VideoCall extends StatefulWidget {
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

  @override
  State<VideoCall> createState() => _VideoCallWebState();
}

class _VideoCallWebState extends State<VideoCall> {
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'jitsi-${DateTime.now().millisecondsSinceEpoch}';
    _registerView();
  }

  // Sanitize channelName → valid Jitsi room name (alphanumeric + hyphens)
  String get _roomName =>
      'icare-${widget.channelName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '-')}';

  String get _jitsiUrl {
    final name = Uri.encodeComponent(
      widget.currentUserName.isNotEmpty ? widget.currentUserName : 'User',
    );
    return 'https://meet.jit.si/$_roomName'
        '#config.prejoinPageEnabled=false'
        '&config.startWithVideoMuted=${widget.isAudioOnly}'
        '&config.startWithAudioMuted=false'
        '&config.disableInviteFunctions=true'
        '&config.disableDeepLinking=true'
        '&config.hideConferenceSubject=true'
        '&config.disableThirdPartyRequests=true'
        '&interfaceConfig.SHOW_JITSI_WATERMARK=false'
        '&interfaceConfig.SHOW_WATERMARK_FOR_GUESTS=false'
        '&interfaceConfig.SHOW_BRAND_WATERMARK=false'
        '&interfaceConfig.TOOLBAR_ALWAYS_VISIBLE=false'
        '&interfaceConfig.DEFAULT_BACKGROUND=%23000000'
        '&userInfo.displayName=$name';
  }

  void _registerView() {
    try {
      ui.platformViewRegistry.registerViewFactory(_viewId, (int id) {
        final iframe = web.HTMLIFrameElement();
        iframe.src = _jitsiUrl;
        iframe.style.width = '100%';
        iframe.style.height = '100%';
        iframe.style.border = 'none';
        iframe.setAttribute(
          'allow',
          'camera; microphone; fullscreen; display-capture; autoplay',
        );
        iframe.setAttribute('allowfullscreen', 'true');
        return iframe;
      });
    } catch (_) {
      // registerViewFactory throws if viewId already registered (hot reload)
    }
  }

  Future<void> _endCall() async {
    try {
      await CallService().endCall(widget.channelName);
    } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Jitsi call fills the whole screen — stays on iCare URL (not a redirect)
          SizedBox.expand(
            child: HtmlElementView(viewType: _viewId),
          ),
          // End call button — lets Flutter handle call cleanup (DB signal)
          Positioned(
            bottom: 32,
            right: 24,
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: _endCall,
              tooltip: 'End Call',
              child: const Icon(Icons.call_end_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
