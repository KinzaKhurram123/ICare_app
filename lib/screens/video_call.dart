import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/agora_service.dart';
import '../services/call_service.dart';
import '../utils/app_keys.dart';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

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
  final CallService _callService = CallService();

  RtcEngine? _engine;
  bool _localVideoReady = false; // camera visible as soon as engine is ready
  bool _remoteUserJoined = false;
  int? _remoteUid;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isLoading = true;
  bool _isScreenSharing = false;
  String? _error;
  String _statusText = 'Connecting...';

  int _callDuration = 0;
  StreamSubscription<int>? _timerSubscription;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _initAgora();
  }

  // ─── INIT ────────────────────────────────────────────────────────────────

  Future<void> _initAgora() async {
    try {
      _setStatus('Requesting permissions...');

      // 1. Permissions
      if (!kIsWeb) {
        final status =
            await [Permission.camera, Permission.microphone].request();
        if (status[Permission.camera]?.isDenied == true ||
            status[Permission.microphone]?.isDenied == true) {
          _showError('Camera and microphone permissions are required.');
          return;
        }
      } else {
        try {
          _setStatus('Requesting camera access...');
          final stream = await web.window.navigator.mediaDevices
              .getUserMedia(
                  web.MediaStreamConstraints(video: true.toJS, audio: true.toJS))
              .toDart;
          // stop tracks — Agora will re-acquire them
          final tracks = stream.getTracks().toDart;
          for (final t in tracks) {
            t.stop();
          }
        } catch (e) {
          _showError(
              'Camera/microphone access denied.\nPlease allow in browser settings and refresh.');
          return;
        }
      }

      // 2. Fetch token
      _setStatus('Fetching call token...');
      final tokenResult =
          await _agoraService.getToken(channelName: widget.channelName);

      if (tokenResult['success'] != true) {
        _showError('Failed to get call token: ${tokenResult['message']}');
        return;
      }

      final data = tokenResult['data'] as Map;
      final token = data['token']?.toString() ?? '';
      final appId = data['appId']?.toString() ?? '';
      final uid = (data['uid'] as num?)?.toInt() ?? 0;

      if (token.isEmpty || appId.isEmpty) {
        _showError('Invalid token or App ID from server.');
        return;
      }

      // 3. Create + initialize engine (with retry for web bridge warm-up)
      _setStatus('Initializing video engine...');
      _engine = createAgoraRtcEngine();

      Exception? initError;
      for (int attempt = 1; attempt <= 5; attempt++) {
        try {
          await _engine!.initialize(RtcEngineContext(appId: appId));
          initError = null;
          break;
        } catch (e) {
          initError = e is Exception ? e : Exception(e.toString());
          if (attempt < 5) {
            await Future.delayed(Duration(milliseconds: 600 * attempt));
          }
        }
      }
      if (initError != null) throw initError;

      // 4. Register event handlers
      _registerHandlers();

      // 5. Enable video
      if (!widget.isAudioOnly) {
        _setStatus('Starting camera...');
        await _engine!.enableVideo();
        await _engine!.enableLocalVideo(true);
        await _engine!.setVideoEncoderConfiguration(
          const VideoEncoderConfiguration(
            dimensions: VideoDimensions(width: 640, height: 480),
            frameRate: 30,
            bitrate: 0, // auto
          ),
        );
      }

      // 6. Channel profile + role
      await _engine!
          .setChannelProfile(ChannelProfileType.channelProfileCommunication);
      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      // 7. Join channel
      _setStatus('Joining call...');
      await _engine!.joinChannel(
        token: token,
        channelId: widget.channelName,
        uid: uid,
        options: ChannelMediaOptions(
          autoSubscribeAudio: true,
          autoSubscribeVideo: !widget.isAudioOnly,
          publishCameraTrack: !widget.isAudioOnly,
          publishMicrophoneTrack: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );

      // Show local camera IMMEDIATELY — don't wait for onJoinChannelSuccess
      // (on web, the callback can be delayed)
      if (mounted) {
        setState(() {
          _isLoading = false;
          _localVideoReady = !widget.isAudioOnly;
          _statusText = 'Waiting for ${widget.remoteUserName}...';
        });
      }
    } catch (e, st) {
      debugPrint('🎥 ❌ Agora init error: $e\n$st');
      _showError('Failed to start call.\n$e');
    }
  }

  void _registerHandlers() {
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          debugPrint('✅ Joined channel UID=${connection.localUid}');
          if (mounted) {
            setState(() {
              _localVideoReady = !widget.isAudioOnly;
              _statusText = 'Waiting for ${widget.remoteUserName}...';
            });
          }
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          debugPrint('✅ Remote joined: uid=$remoteUid');
          if (mounted) {
            setState(() {
              _remoteUid = remoteUid;
              _remoteUserJoined = true;
            });
          }
        },
        onUserOffline: (connection, remoteUid, reason) {
          debugPrint('❌ Remote offline: uid=$remoteUid');
          if (mounted) {
            setState(() {
              _remoteUid = null;
              _remoteUserJoined = false;
            });
          }
        },
        onError: (err, msg) {
          debugPrint('❌ Agora error [$err]: $msg');
        },
        onRemoteVideoStateChanged:
            (connection, remoteUid, state, reason, elapsed) {
          debugPrint('📺 Remote video state uid=$remoteUid state=$state');
        },
        onFirstLocalVideoFrame: (source, width, height, elapsed) {
          debugPrint('📷 First local frame ${width}x$height');
          if (mounted && !_localVideoReady) {
            setState(() => _localVideoReady = true);
          }
        },
        onFirstRemoteVideoFrame:
            (connection, remoteUid, width, height, elapsed) {
          debugPrint('📺 First remote frame uid=$remoteUid ${width}x$height');
        },
      ),
    );
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────

  void _setStatus(String msg) {
    if (mounted) setState(() => _statusText = msg);
  }

  void _showError(String msg) {
    if (mounted) {
      setState(() {
        _error = msg;
        _isLoading = false;
      });
    }
  }

  Future<void> _endCall() async {
    try {
      await _callService.endCall(widget.channelName);
      await _engine?.leaveChannel();
      await _engine?.release();
      _engine = null;
    } catch (e) {
      debugPrint('End call error: $e');
    }
    if (appNavigatorKey.currentState?.canPop() == true) {
      appNavigatorKey.currentState?.pop();
    } else if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> _toggleMute() async {
    setState(() => _isMuted = !_isMuted);
    await _engine?.muteLocalAudioStream(_isMuted);
  }

  Future<void> _toggleCamera() async {
    setState(() => _isCameraOff = !_isCameraOff);
    await _engine?.muteLocalVideoStream(_isCameraOff);
  }

  Future<void> _switchCamera() async {
    try {
      await _engine?.switchCamera();
    } catch (_) {}
  }

  void _startTimer() {
    _timerSubscription =
        Stream.periodic(const Duration(seconds: 1), (i) => i + 1)
            .listen((s) {
      if (mounted && _remoteUserJoined) setState(() => _callDuration = s);
    });
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timerSubscription?.cancel();
    _engine?.leaveChannel();
    _engine?.release();
    _engine = null;
    super.dispose();
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_error != null) return _buildErrorScreen();
    if (_isLoading) return _buildLoadingScreen();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildMainVideo(),
          if (!widget.isAudioOnly) _buildLocalPiP(),
          _buildTopBar(),
          _buildBottomControls(),
        ],
      ),
    );
  }

  // ─── LOADING ──────────────────────────────────────────────────────────────

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundColor: Color(0xFF1E3A8A),
              child: Icon(Icons.videocam, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 32),
            Text(
              widget.remoteUserName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _statusText,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Color(0xFF3B82F6),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ERROR ────────────────────────────────────────────────────────────────

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline,
                    color: Colors.red, size: 56),
              ),
              const SizedBox(height: 24),
              const Text('Call Failed',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
                onPressed: _endCall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── MAIN VIDEO ───────────────────────────────────────────────────────────

  Widget _buildMainVideo() {
    if (widget.isAudioOnly) {
      return _buildAudioCallBg();
    }

    // Remote joined → remote video fills screen
    if (_remoteUserJoined && _remoteUid != null) {
      return AgoraVideoView(
        key: ValueKey('remote-$_remoteUid'),
        controller: VideoViewController.remote(
          rtcEngine: _engine!,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    }

    // Own camera fills screen while waiting
    if (_localVideoReady && _engine != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          AgoraVideoView(
            key: const ValueKey('local-main'),
            controller: VideoViewController(
              rtcEngine: _engine!,
              canvas: const VideoCanvas(uid: 0),
            ),
          ),
          // Dark gradient overlay at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
          ),
          // Waiting banner
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(160),
                  borderRadius: BorderRadius.circular(24),
                  border:
                      Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Waiting for ${widget.remoteUserName}...',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Camera off or engine not ready — dark bg with avatar
    return _buildAvatarBg(label: 'Camera is off');
  }

  Widget _buildAudioCallBg() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 70,
              backgroundColor: Colors.white.withAlpha(30),
              child: Text(
                widget.remoteUserName.isNotEmpty
                    ? widget.remoteUserName[0].toUpperCase()
                    : '?',
                style:
                    const TextStyle(fontSize: 52, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            Text(widget.remoteUserName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(
              _remoteUserJoined
                  ? _formatDuration(_callDuration)
                  : 'Calling...',
              style: const TextStyle(color: Colors.white60, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarBg({required String label}) {
    return Container(
      color: const Color(0xFF0F172A),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 64,
              backgroundColor: Colors.white12,
              child: Text(
                widget.remoteUserName.isNotEmpty
                    ? widget.remoteUserName[0].toUpperCase()
                    : '?',
                style:
                    const TextStyle(fontSize: 44, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Text(widget.remoteUserName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white54, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // ─── LOCAL PIP ────────────────────────────────────────────────────────────

  Widget _buildLocalPiP() {
    // Only show PiP when remote user is in call
    if (!_remoteUserJoined || _engine == null || widget.isAudioOnly) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 96,
      right: 12,
      child: Container(
        width: 108,
        height: 148,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white30, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(100),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _isCameraOff
              ? Container(
                  color: const Color(0xFF1E293B),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam_off,
                          color: Colors.white54, size: 28),
                      SizedBox(height: 4),
                      Text('Camera off',
                          style: TextStyle(
                              color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                )
              : AgoraVideoView(
                  key: const ValueKey('local-pip'),
                  controller: VideoViewController(
                    rtcEngine: _engine!,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ),
        ),
      ),
    );
  }

  // ─── TOP BAR ──────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black87, Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Back button
                _topBtn(Icons.arrow_back_ios_new_rounded, _endCall),
                const SizedBox(width: 12),
                // Name + status
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
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _remoteUserJoined
                                  ? Colors.greenAccent
                                  : Colors.orangeAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _remoteUserJoined
                                ? 'Connected • ${_formatDuration(_callDuration)}'
                                : _statusText,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Flip camera
                if (!widget.isAudioOnly)
                  _topBtn(Icons.flip_camera_ios_rounded, _switchCamera),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // ─── BOTTOM CONTROLS ──────────────────────────────────────────────────────

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black, Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ctrlBtn(
              icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
              label: _isMuted ? 'Unmute' : 'Mute',
              active: _isMuted,
              activeColor: Colors.red,
              onTap: _toggleMute,
            ),
            if (!widget.isAudioOnly)
              _ctrlBtn(
                icon: _isCameraOff
                    ? Icons.videocam_off_rounded
                    : Icons.videocam_rounded,
                label: _isCameraOff ? 'Cam Off' : 'Camera',
                active: _isCameraOff,
                activeColor: Colors.red,
                onTap: _toggleCamera,
              ),
            // End call — big red button in center
            GestureDetector(
              onTap: _endCall,
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withAlpha(100),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.call_end_rounded,
                    color: Colors.white, size: 30),
              ),
            ),
            if (!widget.isAudioOnly)
              _ctrlBtn(
                icon: _isScreenSharing
                    ? Icons.stop_screen_share_rounded
                    : Icons.present_to_all_rounded,
                label: _isScreenSharing ? 'Stop' : 'Share',
                active: _isScreenSharing,
                activeColor: Colors.green,
                onTap: () =>
                    setState(() => _isScreenSharing = !_isScreenSharing),
              ),
            _ctrlBtn(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Chat',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _ctrlBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
    Color activeColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: active
                  ? activeColor.withAlpha(40)
                  : Colors.white.withAlpha(25),
              shape: BoxShape.circle,
              border: Border.all(
                color: active ? activeColor : Colors.white24,
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: active ? activeColor : Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: active ? activeColor : Colors.white60,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
