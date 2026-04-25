import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/agora_service.dart';
import '../services/call_service.dart';
import '../utils/app_keys.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

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
  String? _error;
  String _appId = '';

  // Requirement 40.13: In-Call Features
  int _callDuration = 0;
  StreamSubscription<int>? _timerSubscription;
  bool _isScreenSharing = false;
  int _networkQuality = 4; // 1-5 (5 = Excellent)

  @override
  void initState() {
    super.initState();
    _initAgora().catchError((e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to start call: $e';
          _isLoading = false;
        });
      }
    });
    _startTimer();
  }

  void _startTimer() {
    _timerSubscription = Stream.periodic(const Duration(seconds: 1), (i) => i).listen((duration) {
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
    try {
      debugPrint('🎥 Step 1: Starting Agora init...');
      // On mobile, request permissions via permission_handler
      if (!kIsWeb) {
        await [Permission.camera, Permission.microphone].request();
      } else {
        // On web, explicitly request browser camera+mic permission BEFORE Agora init.
        // This forces Chrome to show the permission dialog and primes getUserMedia
        // so that Agora can access the devices without a second prompt.
        try {
          debugPrint('🎥 Step 1a: Requesting browser camera/mic permission...');
          final stream = await html.window.navigator.mediaDevices!
              .getUserMedia({'video': true, 'audio': true});
          // Stop all tracks immediately — Agora will open its own stream.
          stream.getTracks().forEach((t) => t.stop());
          debugPrint('🎥 Step 1a: Permission granted ✅');
        } catch (e) {
          debugPrint('🎥 Step 1a: Permission denied or unavailable: $e');
          if (mounted) {
            setState(() {
              _error = 'Camera/microphone access denied. Please allow in browser settings and try again.';
              _isLoading = false;
            });
          }
          return;
        }
      }

      debugPrint('🎥 Step 2: Fetching token for channel: ${widget.channelName}');
      // Fetch token from backend
      final tokenResult = await _agoraService.getToken(
        channelName: widget.channelName,
      );
      debugPrint('🎥 Step 3: Token result: $tokenResult');
      if (tokenResult['success'] != true) {
        if (mounted) {
          setState(() {
            _error = 'Could not start call: ${tokenResult['message']}';
            _isLoading = false;
          });
        }
        return;
      }

      final data = tokenResult['data'] as Map;
      final token = data['token']?.toString() ?? '';
      _appId = data['appId']?.toString() ?? '';
      final uid = (data['uid'] as num?)?.toInt() ?? 0;
      debugPrint('🎥 Step 4: token=$token appId=$_appId uid=$uid');

      if (token.isEmpty || _appId.isEmpty) {
        if (mounted) {
          setState(() {
            _error = 'Invalid token or appId from server';
            _isLoading = false;
          });
        }
        return;
      }

      debugPrint('🎥 Step 5: Creating engine...');
      // On web, iris_web_rtc bridge is injected asynchronously.
      // Retry initialize() until the bridge is ready (up to 5 attempts).
      _engine = createAgoraRtcEngine();
      debugPrint('🎥 Step 6: Engine created, initializing with retry...');
      Exception? initError;
      for (int attempt = 1; attempt <= 5; attempt++) {
        try {
          await _engine!.initialize(RtcEngineContext(appId: _appId));
          initError = null;
          break;
        } catch (e) {
          initError = e is Exception ? e : Exception(e.toString());
          debugPrint('🎥 Init attempt $attempt failed: $e');
          if (attempt < 5) {
            await Future.delayed(Duration(milliseconds: 600 * attempt));
          }
        }
      }
      if (initError != null) throw initError;
      debugPrint('🎥 Step 7: Engine initialized');

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
            if (mounted) {
              setState(() {
                _error = 'Call error ($err): $msg';
                _isLoading = false;
              });
            }
          },
        ),
      );

      if (!widget.isAudioOnly) {
        debugPrint('🎥 Step 8: Enabling video...');
        await _engine!.enableVideo();
        // startPreview is not supported on web
        if (!kIsWeb) {
          await _engine!.startPreview();
        }
      }

      debugPrint('🎥 Step 9: Setting client role...');
      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      debugPrint('🎥 Step 10: Joining channel: ${widget.channelName} uid=$uid');
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
      debugPrint('🎥 Step 11: Joined channel successfully!');

      if (mounted) setState(() => _isLoading = false);
    } catch (e, st) {
      debugPrint('🎥 ❌ Agora init error at: $e');
      debugPrint('🎥 Stack: $st');
      if (mounted) {
        setState(() {
          _error = 'Failed to start call: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _endCall() async {
    try {
      await _callService.endCall(widget.channelName);
      await _engine?.leaveChannel();
      await _engine?.release();
    } catch (_) {}
    // Use global navigator key — works regardless of where VideoCall was pushed from
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

  Future<void> _toggleSpeaker() async {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    await _engine?.setEnableSpeakerphone(_isSpeakerOn);
  }

  Future<void> _switchCamera() async {
    await _engine?.switchCamera();
  }

  @override
  void dispose() {
    _timerSubscription?.cancel();
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
                  onPressed: _endCall,
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
          // Main video: own camera until remote joins, then remote video
          _buildMainVideo(),

          // PIP: small self-view in corner only when remote is present
          _buildLocalPiP(),

          // Top bar
          _buildTopBar(),

          // Bottom controls
          _buildControls(),
        ],
      ),
    );
  }

  /// Main (full-screen) video layer.
  /// • If remote has joined → show remote video (Zoom style)
  /// • If remote not yet joined and we have local video → show OWN camera big
  /// • Fallback → avatar placeholder
  Widget _buildMainVideo() {
    // ── Audio-only mode ──────────────────────────────────────────────────────
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
                  color: _remoteUserJoined ? Colors.greenAccent : Colors.white60,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── Remote joined → remote video fills screen ────────────────────────────
    if (_remoteUserJoined && _remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine!,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    }

    // ── Waiting for remote: show OWN camera as main screen ───────────────────
    if (_localUserJoined && !_isCameraOff) {
      return Stack(
        fit: StackFit.expand,
        children: [
          AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: _engine!,
              canvas: const VideoCanvas(uid: 0),
            ),
          ),
          // "Waiting" banner at bottom of own preview
          Positioned(
            bottom: 130,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Waiting for ${widget.remoteUserName} to join...',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // ── Fallback: avatar placeholder (camera off or not yet joined) ──────────
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

  /// Small PIP overlay (top-right corner) — only visible when BOTH are in call.
  /// Shows local camera so you can see yourself while watching the remote feed.
  Widget _buildLocalPiP() {
    // Only show PIP when remote user is present (otherwise own cam IS the main screen)
    if (!_remoteUserJoined || !_localUserJoined || widget.isAudioOnly) {
      return const SizedBox.shrink();
    }

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
              // Network Quality Indicator
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
