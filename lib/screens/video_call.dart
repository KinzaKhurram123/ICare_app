import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/agora_service.dart';
import '../services/call_service.dart';
import '../utils/app_keys.dart';
// ignore: avoid_web_libraries_in_flutter
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
  bool _localUserJoined = false;
  bool _remoteUserJoined = false;
  int? _remoteUid;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;
  bool _isLoading = true;
  bool _isScreenSharing = false;
  String? _error;

  int _callDuration = 0;
  StreamSubscription<int>? _timerSubscription;

  @override
  void initState() {
    super.initState();
    _initAgora();
    _startTimer();
    debugPrint('📞 VideoCall initialized:');
    debugPrint('   channelName: ${widget.channelName}');
    debugPrint('   remoteUserName: ${widget.remoteUserName}');
    debugPrint('   isAudioOnly: ${widget.isAudioOnly}');
  }

  Future<void> _initAgora() async {
    try {
      debugPrint('🎥 [1] Starting Agora initialization...');

      // Request permissions
      if (!kIsWeb) {
        final status = await [Permission.camera, Permission.microphone].request();
        if (status[Permission.camera]?.isDenied == true ||
            status[Permission.microphone]?.isDenied == true) {
          if (mounted) {
            setState(() {
              _error = 'Camera and microphone permissions are required';
              _isLoading = false;
            });
          }
          return;
        }
      } else {
        try {
          debugPrint('🎥 [1a] Requesting web camera/mic permission...');
          final stream = await web.window.navigator.mediaDevices
              .getUserMedia(web.MediaStreamConstraints(
                video: true.toJS,
                audio: true.toJS,
              ))
              .toDart;
          final tracks = stream.getTracks().toDart;
          for (final t in tracks) {
            t.stop();
          }
          debugPrint('🎥 [1a] Web permission granted ✅');
        } catch (e) {
          debugPrint('🎥 [1a] Web permission denied: $e');
          if (mounted) {
            setState(() {
              _error =
                  'Camera/microphone access denied. Please allow in browser settings.';
              _isLoading = false;
            });
          }
          return;
        }
      }

      // Fetch Agora token
      debugPrint('🎥 [2] Fetching Agora token...');
      final tokenResult = await _agoraService.getToken(
        channelName: widget.channelName,
      );
      debugPrint('🎥 [3] Token response: ${tokenResult['success']}');

      if (tokenResult['success'] != true) {
        if (mounted) {
          setState(() {
            _error = 'Failed to get call token: ${tokenResult['message']}';
            _isLoading = false;
          });
        }
        return;
      }

      final data = tokenResult['data'] as Map;
      final token = data['token']?.toString() ?? '';
      final appId = data['appId']?.toString() ?? '';
      final uid = (data['uid'] as num?)?.toInt() ?? 0;

      debugPrint(
          '🎥 [4] Token received: ${token.isNotEmpty ? 'OK' : 'MISSING'}');
      debugPrint('🎥 [4] AppId: $appId, UID: $uid');

      if (token.isEmpty || appId.isEmpty) {
        if (mounted) {
          setState(() {
            _error = 'Invalid token or App ID from server';
            _isLoading = false;
          });
        }
        return;
      }

      // Create Agora engine
      debugPrint('🎥 [5] Creating Agora engine...');
      _engine = createAgoraRtcEngine();

      // Initialize with retry (web needs bridge warm-up)
      Exception? initError;
      for (int attempt = 1; attempt <= 5; attempt++) {
        try {
          debugPrint('🎥 [5a] Init attempt $attempt...');
          await _engine!.initialize(RtcEngineContext(appId: appId));
          initError = null;
          break;
        } catch (e) {
          initError = e is Exception ? e : Exception(e.toString());
          debugPrint('🎥 [5a] Init attempt $attempt failed: $e');
          if (attempt < 5) {
            await Future.delayed(Duration(milliseconds: 600 * attempt));
          }
        }
      }
      if (initError != null) throw initError;

      debugPrint('🎥 [6] Engine initialized ✅');

      // Set up event handlers
      _setupEventHandlers();

      // Enable video if not audio-only
      if (!widget.isAudioOnly) {
        debugPrint('🎥 Step 8: Enabling video module...');
        await _engine!.enableVideo();
        // Explicitly enable local video track
        await _engine!.enableLocalVideo(true);
        // Configure video encoding
        await _engine!.setVideoEncoderConfiguration(
          const VideoEncoderConfiguration(
            dimensions: VideoDimensions(width: 640, height: 480),
            frameRate: 30,
            bitrate: 1500,
          ),
        );
        debugPrint('🎥 Step 8a: Video encoder configured');
      }

      // Set channel profile
      debugPrint('🎥 [8] Setting channel profile...');
      await _engine!
          .setChannelProfile(ChannelProfileType.channelProfileCommunication);

      // Set client role
      debugPrint('🎥 [9] Setting client role...');
      await _engine!
          .setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      // Join channel
      debugPrint('🎥 [10] Joining channel: ${widget.channelName}');
      await _engine!.joinChannel(
        token: token,
        channelId: widget.channelName,
        uid: uid,
        options: ChannelMediaOptions(
          autoSubscribeAudio: true,
          autoSubscribeVideo: !widget.isAudioOnly,
          publishCameraTrack: !widget.isAudioOnly && !_isCameraOff,
          publishMicrophoneTrack: !_isMuted,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );

      debugPrint('🎥 [11] Channel join command sent ✅');

      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('🎥 [12] VideoCall UI ready ✅');
    } catch (e, st) {
      debugPrint('🎥 ❌ Agora init error: $e');
      debugPrint('🎥 Stack trace: $st');
      if (mounted) {
        setState(() {
          _error = 'Failed to start call: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _setupEventHandlers() {
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          debugPrint(
              '✅ onJoinChannelSuccess: UID=${connection.localUid}, elapsed=$elapsed');
          if (mounted) {
            setState(() => _localUserJoined = true);
          }
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          debugPrint(
              '✅ onUserJoined: remoteUid=$remoteUid, elapsed=$elapsed');
          if (mounted) {
            setState(() {
              _remoteUid = remoteUid;
              _remoteUserJoined = true;
            });
          }
        },
        onUserOffline: (connection, remoteUid, reason) {
          debugPrint('❌ onUserOffline: remoteUid=$remoteUid, reason=$reason');
          if (mounted) {
            setState(() {
              _remoteUid = null;
              _remoteUserJoined = false;
            });
          }
        },
        onError: (err, msg) {
          debugPrint('❌ Agora Error [code=$err]: $msg');
          if (mounted) {
            setState(() {
              _error = 'Agora error ($err): $msg';
              _isLoading = false;
            });
          }
        },
        onRemoteVideoStateChanged:
            (connection, remoteUid, state, reason, elapsed) {
          debugPrint(
              '📺 Remote video state: UID=$remoteUid, state=$state, reason=$reason');
        },
        onRemoteAudioStateChanged:
            (connection, remoteUid, state, reason, elapsed) {
          debugPrint(
              '🔈 Remote audio state: UID=$remoteUid, state=$state, reason=$reason');
        },
        onFirstLocalVideoFrame: (source, width, height, elapsed) {
          debugPrint('📷 First local video frame: ${width}x$height');
        },
        onFirstRemoteVideoFrame:
            (connection, remoteUid, width, height, elapsed) {
          debugPrint(
              '📺 First remote video frame: UID=$remoteUid, ${width}x$height');
        },
      ),
    );
    debugPrint('🎯 Event handlers registered ✅');
  }

  Future<void> _endCall() async {
    try {
      await _callService.endCall(widget.channelName);
      await _engine?.leaveChannel();
      await _engine?.release();
      _engine = null;
    } catch (e) {
      debugPrint('Error ending call: $e');
    }

    if (appNavigatorKey.currentState?.canPop() == true) {
      appNavigatorKey.currentState?.pop();
    } else if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> _toggleMute() async {
    final newState = !_isMuted;
    setState(() => _isMuted = newState);
    await _engine?.muteLocalAudioStream(newState);
    debugPrint('🎤 Mute: $_isMuted');
  }

  Future<void> _toggleCamera() async {
    final newState = !_isCameraOff;
    setState(() => _isCameraOff = newState);
    await _engine?.muteLocalVideoStream(newState);
    debugPrint('📷 Camera off: $_isCameraOff');
  }

  Future<void> _toggleSpeaker() async {
    final newState = !_isSpeakerOn;
    setState(() => _isSpeakerOn = newState);
    await _engine?.setEnableSpeakerphone(newState);
    debugPrint('🔊 Speakerphone: $_isSpeakerOn');
  }

  Future<void> _switchCamera() async {
    try {
      await _engine?.switchCamera();
      debugPrint('🔄 Camera switched');
    } catch (e) {
      debugPrint('❌ Switch camera error: $e');
    }
  }

  void _startTimer() {
    _timerSubscription =
        Stream.periodic(const Duration(seconds: 1), (i) => i + 1)
            .listen((seconds) {
      if (mounted && _remoteUserJoined) {
        setState(() => _callDuration = seconds);
      }
    });
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timerSubscription?.cancel();
    _engine?.leaveChannel();
    _engine?.release();
    _engine = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorScreen();
    }

    if (_isLoading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildMainVideo(),
          if (!widget.isAudioOnly) _buildLocalPiP(),
          _buildTopBar(),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
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
                onPressed: _endCall,
                child: const Text('End Call & Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
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
            const SizedBox(height: 12),
            Text(
              'Channel: ${widget.channelName}',
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// Main video area:
  /// - Audio-only → avatar placeholder
  /// - Remote joined → remote video fills screen (Zoom style)
  /// - Waiting for remote → own camera fills screen + "waiting" banner
  /// - Fallback → dark placeholder
  Widget _buildMainVideo() {
    if (widget.isAudioOnly) {
      return _buildAvatarPlaceholder(
        label: _remoteUserJoined ? 'Connected' : 'Calling...',
        connected: _remoteUserJoined,
      );
    }

    if (_remoteUserJoined && _remoteUid != null) {
      return SizedBox.expand(
        child: AgoraVideoView(
          key: ValueKey('remote-$_remoteUid'),
          controller: VideoViewController.remote(
            rtcEngine: _engine!,
            canvas: VideoCanvas(
              uid: _remoteUid,
              renderMode: VideoRenderMode.hidden,
              // Platform-specific optimizations
              useAndroidSurfaceView: !kIsWeb,
              useFlutterTexture: kIsWeb,
            ),
            connection: RtcConnection(channelId: widget.channelName),
          ),
        ),
      );
    }

    if (_localUserJoined && !_isCameraOff) {
      // Own camera fills screen while waiting (Zoom style)
      return Stack(
        fit: StackFit.expand,
        children: [
          AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: _engine!,
              canvas: VideoCanvas(
                uid: 0,
                renderMode: VideoRenderMode.hidden,
                useAndroidSurfaceView: !kIsWeb,
                useFlutterTexture: kIsWeb,
              ),
            ),
          ),
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Waiting for ${widget.remoteUserName} to join...',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Fallback — camera off or engine not ready yet
    return _buildAvatarPlaceholder(
      label: !_localUserJoined
          ? 'Starting camera...'
          : _isCameraOff
              ? 'Camera is off'
              : 'Waiting...',
      connected: false,
    );
  }

  Widget _buildAvatarPlaceholder(
      {required String label, required bool connected}) {
    return Container(
      color: const Color(0xFF1E293B),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white24,
              child: Text(
                widget.remoteUserName.isNotEmpty
                    ? widget.remoteUserName[0].toUpperCase()
                    : '?',
                style: const TextStyle(fontSize: 56, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.remoteUserName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: connected
                    ? Colors.green.withOpacity(0.3)
                    : Colors.orange.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: connected ? Colors.green : Colors.orange,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: connected ? Colors.greenAccent : Colors.orangeAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// PiP overlay — own camera small in top-right corner, only shown when
  /// both users are connected (Zoom style).
  Widget _buildLocalPiP() {
    if (!_remoteUserJoined || !_localUserJoined || widget.isAudioOnly) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 80,
      right: 16,
      child: Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _isCameraOff
              ? Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.videocam_off,
                      color: Colors.white54, size: 32),
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
                  icon:
                      const Icon(Icons.close_rounded, color: Colors.white),
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
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _remoteUserJoined
                                ? Colors.green
                                : Colors.orange,
                            shape: BoxShape.circle,
                            boxShadow: _remoteUserJoined
                                ? [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.5),
                                      blurRadius: 4,
                                    )
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _remoteUserJoined
                              ? 'Connected • ${_formatDuration(_callDuration)}'
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _controlBtn(
              icon:
                  _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
              label: _isMuted ? 'Unmute' : 'Mute',
              onTap: _toggleMute,
              active: _isMuted,
              color: _isMuted ? Colors.red : Colors.white,
            ),
            if (!widget.isAudioOnly) ...[
              _controlBtn(
                icon: _isCameraOff
                    ? Icons.videocam_off_rounded
                    : Icons.videocam_rounded,
                label: 'Camera',
                onTap: _toggleCamera,
                active: _isCameraOff,
                color: _isCameraOff ? Colors.red : Colors.white,
              ),
              _controlBtn(
                icon: Icons.present_to_all_rounded,
                label: 'Share',
                onTap: () =>
                    setState(() => _isScreenSharing = !_isScreenSharing),
                active: _isScreenSharing,
                color: _isScreenSharing ? Colors.green : Colors.white,
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
    Color? color,
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
                      : Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
              border: Border.all(
                color: active && !isEnd
                    ? (color ?? Colors.white)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(icon, color: color ?? Colors.white, size: 26),
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
