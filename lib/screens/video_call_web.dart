// Web video call — Agora Web SDK via dart:js_interop
import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    // Only poll status on PATIENT side — doctor ends consultation themselves
    // Check role from SharedPref to determine if this is doctor or patient
    _maybeStartStatusPolling();
    // Register beforeunload handler so closing the browser marks appointment completed
    _registerBeforeUnload();
  }

  void _registerBeforeUnload() {
    if (widget.appointmentId == null || widget.appointmentId!.isEmpty) return;
    // When the browser tab/window is closed, mark appointment as completed
    // so it doesn't stay stuck as "in_progress"
    html.window.onBeforeUnload.listen((_) {
      if (widget.appointmentId != null && widget.appointmentId!.isNotEmpty) {
        // Fire-and-forget: mark as completed so rejoin button disappears
        try {
          ApiService().put('/appointments/update_status', {
            'appointmentId': widget.appointmentId!,
            'status': 'completed',
          });
        } catch (_) {}
      }
    });
  }

  Future<void> _maybeStartStatusPolling() async {
    if (widget.appointmentId == null || widget.appointmentId!.isEmpty) return;
    try {
      final user = await SharedPref().getUserData();
      final role = user?.role?.toLowerCase() ?? '';
      // Only patients need to poll — doctors end the call themselves
      if (role != 'doctor') {
        _startStatusPolling();
      }
    } catch (_) {
      // If we can't determine role, default to patient behavior (safe)
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
        // Use direct appointment endpoint
        final response = await api.get(
          '/appointments/${widget.appointmentId}',
        );
        final appt = response.data['appointment'];
        final status = appt?['status']?.toString() ?? '';
        if ((status == 'completed' || status == 'ended') && mounted) {
          _statusPollTimer?.cancel();
          try { await _agoraLeave().toDart; } catch (_) {}
          if (mounted) _showConsultationEndedDialog();
        }
      } catch (_) {
        // Fallback: list all appointments and find matching one
        try {
          final api = ApiService();
          final response = await api.get('/appointments/getAppointments');
          final appts = response.data['appointments'] as List? ?? [];
          final match = appts.firstWhere(
            (a) => (a['_id'] ?? a['id'])?.toString() == widget.appointmentId,
            orElse: () => null,
          );
          if (match != null &&
              (match['status'] == 'completed' || match['status'] == 'ended') &&
              mounted) {
            _statusPollTimer?.cancel();
            try { await _agoraLeave().toDart; } catch (_) {}
            if (mounted) _showConsultationEndedDialog();
          }
        } catch (_) {
          // Non-critical — silently ignore
        }
      }
    });
  }

  void _showConsultationEndedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Consultation Ended', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content: const Text('The doctor has ended the consultation.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Use browser navigation — guaranteed on Flutter Web
              html.window.location.href = '/dashboard';
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    );
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
      // Patient can also end consultation — show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('End Consultation?',
              style: TextStyle(fontWeight: FontWeight.w800)),
          content: const Text(
              'Are you sure you want to end this consultation? The doctor will be notified.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('End Consultation'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
      // Mark appointment as completed so doctor side also closes
      try {
        await AppointmentService().updateAppointmentStatus(
          appointmentId: widget.appointmentId!,
          status: 'completed',
        );
      } catch (_) {}
      try { await _agoraLeave().toDart; } catch (_) {}
      if (mounted) html.window.location.href = '/dashboard';
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
      final bytes = file.bytes;
      final name = file.name.toLowerCase();

      // Check if it's an image
      final isImage = name.endsWith('.png') || name.endsWith('.jpg') ||
          name.endsWith('.jpeg') || name.endsWith('.gif') ||
          name.endsWith('.webp') || name.endsWith('.bmp');

      String msgText;
      if (isImage && bytes != null) {
        // Convert to base64 data URL so it renders as image in chat
        final ext = name.split('.').last;
        final mime = ext == 'jpg' || ext == 'jpeg' ? 'image/jpeg'
            : ext == 'png' ? 'image/png'
            : ext == 'gif' ? 'image/gif'
            : 'image/webp';
        final b64 = base64Encode(bytes);
        msgText = 'img:data:$mime;base64,$b64';
      } else {
        msgText = '📎 ${file.name}';
      }

      if (mounted) setState(() => _chatMessages.add({'sender': _mySenderName, 'text': msgText}));
      ApiService().post('/call-chat/send', {
        'channelName': widget.channelName,
        'sender': _mySenderName,
        'text': msgText,
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
  Widget _buildMessageContent(String text, bool isMe) {
    // Image message — render as inline image
    if (text.startsWith('img:')) {
      final dataUrl = text.substring(4); // remove 'img:' prefix
      try {
        // Extract base64 part from data URL
        final base64Part = dataUrl.split(',').last;
        final bytes = base64Decode(base64Part);
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            bytes,
            width: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Text(
              '🖼️ Image',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        );
      } catch (_) {
        return const Text('🖼️ Image', style: TextStyle(color: Colors.white, fontSize: 13));
      }
    }
    // Regular text message
    return Text(text, style: const TextStyle(color: Colors.white, fontSize: 13));
  }

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
                            _buildMessageContent(msg['text'] ?? '', isMe),
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

    // Separate medical records (have prescription/diagnosis) from plain appointment records
    final medicalRecords = _historyRecords
        .where((r) => r['type'] != 'appointment')
        .toList();
    final appointmentRecords = _historyRecords
        .where((r) => r['type'] == 'appointment')
        .toList();

    // Build clickable visit cards from medical records
    final visitWidgets = <Widget>[];
    for (final rec in medicalRecords) {
      visitWidgets.add(_buildVisitCard(rec));
      visitWidgets.add(const SizedBox(height: 8));
    }

    // Add plain appointment records (no medical record yet)
    for (final rec in appointmentRecords) {
      final rawDate = rec['date'] ?? rec['createdAt'];
      final dateStr = rawDate != null
          ? _formatDate(rawDate.toString())
          : 'Unknown date';
      final complaint = rec['chiefComplaint']?.toString() ?? '';
      final doctorName = (rec['doctor'] is Map)
          ? (rec['doctor']['name']?.toString() ?? 'Doctor')
          : 'Doctor';
      visitWidgets.add(_buildSimpleVisitTile(dateStr, doctorName, complaint));
      visitWidgets.add(const SizedBox(height: 8));
    }

    final totalVisits = medicalRecords.length + appointmentRecords.length;
    final visitLabel = totalVisits > 0
        ? 'Previous Visits ($totalVisits)'
        : 'Previous Visits';

    return [
      // Section header
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                color: Color(0xFF10B981), size: 14),
            const SizedBox(width: 6),
            Text(visitLabel,
                style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ],
        ),
      ),
      if (visitWidgets.isEmpty)
        _historySection('Previous Visits', Icons.calendar_today_rounded,
            const Color(0xFF10B981), ['No previous consultations recorded'])
      else
        ...visitWidgets,
    ];
  }

  String _formatDate(String raw) {
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return raw;
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}  '
        '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }

  // ── Clickable card for a full medical record ────────────────────────────
  Widget _buildVisitCard(Map<String, dynamic> rec) {
    final rawDate = rec['date'] ?? rec['createdAt'];
    final dateStr = rawDate != null ? _formatDate(rawDate.toString()) : 'Unknown date';
    final diagnosis = rec['diagnosis']?.toString() ?? '';
    final notes = rec['notes']?.toString() ?? '';
    final doctorName = (rec['doctor'] is Map)
        ? (rec['doctor']['name']?.toString() ?? 'Doctor')
        : (rec['doctor']?.toString() ?? 'Doctor');

    // Medicines
    final prescription = rec['prescription'];
    final medicines = prescription is Map
        ? ((prescription['medicines'] as List?) ?? [])
        : <dynamic>[];

    // Lab tests — can be in prescription.labTests or top-level labTests
    final labTestsInPrescription = prescription is Map
        ? ((prescription['labTests'] as List?) ?? [])
        : <dynamic>[];
    final labTestsTopLevel = (rec['labTests'] as List?) ?? [];
    final labTests = labTestsInPrescription.isNotEmpty
        ? labTestsInPrescription
        : labTestsTopLevel;

    // Assigned courses
    final courses = (rec['assignedCourses'] as List?) ?? [];

    return GestureDetector(
      onTap: () => _showVisitDetail(rec, dateStr, diagnosis, notes,
          doctorName, medicines, labTests, courses),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date + tap hint
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    color: Color(0xFF10B981), size: 13),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(dateStr,
                      style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
                const Icon(Icons.open_in_new_rounded,
                    color: Color(0xFF64748B), size: 13),
              ],
            ),
            const SizedBox(height: 6),
            // Doctor
            Text('Dr. $doctorName',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12)),
            // Diagnosis
            if (diagnosis.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                diagnosis.length > 60
                    ? '${diagnosis.substring(0, 60)}…'
                    : diagnosis,
                style: const TextStyle(
                    color: Colors.white54, fontSize: 11),
              ),
            ],
            const SizedBox(height: 8),
            // Summary chips
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (medicines.isNotEmpty)
                  _historyChip(
                      '💊 ${medicines.length} med${medicines.length > 1 ? 's' : ''}',
                      const Color(0xFF3B82F6)),
                if (labTests.isNotEmpty)
                  _historyChip(
                      '🧪 ${labTests.length} test${labTests.length > 1 ? 's' : ''}',
                      const Color(0xFF8B5CF6)),
                if (courses.isNotEmpty)
                  _historyChip(
                      '📚 ${courses.length} course${courses.length > 1 ? 's' : ''}',
                      const Color(0xFF10B981)),
                if (notes.isNotEmpty)
                  _historyChip('📝 Notes', const Color(0xFFF59E0B)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  // ── Simple tile for appointment-only records (no medical record yet) ────
  Widget _buildSimpleVisitTile(
      String dateStr, String doctorName, String complaint) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  color: Color(0xFF64748B), size: 13),
              const SizedBox(width: 6),
              Text(dateStr,
                  style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Dr. $doctorName',
              style: const TextStyle(color: Colors.white60, fontSize: 12)),
          if (complaint.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              complaint.length > 60
                  ? '${complaint.substring(0, 60)}…'
                  : complaint,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  // ── Full visit detail dialog ────────────────────────────────────────────
  void _showVisitDetail(
    Map<String, dynamic> rec,
    String dateStr,
    String diagnosis,
    String notes,
    String doctorName,
    List<dynamic> medicines,
    List<dynamic> labTests,
    List<dynamic> courses,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E3A5F), Color(0xFF0F172A)],
                  ),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history_rounded,
                        color: Color(0xFF10B981), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Visit Details',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16)),
                          Text(dateStr,
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white54, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Doctor
                      _detailRow(Icons.person_rounded,
                          const Color(0xFF3B82F6), 'Doctor', 'Dr. $doctorName'),
                      const SizedBox(height: 12),

                      // Diagnosis
                      if (diagnosis.isNotEmpty) ...[
                        _detailSection(
                          Icons.local_hospital_rounded,
                          const Color(0xFFEF4444),
                          'Diagnosis',
                          diagnosis,
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Clinical Notes
                      if (notes.isNotEmpty) ...[
                        _detailSection(
                          Icons.notes_rounded,
                          const Color(0xFF8B5CF6),
                          'Clinical Notes',
                          notes,
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Medicines
                      if (medicines.isNotEmpty) ...[
                        _detailLabel(Icons.medication_rounded,
                            const Color(0xFF3B82F6), 'Prescribed Medicines'),
                        const SizedBox(height: 6),
                        ...medicines.map((m) {
                          final name = m is Map
                              ? (m['name'] ?? 'Medicine').toString()
                              : m.toString();
                          final dosage = m is Map
                              ? (m['dosage'] ?? '').toString()
                              : '';
                          final freq = m is Map
                              ? (m['frequency'] ?? '').toString()
                              : '';
                          final duration = m is Map
                              ? (m['duration'] ?? '').toString()
                              : '';
                          final instructions = m is Map
                              ? (m['instructions'] ?? '').toString()
                              : '';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFF3B82F6)
                                      .withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.medication_rounded,
                                        color: Color(0xFF3B82F6), size: 14),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(name,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13)),
                                    ),
                                  ],
                                ),
                                if (dosage.isNotEmpty ||
                                    freq.isNotEmpty ||
                                    duration.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      if (dosage.isNotEmpty)
                                        _miniChip(dosage,
                                            const Color(0xFF3B82F6)),
                                      if (freq.isNotEmpty)
                                        _miniChip(freq,
                                            const Color(0xFF10B981)),
                                      if (duration.isNotEmpty)
                                        _miniChip(duration,
                                            const Color(0xFFF59E0B)),
                                    ],
                                  ),
                                ],
                                if (instructions.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text('📝 $instructions',
                                      style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 11)),
                                ],
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                      ],

                      // Lab Tests
                      if (labTests.isNotEmpty) ...[
                        _detailLabel(Icons.biotech_rounded,
                            const Color(0xFF8B5CF6), 'Lab Tests Ordered'),
                        const SizedBox(height: 6),
                        ...labTests.map((t) {
                          final name = t is Map
                              ? (t['name'] ?? t['testName'] ?? 'Lab Test')
                                  .toString()
                              : t.toString();
                          final urgency = t is Map
                              ? (t['urgency'] ?? 'Routine').toString()
                              : 'Routine';
                          final urgencyColor =
                              urgency.toLowerCase() == 'stat'
                                  ? const Color(0xFFEF4444)
                                  : urgency.toLowerCase() == 'urgent'
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFF8B5CF6);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFF8B5CF6)
                                      .withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.biotech_rounded,
                                    color: Color(0xFF8B5CF6), size: 14),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(name,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                ),
                                _miniChip(urgency, urgencyColor),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                      ],

                      // Assigned Courses
                      if (courses.isNotEmpty) ...[
                        _detailLabel(Icons.school_rounded,
                            const Color(0xFF10B981), 'Assigned Courses'),
                        const SizedBox(height: 6),
                        ...courses.map((c) {
                          final name = c is Map
                              ? (c['title'] ?? c['name'] ?? 'Course')
                                  .toString()
                              : c.toString();
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.play_circle_rounded,
                                    color: Color(0xFF10B981), size: 14),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(name,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],

                      // Empty state
                      if (diagnosis.isEmpty &&
                          notes.isEmpty &&
                          medicines.isEmpty &&
                          labTests.isEmpty &&
                          courses.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('No details recorded for this visit',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 13)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(
      IconData icon, Color color, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Text('$label: ',
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _detailSection(
      IconData icon, Color color, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _detailLabel(icon, color, title),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(content,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 12, height: 1.5)),
        ),
      ],
    );
  }

  Widget _detailLabel(IconData icon, Color color, String title) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Text(title,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13)),
      ],
    );
  }

  Widget _miniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
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
