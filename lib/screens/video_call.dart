import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:js' as js;
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

  int _callDuration = 0;
  late Stream<int> _timerStream;
  bool _isScreenSharing = false;
  int _networkQuality = 4;

  @override
  void initState() {
    super.initState();
    _initAgora();
    _startTimer();
  }

  void _startTimer() {
    _timerStream = Stream.periodic(const Duration(seconds: 1), (i) => i);
    _timerStream.listen((duration) {
      if (mounted && _remoteUserJoined) {
        setState(() => _callDuration = duration);
      }
    });
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _initAgora() async {
    if (kIsWeb) {
      await _initWebVideo();
      return;
    }

    // Mobile initialization
    await [Permission.camera, Permission.microphone].request();

    final tokenResult = await _agoraService.getToken(
      channelName: widget.channelName,
    );
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

  Future<void> _initWebVideo() async {
    try {
      final tokenResult = await _agoraService.getToken(
        channelName: widget.channelName,
      );
      if (tokenResult['success'] != true) {
        setState(() {
          _error = 'Failed to get call token: ${tokenResult['message']}';
          _isLoading = false;
        });
        return;
      }

      final tokenRaw = tokenResult['data']['token'];
      final token = (tokenRaw != null && tokenRaw.toString().isNotEmpty) ? tokenRaw.toString() : null;
      _appId = tokenResult['data']['appId'] as String;
      final uid = tokenResult['data']['uid'] as int;

      // Initialize Agora Web SDK via JavaScript
      js.context.callMethod('initAgoraWeb', [_appId, widget.channelName, token, uid]);

      if (mounted) {
        setState(() {
          _localUserJoined = true;
          _remoteUserJoined = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error initializing video: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _endCall() async {
    await _engine?.leaveChannel();
    await _engine?.release();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _toggleMute() async {
    setState(() => _isMuted = !_isMuted);
    if (!kIsWeb) {
      await _engine?.muteLocalAudioStream(_isMuted);
    }
  }

  Future<void> _toggleCamera() async {
    setState(() => _isCameraOff = !_isCameraOff);
    if (!kIsWeb) {
      await _engine?.muteLocalVideoStream(_isCameraOff);
    }
  }

  Future<void> _toggleSpeaker() async {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    if (!kIsWeb) {
      await _engine?.setEnableSpeakerphone(_isSpeakerOn);
    }
  }

  Future<void> _switchCamera() async {
    if (!kIsWeb) {
      await _engine?.switchCamera();
    }
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

    if (kIsWeb) {
      return _buildWebVideoInterface();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildRemoteVideo(),
          if (!widget.isAudioOnly) _buildLocalVideo(),
          _buildTopBar(),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildWebVideoInterface() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: _endCall,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.remoteUserName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _remoteUserJoined ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _remoteUserJoined
                      ? _formatDuration(_callDuration)
                      : 'Connecting...',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Remote video area
                Container(
                  color: const Color(0xFF1E293B),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.white24,
                          child: Text(
                            widget.remoteUserName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 64,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          widget.remoteUserName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _remoteUserJoined ? 'Connected' : 'Waiting for connection...',
                          style: TextStyle(
                            color: _remoteUserJoined
                                ? Colors.greenAccent
                                : Colors.white60,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Local video preview (top right)
                if (!widget.isAudioOnly && !_isCameraOff)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      width: 140,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam_rounded,
                            color: Colors.white54,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your Camera',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFF1E293B),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _controlBtn(
                  icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                  label: _isMuted ? 'Unmute' : 'Mute',
                  onTap: _toggleMute,
                  active: _isMuted,
                ),
                if (!widget.isAudioOnly)
                  _controlBtn(
                    icon: _isCameraOff
                        ? Icons.videocam_off_rounded
                        : Icons.videocam_rounded,
                    label: 'Camera',
                    onTap: _toggleCamera,
                    active: _isCameraOff,
                  ),
                _controlBtn(
                  icon: Icons.call_end_rounded,
                  label: 'End Call',
                  onTap: _endCall,
                  isEnd: true,
                ),
              ],
            ),
          ),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _remoteUserJoined ? 'Connected' : 'Calling...',
                style: TextStyle(
                  color: _remoteUserJoined
                      ? Colors.greenAccent
                      : Colors.white60,
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Waiting for other person to join...',
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
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
                  child: const Icon(
                    Icons.videocam_off,
                    color: Colors.white,
                    size: 32,
                  ),
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: _endCall,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.remoteUserName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _remoteUserJoined
                                ? Colors.green
                                : Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _remoteUserJoined
                              ? _formatDuration(_callDuration)
                              : 'Connecting...',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: List.generate(
                    5,
                    (index) => Container(
                      margin: const EdgeInsets.only(left: 2),
                      width: 3,
                      height: (index + 1) * 3.0,
                      decoration: BoxDecoration(
                        color: index < _networkQuality
                            ? Colors.greenAccent
                            : Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (!widget.isAudioOnly)
                IconButton(
                  icon: const Icon(
                    Icons.flip_camera_ios_rounded,
                    color: Colors.white,
                  ),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _controlBtn(
              icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
              label: _isMuted ? 'Unmute' : 'Mute',
              onTap: _toggleMute,
              active: _isMuted,
            ),
            if (!widget.isAudioOnly) ...[
              _controlBtn(
                icon: _isCameraOff
                    ? Icons.videocam_off_rounded
                    : Icons.videocam_rounded,
                label: 'Camera',
                onTap: _toggleCamera,
                active: _isCameraOff,
              ),
              _controlBtn(
                icon: Icons.present_to_all_rounded,
                label: 'Share',
                onTap: () =>
                    setState(() => _isScreenSharing = !_isScreenSharing),
                active: _isScreenSharing,
              ),
            ],
            _controlBtn(
              icon: Icons.call_end_rounded,
              label: 'End',
              onTap: _endCall,
              isEnd: true,
            ),
          ],
        ),
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
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
