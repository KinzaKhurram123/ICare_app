import 'dart:async';
import 'package:flutter/material.dart';
import 'package:icare/screens/video_call.dart';
import 'package:icare/services/connect_now_service.dart';
import 'package:icare/utils/theme.dart';

class DoctorConnectNowScreen extends StatefulWidget {
  final String requestId;
  final String patientName;
  final String channelName;
  final DateTime expiresAt;

  const DoctorConnectNowScreen({
    super.key,
    required this.requestId,
    required this.patientName,
    required this.channelName,
    required this.expiresAt,
  });

  @override
  State<DoctorConnectNowScreen> createState() => _DoctorConnectNowScreenState();
}

class _DoctorConnectNowScreenState extends State<DoctorConnectNowScreen>
    with SingleTickerProviderStateMixin {
  final ConnectNowService _service = ConnectNowService();

  int _secondsLeft = 0;
  Timer? _countdownTimer;
  bool _isLoading = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.expiresAt.difference(DateTime.now()).inSeconds.clamp(0, 180);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startCountdown();
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

  void _onExpired() {
    _pulseController.stop();
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.timer_off, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Request Expired'),
          ],
        ),
        content: const Text('The patient\'s request has expired.'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptRequest() async {
    setState(() => _isLoading = true);
    _countdownTimer?.cancel();
    try {
      final result = await _service.acceptRequest(widget.requestId);
      if (!mounted) return;
      if (result['success'] == true) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => VideoCall(
              channelName: widget.channelName,
              remoteUserName: widget.patientName,
            ),
          ),
        );
      } else {
        _showError(result['message'] ?? 'Could not accept request');
      }
    } catch (e) {
      _showError('Failed to accept. Request may have expired.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _rejectRequest() async {
    _countdownTimer?.cancel();
    try {
      await _service.rejectRequest(widget.requestId);
    } catch (_) {}
    if (mounted) Navigator.of(context).pop();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
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
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = _secondsLeft <= 30;

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
                  const Spacer(),
                  const Text(
                    'Incoming Request',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            const Spacer(),

            // Urgent badge
            if (isUrgent)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                ),
                child: const Text(
                  'EXPIRING SOON',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
              ),

            // Pulse animation with patient icon
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
                  color: (isUrgent ? Colors.red : Colors.green).withOpacity(0.2),
                  border: Border.all(
                    color: (isUrgent ? Colors.red : Colors.green).withOpacity(0.5),
                    width: 3,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_rounded,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Patient name
            Text(
              widget.patientName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Requesting an instant consultation',
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),

            const SizedBox(height: 32),

            // Countdown
            Text(
              _timeFormatted,
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w900,
                color: isUrgent ? Colors.red : Colors.white,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Time remaining to respond',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),

            const Spacer(),

            // Accept / Reject buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      children: [
                        // Reject
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _rejectRequest,
                            icon: const Icon(Icons.close, color: Colors.white70),
                            label: const Text(
                              'Decline',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white30),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Accept
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _acceptRequest,
                            icon: const Icon(Icons.video_call, color: Colors.white),
                            label: const Text(
                              'Accept',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
