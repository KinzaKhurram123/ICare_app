// Web-only video call implementation — Agora RTC Engine
// This file is only compiled on Flutter web (conditional export in video_call.dart)
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:dio/dio.dart';
import '../services/api_config.dart';
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
  RtcEngine? _engine;
  int? _remoteUid;
  bool _localVideoReady = false;
  bool _joined = false;
  bool _muted = false;
  bool _cameraOff = false;
  String? _error;
  String? _agoraAppId;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  @override
  void dispose() {
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  Future<String?> _fetchToken() async {
    try {
      final resp = await Dio().get(
        '${ApiConfig.baseUrl}/agora/token',
        queryParameters: {'channelName': widget.channelName, 'uid': 0},
      );
      if (resp.data['success'] == true) {
        _agoraAppId = resp.data['data']['appId']?.toString();
        return resp.data['data']['token']?.toString();
      }
    } catch (e) {
      debugPrint('❌ Agora token fetch failed: $e');
    }
    return null;
  }

  Future<void> _initAgora() async {
    final token = await _fetchToken();
    if (!mounted) return;

    if (token == null || _agoraAppId == null || (_agoraAppId?.isEmpty ?? true)) {
      setState(() => _error = 'Could not get call token — check your connection.');
      return;
    }

    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(appId: _agoraAppId!));

      _engine!.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          if (mounted) setState(() => _joined = true);
        },
        onUserJoined: (connection, uid, elapsed) {
          if (mounted) setState(() => _remoteUid = uid);
        },
        onUserOffline: (connection, uid, reason) {
          if (mounted) setState(() => _remoteUid = null);
        },
        onError: (errCode, errMsg) {
          debugPrint('⚠️ Agora error $errCode: $errMsg');
        },
      ));

      if (!widget.isAudioOnly) {
        await _engine!.enableVideo();
        // Note: startPreview() is NOT called — on Flutter web it tries to bind
        // to a DOM element before the widget tree renders and throws a null error.
        // Video preview starts automatically after joinChannel() renders AgoraVideoView.
        if (mounted) setState(() => _localVideoReady = true);
      }
      await _engine!.enableAudio();

      if (!mounted) return;
      await _engine!.joinChannel(
        token: token,
        channelId: widget.channelName,
        uid: 0,
        options: ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishMicrophoneTrack: !_muted,
          publishCameraTrack: !widget.isAudioOnly,
        ),
      );
    } catch (e) {
      debugPrint('❌ Agora init error: $e');
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _endCall() async {
    try {
      await _engine?.leaveChannel();
      await CallService().endCall(widget.channelName);
    } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  Future<void> _toggleMute() async {
    _muted = !_muted;
    await _engine?.muteLocalAudioStream(_muted);
    setState(() {});
  }

  Future<void> _toggleCamera() async {
    _cameraOff = !_cameraOff;
    await _engine?.muteLocalVideoStream(_cameraOff);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return _buildError();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildRemoteView(),
          if (!widget.isAudioOnly && _localVideoReady) _buildLocalView(),
          _buildTopBar(),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: _buildControls(),
          ),
          if (!_joined) _buildConnecting(),
        ],
      ),
    );
  }

  Widget _buildRemoteView() {
    if (widget.isAudioOnly || _remoteUid == null) {
      return Container(
        color: const Color(0xFF0A1628),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white24,
                child: Text(
                  widget.remoteUserName.isNotEmpty
                      ? widget.remoteUserName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 50, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.remoteUserName,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
              ),
              if (widget.isAudioOnly) ...[
                const SizedBox(height: 8),
                const Text('Audio Call', style: TextStyle(color: Colors.white54, fontSize: 14)),
              ],
            ],
          ),
        ),
      );
    }
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: _remoteUid),
        connection: RtcConnection(channelId: widget.channelName),
      ),
    );
  }

  Widget _buildLocalView() {
    return Positioned(
      bottom: 120,
      right: 16,
      child: Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white30),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _cameraOff
              ? Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.videocam_off, color: Colors.white54, size: 32),
                )
              : AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: _engine!,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black87, Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Text(
                widget.remoteUserName.isNotEmpty ? widget.remoteUserName[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.remoteUserName,
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _controlBtn(
          icon: _muted ? Icons.mic_off_rounded : Icons.mic_rounded,
          bg: _muted ? Colors.red : Colors.white24,
          onTap: _toggleMute,
        ),
        const SizedBox(width: 20),
        _controlBtn(
          icon: Icons.call_end_rounded,
          bg: Colors.red,
          size: 30,
          onTap: _endCall,
        ),
        const SizedBox(width: 20),
        if (!widget.isAudioOnly)
          _controlBtn(
            icon: _cameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
            bg: _cameraOff ? Colors.red : Colors.white24,
            onTap: _toggleCamera,
          ),
      ],
    );
  }

  Widget _controlBtn({
    required IconData icon,
    required Color bg,
    required VoidCallback onTap,
    double size = 24,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }

  Widget _buildConnecting() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'Connecting to ${widget.remoteUserName}...',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.orange, size: 56),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
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
