import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/connect_now_service.dart';
import '../utils/shared_pref.dart';
import '../screens/doctor_connect_now_screen.dart';

/// Wraps the doctor's app and polls for Connect Now requests every 5 seconds.
class DoctorConnectNowListener extends StatefulWidget {
  final Widget child;

  const DoctorConnectNowListener({super.key, required this.child});

  @override
  State<DoctorConnectNowListener> createState() => _DoctorConnectNowListenerState();
}

class _DoctorConnectNowListenerState extends State<DoctorConnectNowListener> {
  final ConnectNowService _service = ConnectNowService();
  final SharedPref _sharedPref = SharedPref();
  Timer? _timer;
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _checkPending());
  }

  Future<void> _checkPending() async {
    if (_dialogShowing || !mounted) return;

    // Only poll if user is a doctor
    final userRole = await _sharedPref.getUserRole();
    if (userRole != 'doctor' && userRole != 'Doctor') return;

    final token = await _sharedPref.getToken();
    if (token == null || token.isEmpty) return;

    debugPrint('🩺 Checking for Connect Now requests...');

    try {
      final result = await _service.checkPending();
      if (result['hasPending'] == true && mounted) {
        final request = result['request'];
        debugPrint('🚨 Pending request found: ${request['patientName']}');
        _dialogShowing = true;
        await _showRequestScreen(request);
        _dialogShowing = false;
      }
    } catch (e) {
      debugPrint('❌ Error checking pending requests: $e');
    }
  }

  Future<void> _showRequestScreen(Map<String, dynamic> request) async {
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DoctorConnectNowScreen(
          requestId: request['id']?.toString() ?? '',
          patientName: request['patientName']?.toString() ?? 'Patient',
          channelName: request['channelName']?.toString() ?? '',
          expiresAt: DateTime.now().add(
            Duration(seconds: 180 - ((request['waitingTime'] as num?)?.toInt() ?? 0)),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
