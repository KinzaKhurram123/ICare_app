import 'dart:async';
import 'package:flutter/material.dart';
import 'package:icare/screens/video_call.dart';
import 'package:icare/services/connect_now_service.dart';
import 'package:icare/utils/shared_pref.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/app_keys.dart';

class ConnectNowWaitingScreen extends StatefulWidget {
  const ConnectNowWaitingScreen({super.key});

  @override
  State<ConnectNowWaitingScreen> createState() => _ConnectNowWaitingScreenState();
}

class _ConnectNowWaitingScreenState extends State<ConnectNowWaitingScreen>
    with SingleTickerProviderStateMixin {
  final ConnectNowService _service = ConnectNowService();

  String? _requestId;
  String? _channelName;
  int _secondsLeft = 180; // 3 minutes
  Timer? _countdownTimer;
  Timer? _pollTimer;
  bool _isSearching = true;
  bool _isLoading = true;
  String _statusMessage = 'Connecting to available doctors...';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initiateRequest();
  }

  Future<void> _initiateRequest() async {
    try {
      final result = await _service.initiateConnect();
      if (result['success'] == true) {
        setState(() {
          _requestId = result['requestId'];
          _channelName = result['channelName'];
          _isLoading = false;
          _statusMessage =
              'Notified ${result['notifiedDoctors']} doctors.\nWaiting for response...';
        });
        _startCountdown();
        _startPolling();
      } else {
        _showError(result['message'] ?? 'No doctors available');
      }
    } catch (e) {
      _showError('Could not connect. Please try again.');
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          timer.cancel();
          _onExpired();
        }
      });
    });
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_requestId == null || !mounted) return;
      try {
        final status = await _service.getStatus(_requestId!);
        if (!mounted) return;

        if (status['status'] == 'accepted') {
          timer.cancel();
          _countdownTimer?.cancel();
          final acceptedBy = status['acceptedBy'] as Map? ?? {};
          final doctorName = (acceptedBy['doctorName'] ?? acceptedBy['name'] ?? 'Doctor').toString();
          _onDoctorAccepted(
            status['channelName']?.toString() ?? _channelName ?? '',
            doctorName,
          );
        } else if (status['status'] == 'expired') {
          timer.cancel();
          _countdownTimer?.cancel();
          _onExpired();
        }
      } catch (_) {}
    });
  }

  void _onDoctorAccepted(String channelName, String doctorName) async {
    if (!mounted) return;
    _countdownTimer?.cancel();
    _pollTimer?.cancel();
    // Get current user (patient) name
    final userData = await SharedPref().getUserData();
    final patientName = userData?.name ?? 'Patient';
    // Auto-navigate directly — no button click required
    appNavigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (_) => VideoCall(
          channelName: channelName,
          remoteUserName: doctorName.isNotEmpty ? doctorName : 'Doctor',
          currentUserName: patientName,
        ),
      ),
    );
  }

  void _onExpired() {
    if (!mounted) return;
    setState(() {
      _isSearching = false;
      _statusMessage = 'No doctor responded.\nOur team has been notified.';
    });
    _pulseController.stop();
  }

  void _showError(String msg) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isSearching = false;
      _statusMessage = msg;
    });
    _pulseController.stop();
  }

  void _cancelRequest() {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();
    Navigator.of(context).pop();
  }

  String get _timeFormatted {
    final mins = _secondsLeft ~/ 60;
    final secs = _secondsLeft % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _cancelRequest,
                    child: const Icon(Icons.close, color: Colors.white, size: 28),
                  ),
                  const Spacer(),
                  const Text(
                    'Instant Consultation',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 28),
                ],
              ),
            ),

            const Spacer(),

            // Pulse animation
            if (_isLoading)
              const CircularProgressIndicator(color: Colors.white)
            else if (_isSearching)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: child,
                  );
                },
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor.withOpacity(0.2),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.5),
                      width: 3,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.medical_services_rounded,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else
              Icon(
                _secondsLeft == 0
                    ? Icons.notifications_off_outlined
                    : Icons.check_circle_outline,
                size: 100,
                color: _secondsLeft == 0 ? Colors.orange : Colors.green,
              ),

            const SizedBox(height: 40),

            // Timer
            if (_isSearching && !_isLoading)
              Column(
                children: [
                  Text(
                    _timeFormatted,
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: _secondsLeft <= 30 ? Colors.red : Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Finding a doctor for you',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ),

            const Spacer(),

            // Searching dots
            if (_isSearching && !_isLoading) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return AnimatedBuilder(
                    animation: _pulseController,
                    builder: (ctx, _) {
                      final delay = i * 0.3;
                      final value = (_pulseController.value + delay) % 1.0;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.3 + value * 0.7),
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 40),
            ],

            // Cancel button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: _isSearching
                  ? OutlinedButton(
                      onPressed: _cancelRequest,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size(double.infinity, 0),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size(double.infinity, 0),
                      ),
                      child: const Text(
                        'Go Back',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
