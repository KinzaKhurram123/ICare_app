import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/agora_service.dart';

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
  final AgoraService _agoraService = AgoraService();

  RtcEngine? _engine;
  bool _localUserJoined = false;
  bool _remoteUserJoined = false;
  int? _remoteUid;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;
  bool _isLoading = true;
  String? _error;
  String _appId = '';

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    if (kIsWeb) {
      setState(() {
        _error = 'Video calls are not supported on web.\nPlease use the mobile app.';
        _isLoading = false;
      });
      return;
    }

    // Request permissions
    await [Permission.camera, Permission.microphone].request();

    // Fetch token from backend
    final tokenResult = await _agoraService.getToken(channelName: widget.channelName);
    if (tokenResult['success'] != true) {
      setState(() {
        _error = 'Failed to get call token: ${tokenResult['message']}';
        _isLoading = false;
      });
      return;
    }

    final token = tokenResult['data']['token'] as String;
    _appId = tokenResult['data']['appId'] as String;
    final uid = tokenResult['data']['uid'] as int;

    // Init engine
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(appId: _appId));

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          if (mounted) setState(() => _localUserJoined = true);
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          if (mounted) {
            setState(() {
              _remoteUid = remoteUid;
              _remoteUserJoined = true;
            });
          }
        },
        onUserOffline: (connection, remoteUid, reason) {
          if (mounted) {
            setState(() {
              _remoteUid = null;
              _remoteUserJoined = false;
            });
          }
        },
        onError: (err, msg) {
          if (mounted) setState(() => _error = 'Call error: $msg');
        },
      ),
    );

    if (!widget.isAudioOnly) {
      await _engine!.enableVideo();
      await _engine!.startPreview();
    }

    await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine!.joinChannel(
      token: token,
      channelId: widget.channelName,
      uid: uid,
      options: const ChannelMediaOptions(
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _endCall() async {
    await _engine?.leaveChannel();
    await _engine?.release();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _toggleMute() async {
    setState(() => _isMuted = !_isMuted);
    await _engine?.muteLocalAudioStream(_isMuted);
  }

  Future<void> _toggleCamera() async {
    setState(() => _isCameraOff = !_isCameraOff);
    await _engine?.muteLocalVideoStream(_isCameraOff);
  }

  Future<void> _toggleSpeaker() async {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    await _engine?.setEnableSpeakerphone(_isSpeakerOn);
  }

  Future<void> _switchCamera() async {
    await _engine?.switchCamera();
  }

  @override
  void dispose() {
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 32),
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

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 24),
              Text(
                'Connecting to ${widget.remoteUserName}...',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote video (full screen)
          _buildRemoteVideo(),

          // Local video (picture-in-picture, top right)
          if (!widget.isAudioOnly) _buildLocalVideo(),

          // Top bar
          _buildTopBar(),

          // Bottom controls
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildRemoteVideo() {
    if (widget.isAudioOnly) {
      return Container(
        color: const Color(0xFF1E293B),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white24,
                child: Text(
                  widget.remoteUserName[0].toUpperCase(),
                  style: const TextStyle(fontSize: 48, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.remoteUserName,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _remoteUserJoined ? 'Connected' : 'Calling...',
                style: TextStyle(
                  color: _remoteUserJoined ? Colors.greenAccent : Colors.white60,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine!,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    }

    return Container(
      color: const Color(0xFF1E293B),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white24,
              child: Text(
                widget.remoteUserName[0].toUpperCase(),
                style: const TextStyle(fontSize: 48, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.remoteUserName,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('Waiting for other person to join...', style: TextStyle(color: Colors.white60, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalVideo() {
    if (!_localUserJoined) return const SizedBox.shrink();

    return Positioned(
      top: 80,
      right: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 110,
          height: 150,
          child: _isCameraOff
              ? Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.videocam_off, color: Colors.white, size: 32),
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _endCall,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.remoteUserName,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      _remoteUserJoined ? 'Connected' : 'Calling...',
                      style: TextStyle(
                        color: _remoteUserJoined ? Colors.greenAccent : Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (!widget.isAudioOnly)
                IconButton(
                  icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                  onPressed: _switchCamera,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _controlBtn(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            label: _isMuted ? 'Unmute' : 'Mute',
            onTap: _toggleMute,
            active: _isMuted,
          ),
          if (!widget.isAudioOnly)
            _controlBtn(
              icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
              label: _isCameraOff ? 'Cam Off' : 'Camera',
              onTap: _toggleCamera,
              active: _isCameraOff,
            ),
          _controlBtn(
            icon: Icons.call_end,
            label: 'End',
            onTap: _endCall,
            isEnd: true,
          ),
          _controlBtn(
            icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
            label: 'Speaker',
            onTap: _toggleSpeaker,
            active: !_isSpeakerOn,
          ),
        ],
      ),
    );
  }

  Widget _controlBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
    bool isEnd = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isEnd
                  ? const Color(0xFFEF4444)
                  : active
                      ? Colors.white24
                      : Colors.white12,
              shape: BoxShape.circle,
              border: Border.all(
                color: active && !isEnd ? Colors.white54 : Colors.transparent,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}
