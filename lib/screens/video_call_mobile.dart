import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../config/agora_config.dart';
import '../services/agora_service.dart';
import '../services/call_service.dart';

/// Agora RTC video call — Android / iOS / Desktop
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
  State<VideoCall> createState() => _VideoCallMobileState();
}

class _VideoCallMobileState extends State<VideoCall> {
  RtcEngine? _engine;
  int? _remoteUid;
  bool _localVideoReady = false;
  bool _joined = false;
  bool _micMuted = false;
  bool _camOff = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    try {
      // 1. Fetch token from backend
      final tokenData = await AgoraService().getToken(
        channelName: widget.channelName,
        uid: 0,
      );

      if (tokenData['success'] != true) {
        setState(() {
          _error = tokenData['message'] ?? 'Failed to get Agora token';
          _loading = false;
        });
        return;
      }

      final token = tokenData['data']['token'] as String;
      final appId = tokenData['data']['appId'] as String? ?? AgoraConfig.appId;

      // 2. Create engine
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(appId: appId));

      // 3. Register event handlers
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            debugPrint('✅ Agora: joined channel ${connection.channelId}');
            if (mounted) setState(() { _joined = true; _loading = false; });
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            debugPrint('👤 Agora: remote user $remoteUid joined');
            if (mounted) setState(() => _remoteUid = remoteUid);
          },
          onUserOffline: (connection, remoteUid, reason) {
            debugPrint('👤 Agora: remote user $remoteUid left');
            if (mounted) setState(() => _remoteUid = null);
          },
          onLocalVideoStateChanged: (source, state, error) {
            if (state == LocalVideoStreamState.localVideoStreamStateCapturing ||
                state == LocalVideoStreamState.localVideoStreamStateEncoding) {
              if (mounted) setState(() => _localVideoReady = true);
            }
          },
          onError: (err, msg) {
            debugPrint('❌ Agora error: $err — $msg');
            if (mounted) setState(() { _error = msg; _loading = false; });
          },
        ),
      );

      // 4. Enable video (or audio-only)
      if (!widget.isAudioOnly) {
        await _engine!.enableVideo();
        await _engine!.startPreview();
      } else {
        await _engine!.enableAudio();
      }

      // 5. Set channel profile and client role
      await _engine!.setChannelProfile(
        ChannelProfileType.channelProfileCommunication,
      );

      // 6. Join channel
      await _engine!.joinChannel(
        token: token,
        channelId: widget.channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
    } catch (e) {
      debugPrint('❌ Agora init error: $e');
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _endCall() async {
    try {
      await CallService().endCall(widget.channelName);
    } catch (_) {}
    await _engine?.leaveChannel();
    await _engine?.release();
    _engine = null;
    if (mounted) Navigator.pop(context);
  }

  void _toggleMic() async {
    _micMuted = !_micMuted;
    await _engine?.muteLocalAudioStream(_micMuted);
    if (mounted) setState(() {});
  }

  void _toggleCam() async {
    _camOff = !_camOff;
    await _engine?.muteLocalVideoStream(_camOff);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return _buildError();
    if (_loading) return _buildLoading();
    return _buildCallUI();
  }

  Widget _buildLoading() {
    return const Scaffold(
      backgroundColor: Color(0xFF0A1628),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text('Connecting...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 56),
            const SizedBox(height: 16),
            Text(_error ?? 'Unknown error',
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallUI() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote video (full screen)
          if (_remoteUid != null && !widget.isAudioOnly)
            SizedBox.expand(
              child: AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _engine!,
                  canvas: VideoCanvas(uid: _remoteUid),
                  connection: RtcConnection(channelId: widget.channelName),
                ),
              ),
            )
          else
            _buildWaitingOverlay(),

          // Local video (picture-in-picture)
          if (!widget.isAudioOnly && _localVideoReady)
            Positioned(
              top: 48,
              right: 16,
              width: 110,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: _engine!,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ),
              ),
            ),

          // Remote user name
          if (_remoteUid != null)
            Positioned(
              top: 48,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.remoteUserName,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),

          // Controls bar
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _controlBtn(
                  icon: _micMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                  color: _micMuted ? Colors.grey : Colors.white,
                  bg: Colors.white24,
                  onTap: _toggleMic,
                ),
                const SizedBox(width: 20),
                _controlBtn(
                  icon: Icons.call_end_rounded,
                  color: Colors.white,
                  bg: Colors.red,
                  onTap: _endCall,
                  size: 64,
                ),
                const SizedBox(width: 20),
                if (!widget.isAudioOnly)
                  _controlBtn(
                    icon: _camOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                    color: _camOff ? Colors.grey : Colors.white,
                    bg: Colors.white24,
                    onTap: _toggleCam,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingOverlay() {
    return Container(
      color: const Color(0xFF0A1628),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 56,
              backgroundColor: Colors.white12,
              child: Text(
                widget.remoteUserName.isNotEmpty
                    ? widget.remoteUserName[0].toUpperCase()
                    : '?',
                style: const TextStyle(fontSize: 48, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.remoteUserName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Waiting for other party...',
                style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  Widget _controlBtn({
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
    double size = 56,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: size * 0.45),
      ),
    );
  }
}
