// Web video call — Agora Web SDK via dart:js_interop
import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import '../services/agora_service.dart';
import '../services/api_service.dart';
import '../models/appointment_detail.dart';
import '../services/appointment_service.dart';
import '../services/call_service.dart';
import '../services/medical_record_service.dart';
import '../utils/theme.dart';
import '../screens/end_consultation_workflow.dart';
import '../utils/shared_pref.dart';

// JS interop
@JS('agoraJoin')
external JSPromise<JSString> _agoraJoin(
    JSString appId, JSString channel, JSString token, JSNumber uid);

@JS('agoraLeave')
external JSPromise<JSAny?> _agoraLeave();

@JS('agoraMuteMic')
external void _agoraMuteMic(JSBoolean mute);

@JS('agoraMuteCam')
external void _agoraMuteCam(JSBoolean mute);
class VideoCall extends StatefulWidget {
  final String channelName;
  final String remoteUserName;
  final bool isAudioOnly;
  final String currentUserId;
  final String currentUserName;
  /// Optional appointment ID — used to mark consultation in progress / end
  final String? appointmentId;
  /// Patient's user ID — used to load patient history (doctor-side only)
  final String? patientId;

  const VideoCall({
    super.key,
    required this.channelName,
    required this.remoteUserName,
    this.isAudioOnly = false,
    this.currentUserId = '',
    this.currentUserName = 'User',
    this.appointmentId,
    this.patientId,
  });

  @override
  State<VideoCall> createState() => _VideoCallWebState();
}

class _VideoCallWebState extends State<VideoCall> {
  bool _loading = true;
  bool _joined = false;
  bool _micMuted = false;
  bool _camOff = false;
  String? _error;

  // Side panel state
  bool _showChat = false;
  bool _showHistory = false;

  // Chat messages (synced via backend API)
  final List<Map<String, String>> _chatMessages = [];
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScroll = ScrollController();
  Timer? _chatPollTimer;
  int _lastChatTimestamp = 0; // epoch ms of last fetched message
  bool _pollInProgress = false; // prevents overlapping polls
  int _unreadChatCount = 0; // unread message count for notification badge

  // Timer for 15-min session
  Timer? _sessionTimer;
  int _sessionSeconds = 0;

  // Poll appointment status — if doctor ends consultation, patient side closes too
  Timer? _statusPollTimer;

  // Patient history (real data from backend)
  List<Map<String, dynamic>> _historyRecords = [];
  bool _historyLoading = false;
  bool _historyLoaded = false;

  final String _viewId =
      'agora-call-${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    _registerView();
    _joinCall();
    _startSessionTimer();
    _startChatPolling();
    // Only poll status if we have an appointmentId (not for quick calls)
    if (widget.appointmentId != null && widget.appointmentId!.isNotEmpty) {
      _startStatusPolling();
    }
  }

  /// Poll appointment status every 5 seconds.
  /// If doctor marks it 'completed', patient side auto-closes.
  void _startStatusPolling() {
    _statusPollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted || widget.appointmentId == null) return;
      try {
        final api = ApiService();
        final response = await api.get(
          '/appointments/getAppointments',
        );
        final appts = response.data['appointments'] as List? ?? [];
        final match = appts.firstWhere(
          (a) => (a['_id'] ?? a['id'])?.toString() == widget.appointmentId,
          orElse: () => null,
        );
        if (match != null && match['status'] == 'completed' && mounted) {
          _statusPollTimer?.cancel();
          // Doctor ended the consultation — close patient side too
          try { await _agoraLeave().toDart; } catch (_) {}
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: Colors.green, size: 28),
                    SizedBox(width: 8),
                    Text('Consultation Ended',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
                content: const Text(
                    'The doctor has ended this consultation. Thank you!'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      } catch (_) {
        // Non-critical — silently ignore
      }
    });
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _sessionSeconds++);
        // At exactly 15 minutes — show a non-blocking notification
        if (_sessionSeconds == 900) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.timer_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 10),
                  Text('15 minutes reached — consultation continues until you end it'),
                ],
              ),
              backgroundColor: Colors.orange.shade700,
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });
  }

  /// Poll backend every 2 seconds for new chat messages
  void _startChatPolling() {
    _chatPollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      _fetchNewMessages();
    });
  }

  Future<void> _fetchNewMessages() async {
    // Prevent overlapping polls — if previous fetch is still running, skip
    if (_pollInProgress) return;
    _pollInProgress = true;
    try {
      final api = ApiService();
      final response = await api.get(
        '/call-chat/messages/${Uri.encodeComponent(widget.channelName)}',
        queryParameters: {'since': _lastChatTimestamp.toString()},
      );
      final msgs = response.data['messages'] as List? ?? [];
      if (msgs.isEmpty) return;

      // Update timestamp FIRST (before UI update) so any concurrent call won't re-fetch
      final lastTs = msgs.last['createdAt'];
      if (lastTs != null) {
        final parsed = DateTime.tryParse(lastTs.toString())?.millisecondsSinceEpoch;
        if (parsed != null) _lastChatTimestamp = parsed;
      }

      // Filter out messages we already showed optimistically (our own sent msgs)
      final newMsgs = <Map<String, String>>[];
      for (final m in msgs) {
        final sender = m['sender']?.toString() ?? '';
        final text = m['text']?.toString() ?? '';
        // Skip our own messages — already shown optimistically (match by sender+text)
        final alreadyShown = sender == _mySenderName &&
            _chatMessages.any((c) => c['sender'] == sender && c['text'] == text);
        if (!alreadyShown) {
          newMsgs.add({'sender': sender, 'text': text});
        }
      }

      if (mounted && newMsgs.isNotEmpty) {
        setState(() {
          _chatMessages.addAll(newMsgs);
          // Increment unread count only if chat panel is closed
          if (!_showChat) {
            _unreadChatCount += newMsgs.length;
          }
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_chatScroll.hasClients) {
            _chatScroll.animateTo(
              _chatScroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (_) {
      // Non-critical — silently ignore poll errors
    } finally {
      _pollInProgress = false;
    }
  }

  Future<void> _loadPatientHistory() async {
    if (_historyLoading) return;
    setState(() => _historyLoading = true);

    final pid = widget.patientId;
    final records = <Map<String, dynamic>>[];

    // 1. Try medical records (works when patientId is provided — doctor viewing patient)
    if (pid != null && pid.isNotEmpty) {
      try {
        final result = await MedicalRecordService().getPatientRecords(pid);
        final raw = result['records'];
        if (raw is List) records.addAll(raw.cast<Map<String, dynamic>>());
      } catch (_) {}
    }

    // 2. Load past appointments for history — works for both patient and doctor
    //    For the patient: shows their own history
    //    For the doctor: shows appointments linked to this consultation channel
    try {
      final apptResult = await AppointmentService().getMyAppointmentsDetailed();
      if (apptResult['success'] == true) {
        final appts = apptResult['appointments'] as List<AppointmentDetail>? ?? [];
        // Include completed appointments that have a complaint or notes
        for (final a in appts) {
          if (a.status.toLowerCase() == 'completed') {
            records.add({
              'type': 'appointment',
              'date': a.date.toIso8601String(),
              'createdAt': a.date.toIso8601String(),
              'chiefComplaint': a.reason ?? '',
              'doctor': {'name': a.doctorName},
              'timeSlot': a.timeSlot,
            });
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _historyRecords = records;
        _historyLoaded = true;
        _historyLoading = false;
      });
    }
  }

  String get _sessionTimeStr {
    final m = _sessionSeconds ~/ 60;
    final s = _sessionSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _registerView() {
    try {
      ui.platformViewRegistry.registerViewFactory(_viewId, (int id) {
        final container =
            web.document.createElement('div') as web.HTMLDivElement;
        container.style.width = '100%';
        container.style.height = '100%';
        container.style.background = '#0A1628';
        container.style.position = 'relative';

        final remote =
            web.document.createElement('div') as web.HTMLDivElement;
        remote.id = 'agora-remote';
        remote.style.width = '100%';
        remote.style.height = '100%';
        remote.style.background = '#0A1628';
        container.appendChild(remote);

        final local = web.document.createElement('div') as web.HTMLDivElement;
        local.id = 'agora-local';
        local.style.position = 'absolute';
        local.style.top = '16px';
        local.style.right = '16px';
        local.style.width = '110px';
        local.style.height = '160px';
        local.style.borderRadius = '12px';
        local.style.overflow = 'hidden';
        local.style.background = '#1E293B';
        local.style.zIndex = '10';
        container.appendChild(local);

        return container;
      });
    } catch (_) {}
  }

  Future<void> _joinCall() async {
    try {
      final tokenData = await AgoraService().getToken(
        channelName: widget.channelName,
        uid: 0,
      );

      if (tokenData['success'] != true) {
        if (mounted) {
          setState(() {
            _error = tokenData['message'] ?? 'Failed to get Agora token';
            _loading = false;
          });
        }
        return;
      }

      final token = tokenData['data']['token'] as String;
      final appId = tokenData['data']['appId'] as String;

      final result = await _agoraJoin(
        appId.toJS,
        widget.channelName.toJS,
        token.toJS,
        0.toJS,
      ).toDart;

      final resultStr = result.toDart;
      if (resultStr.startsWith('error:')) {
        // Non-fatal: show warning but still allow video call to proceed
        // (other party may still be able to connect)
        debugPrint('⚠️ Agora join warning: $resultStr');
        if (mounted) setState(() { _joined = true; _loading = false; });
      } else {
        if (mounted) setState(() { _joined = true; _loading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  /// Red button — leave video but keep consultation "in progress"
  Future<void> _leaveVideo() async {
    try { await _agoraLeave().toDart; } catch (_) {}

    // Mark appointment as in_progress so patient can rejoin
    if (widget.appointmentId != null && widget.appointmentId!.isNotEmpty) {
      try {
        await AppointmentService().updateAppointmentStatus(
          appointmentId: widget.appointmentId!,
          status: 'in_progress',
        );
        debugPrint('✅ Marked in_progress: ${widget.appointmentId}');
      } catch (e) {
        debugPrint('❌ Failed to mark in_progress: $e');
      }
    } else {
      debugPrint('⚠️ appointmentId is null — cannot mark in_progress. channelName: ${widget.channelName}');
    }

    if (mounted) Navigator.pop(context);
  }
  /// End Consultation button — opens workflow screen for doctor to complete documentation
  Future<void> _endConsultation() async {
    // Check if this is a doctor ending consultation (has appointment details)
    if (widget.appointmentId == null || widget.appointmentId!.isEmpty) {
      // No appointment ID - just leave the call (for quick calls)
      try { await CallService().endCall(widget.channelName); } catch (_) {}
      try { await _agoraLeave().toDart; } catch (_) {}
      if (mounted) Navigator.pop(context);
      return;
    }

    // Check if current user is doctor
    final currentUser = await SharedPref().getUserData();
    final isDoctor = currentUser?.role?.toLowerCase() == 'doctor';

    if (!isDoctor) {
      // Patient cannot end consultation - only leave video
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only the doctor can end the consultation'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Doctor ending consultation - fetch appointment details and open workflow
    try {
      final api = ApiService();
      final response = await api.get('/appointments/getAppointments');
      final appts = response.data['appointments'] as List? ?? [];
      final match = appts.firstWhere(
        (a) => (a['_id'] ?? a['id'])?.toString() == widget.appointmentId,
        orElse: () => null,
      );

      if (match == null) {
        throw Exception('Appointment not found');
      }

      final appointment = AppointmentDetail.fromJson(match);

      // Leave video call first
      try { await _agoraLeave().toDart; } catch (_) {}

      if (!mounted) return;

      // Open End Consultation Workflow screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EndConsultationWorkflow(appointment: appointment),
        ),
      );

      // After workflow completes, close video call screen
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Mute mic ONLY — does NOT affect camera
  void _toggleMic() {
    _micMuted = !_micMuted;
    try { _agoraMuteMic(_micMuted.toJS); } catch (_) {}
    if (mounted) setState(() {});
  }

  /// Toggle camera ONLY — does NOT affect mic
  void _toggleCam() {
    _camOff = !_camOff;
    try { _agoraMuteCam(_camOff.toJS); } catch (_) {}
    if (mounted) setState(() {});
  }

  String get _mySenderName =>
      widget.currentUserName.isNotEmpty ? widget.currentUserName : 'User';

  void _sendChatMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    _chatController.clear();

    // Show message immediately (optimistic)
    if (mounted) {
      setState(() => _chatMessages.add({'sender': _mySenderName, 'text': text}));
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_chatScroll.hasClients) {
          _chatScroll.animateTo(
            _chatScroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }

    // Send to backend (update lastTimestamp so poll skips duplicates)
    ApiService().post('/call-chat/send', {
      'channelName': widget.channelName,
      'sender': _mySenderName,
      'text': text,
    }).then((res) {
      // Update lastTimestamp from the saved message so poll won't duplicate it
      try {
        final createdAt = res.data['message']?['createdAt']?.toString();
        if (createdAt != null) {
          final ts = DateTime.tryParse(createdAt)?.millisecondsSinceEpoch;
          if (ts != null) _lastChatTimestamp = ts;
        }
      } catch (_) {}
    }).catchError((_) {
      // Message already shown optimistically — no action needed
    });
  }

  Future<void> _pickAndSendFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(withData: true);
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final fileMsg = '📎 ${file.name}';
      // Show locally immediately
      if (mounted) setState(() => _chatMessages.add({'sender': _mySenderName, 'text': fileMsg}));
      // Also send to backend so other party sees it
      ApiService().post('/call-chat/send', {
        'channelName': widget.channelName,
        'sender': _mySenderName,
        'text': fileMsg,
      }).then((res) {
        try {
          final createdAt = res.data['message']?['createdAt']?.toString();
          if (createdAt != null) {
            final ts = DateTime.tryParse(createdAt)?.millisecondsSinceEpoch;
            if (ts != null) _lastChatTimestamp = ts;
          }
        } catch (_) {}
      }).catchError((_) {});
    } catch (_) {}
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _chatPollTimer?.cancel();
    _statusPollTimer?.cancel();
    _chatController.dispose();
    _chatScroll.dispose();
    try { _agoraLeave(); } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return _buildError();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // ── Main video area ──────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                SizedBox.expand(child: HtmlElementView(viewType: _viewId)),

                // Loading overlay
                if (_loading)
                  Container(
                    color: const Color(0xFF0A1628),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 20),
                          Text('Connecting...',
                              style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),

                // Top bar: remote name + session timer
                if (_joined)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(widget.remoteUserName,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14)),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _sessionSeconds >= 900
                                ? Colors.orange.withOpacity(0.8)
                                : Colors.black45,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_rounded,
                                  color: Colors.white70, size: 14),
                              const SizedBox(width: 4),
                              Text(_sessionTimeStr,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Bottom controls
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      // Side action buttons row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _sideBtn(
                            icon: Icons.history_rounded,
                            label: 'Patient History',
                            active: _showHistory,
                            badgeCount: 0,
                            onTap: () {
                              setState(() {
                                _showHistory = !_showHistory;
                                if (_showHistory) _showChat = false;
                              });
                              // Always load history when panel opens (patientId optional)
                              if (_showHistory && !_historyLoaded && !_historyLoading) {
                                _loadPatientHistory();
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                          _sideBtn(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: 'Chat',
                            active: _showChat,
                            badgeCount: _unreadChatCount,
                            onTap: () => setState(() {
                              _showChat = !_showChat;
                              if (_showChat) {
                                _showHistory = false;
                                _unreadChatCount = 0; // Clear unread count when opening chat
                              }
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Main controls row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _controlBtn(
                            icon: _micMuted
                                ? Icons.mic_off_rounded
                                : Icons.mic_rounded,
                            color: _micMuted ? Colors.grey : Colors.white,
                            bg: Colors.white24,
                            onTap: _toggleMic,
                            tooltip: _micMuted ? 'Unmute' : 'Mute',
                          ),
                          const SizedBox(width: 16),
                          // Red button — leave video only
                          _controlBtn(
                            icon: Icons.call_end_rounded,
                            color: Colors.white,
                            bg: Colors.red,
                            onTap: _leaveVideo,
                            size: 64,
                            tooltip: 'Leave Video',
                          ),
                          const SizedBox(width: 16),
                          if (!widget.isAudioOnly)
                            _controlBtn(
                              icon: _camOff
                                  ? Icons.videocam_off_rounded
                                  : Icons.videocam_rounded,
                              color: _camOff ? Colors.grey : Colors.white,
                              bg: Colors.white24,
                              onTap: _toggleCam,
                              tooltip: _camOff ? 'Start Camera' : 'Stop Camera',
                            ),
                          const SizedBox(width: 16),
                          // End Consultation button
                          _controlBtn(
                            icon: Icons.stop_circle_rounded,
                            color: Colors.white,
                            bg: const Color(0xFF7C3AED),
                            onTap: _endConsultation,
                            tooltip: 'End Consultation',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Red = Leave Video  •  Purple = End Consultation',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Side panel ───────────────────────────────────────────────
          if (_showChat || _showHistory)
            Container(
              width: 320,
              color: const Color(0xFF0F172A),
              child: _showChat ? _buildChatPanel() : _buildHistoryPanel(),
            ),
        ],
      ),
    );
  }

  // ── Chat Panel ──────────────────────────────────────────────────────────
  Widget _buildChatPanel() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
          ),
          child: Row(
            children: [
              const Icon(Icons.chat_bubble_rounded,
                  color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              const Text('Chat',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white54, size: 20),
                onPressed: () => setState(() => _showChat = false),
              ),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: _chatMessages.isEmpty
              ? const Center(
                  child: Text('No messages yet',
                      style: TextStyle(color: Colors.white38)))
              : ListView.builder(
                  controller: _chatScroll,
                  padding: const EdgeInsets.all(12),
                  itemCount: _chatMessages.length,
                  itemBuilder: (ctx, i) {
                    final msg = _chatMessages[i];
                    final isMe = msg['sender'] == _mySenderName;
                    final displaySender = isMe ? 'You' : (msg['sender'] ?? '');
                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppColors.primaryColor
                              : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: Radius.circular(isMe ? 12 : 2),
                            bottomRight: Radius.circular(isMe ? 2 : 12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              displaySender,
                              style: TextStyle(
                                color: isMe
                                    ? Colors.white70
                                    : const Color(0xFF60A5FA),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              msg['text'] ?? '',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Input
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFF1E293B))),
          ),
          child: Row(
            children: [
              // File upload
              IconButton(
                icon: const Icon(Icons.attach_file_rounded,
                    color: Colors.white54),
                onPressed: _pickAndSendFile,
                tooltip: 'Attach file',
              ),
              Expanded(
                child: TextField(
                  controller: _chatController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  onSubmitted: (_) => _sendChatMessage(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendChatMessage,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Patient History Panel ───────────────────────────────────────────────
  Widget _buildHistoryPanel() {
    // currentUserName = patient (the one viewing this screen)
    // remoteUserName = doctor (the other side)
    final patientName = widget.currentUserName.isNotEmpty
        ? widget.currentUserName
        : 'Patient';
    final doctorName = widget.remoteUserName.isNotEmpty
        ? widget.remoteUserName
        : 'Doctor';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
          ),
          child: Row(
            children: [
              const Icon(Icons.history_rounded,
                  color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              const Text('Patient History',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white54, size: 20),
                onPressed: () => setState(() => _showHistory = false),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _historySection('Current Consultation',
                    Icons.video_call_rounded, const Color(0xFF3B82F6), [
                  'Patient: $patientName',
                  'Doctor: $doctorName',
                  'Session: $_sessionTimeStr',
                ]),
                const SizedBox(height: 16),
                if (_historyLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(
                          color: Color(0xFF10B981), strokeWidth: 2),
                    ),
                  )
                else ..._buildRealHistorySections(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRealHistorySections() {
    if (_historyRecords.isEmpty) {
      return [
        _historySection('Previous Visits', Icons.calendar_today_rounded,
            const Color(0xFF10B981), ['No previous consultations found']),
        const SizedBox(height: 16),
        _historySection('Prescriptions', Icons.medication_rounded,
            const Color(0xFFF59E0B), ['No prescriptions on file']),
        const SizedBox(height: 16),
        _historySection('Lab Reports', Icons.biotech_rounded,
            const Color(0xFF8B5CF6), ['No lab reports available']),
      ];
    }

    final visitItems = <String>[];
    final prescriptionItems = <String>[];
    final labItems = <String>[];
    int visitCount = 0;

    for (final rec in _historyRecords) {
      final rawDate = rec['date'] ?? rec['createdAt'];
      final dateStr = rawDate != null
          ? (DateTime.tryParse(rawDate.toString())?.toLocal().toString().substring(0, 10) ?? 'Unknown date')
          : 'Unknown date';
      final complaint = rec['chiefComplaint']?.toString() ?? '';
      final diagnosis = rec['diagnosis']?.toString() ?? '';
      final timeSlot = rec['timeSlot']?.toString() ?? '';
      final doctorName = (rec['doctor'] is Map)
          ? (rec['doctor']['name']?.toString() ?? 'Doctor')
          : (rec['doctor']?.toString() ?? 'Doctor');

      // Visit entry
      final hasVisitInfo = complaint.isNotEmpty || diagnosis.isNotEmpty || rec['type'] == 'appointment';
      if (hasVisitInfo) {
        visitCount++;
        if (visitItems.isNotEmpty) visitItems.add(''); // separator
        visitItems.add('📅 $dateStr${timeSlot.isNotEmpty ? '  $timeSlot' : ''}');
        visitItems.add('Dr. $doctorName');
        if (complaint.isNotEmpty) visitItems.add('Complaint: $complaint');
        if (diagnosis.isNotEmpty) visitItems.add('Diagnosis: $diagnosis');
      }

      // Prescriptions from medical records
      final prescriptions = rec['prescriptions'];
      if (prescriptions is List && prescriptions.isNotEmpty) {
        for (final p in prescriptions) {
          if (p is Map) {
            final med = p['medication']?.toString() ?? p['name']?.toString() ?? '';
            final dosage = p['dosage']?.toString() ?? '';
            final freq = p['frequency']?.toString() ?? '';
            if (med.isNotEmpty) {
              prescriptionItems.add(
                  '$med${dosage.isNotEmpty ? ' — $dosage' : ''}${freq.isNotEmpty ? ' ($freq)' : ''}');
            }
          } else if (p is String && p.isNotEmpty) {
            prescriptionItems.add(p);
          }
        }
      }

      // Lab reports from medical records
      final labReports = rec['labReports'] ?? rec['labResults'];
      if (labReports is List && labReports.isNotEmpty) {
        for (final l in labReports) {
          if (l is Map) {
            final test = l['test']?.toString() ?? l['name']?.toString() ?? '';
            final result = l['result']?.toString() ?? '';
            if (test.isNotEmpty) {
              labItems.add('$test${result.isNotEmpty ? ': $result' : ''}');
            }
          } else if (l is String && l.isNotEmpty) {
            labItems.add(l);
          }
        }
      }
    }

    while (visitItems.isNotEmpty && visitItems.last.isEmpty) visitItems.removeLast();

    final visitLabel = visitCount > 0 ? 'Previous Visits ($visitCount)' : 'Previous Visits';

    return [
      _historySection(
          visitLabel,
          Icons.calendar_today_rounded,
          const Color(0xFF10B981),
          visitItems.isEmpty ? ['No previous consultations recorded'] : visitItems),
      const SizedBox(height: 16),
      _historySection(
          'Prescriptions',
          Icons.medication_rounded,
          const Color(0xFFF59E0B),
          prescriptionItems.isEmpty ? ['No prescriptions on file'] : prescriptionItems),
      const SizedBox(height: 16),
      _historySection(
          'Lab Reports',
          Icons.biotech_rounded,
          const Color(0xFF8B5CF6),
          labItems.isEmpty ? ['No lab reports available'] : labItems),
    ];
  }

  Widget _historySection(
      String title, IconData icon, Color color, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(item,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12)),
              )),
        ],
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

  Widget _controlBtn({
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
    double size = 56,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: size * 0.45),
        ),
      ),
    );
  }

  Widget _sideBtn({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primaryColor.withOpacity(0.3)
                  : Colors.white12,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active ? AppColors.primaryColor : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    color: active ? Colors.white : Colors.white60, size: 16),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                        color: active ? Colors.white : Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          // Notification badge
          if (badgeCount > 0)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Center(
                  child: Text(
                    badgeCount > 9 ? '9+' : '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
