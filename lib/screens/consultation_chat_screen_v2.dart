// Consultation Chat Screen V2 - Chat-First Approach
// Updated as per client requirements - May 4, 2026

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:icare/models/consultation_timer.dart';
import 'package:icare/models/consultation_message.dart';
import 'package:icare/models/appointment_detail.dart';
import 'package:icare/screens/video_call.dart';
import 'package:icare/screens/in_consultation_prescription_form.dart';
import 'package:icare/screens/patient_history_form_screen.dart';
import 'package:icare/services/consultation_service.dart';
import 'package:icare/services/call_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class ConsultationChatScreenV2 extends StatefulWidget {
  final AppointmentDetail appointment;
  final bool isDoctor;
  final String currentUserId;
  final String currentUserName;
  final String? consultationId; // Optional - if already created

  const ConsultationChatScreenV2({
    super.key,
    required this.appointment,
    required this.isDoctor,
    required this.currentUserId,
    required this.currentUserName,
    this.consultationId, // Optional parameter
  });

  @override
  State<ConsultationChatScreenV2> createState() => _ConsultationChatScreenV2State();
}

class _ConsultationChatScreenV2State extends State<ConsultationChatScreenV2> {
  final ConsultationService _consultationService = ConsultationService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late ConsultationTimer _timer;
  List<ConsultationMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _prescriptionComplete = false;
  String? _consultationId;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
    _initializeConsultation();
  }

  void _initializeTimer() {
    _timer = ConsultationTimer(
      onTick: (duration) {
        if (mounted) setState(() {});
      },
      onMinimumReached: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Minimum consultation duration reached. You can now end the consultation.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
      onWarningBeforeMax: () {
        if (mounted) {
          _showWarningDialog();
        }
      },
      onMaximumReached: () {
        if (mounted) {
          _showMaximumReachedDialog();
        }
      },
    );
    _timer.start();
  }

  Future<void> _initializeConsultation() async {
    try {
      // If consultationId already provided, use it
      if (widget.consultationId != null && widget.consultationId!.isNotEmpty) {
        _consultationId = widget.consultationId;
        
        // Send consent message if doctor
        if (widget.isDoctor) {
          await _sendConsentMessage();
        }
        
        // Load existing messages
        await _loadMessages();
        
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Otherwise create new consultation
      final result = await _consultationService.startConsultationV2(
        appointmentId: widget.appointment.id ?? '',
        patientId: widget.appointment.patient!.id,
        doctorId: widget.appointment.doctor!.id,
      );

      if (result['success']) {
        _consultationId = result['consultationId'];
        
        // Send consent message if doctor
        if (widget.isDoctor) {
          await _sendConsentMessage();
        }
        
        // Load messages
        await _loadMessages();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing consultation: $e')),
        );
      }
    }
  }

  Future<void> _sendConsentMessage() async {
    final consentMessage = 'Hi, I am Dr. ${widget.currentUserName}. I confirm that telehealth has limitations and some emergencies require in-person visits.';
    
    await _consultationService.sendMessageV2(
      consultationId: _consultationId!,
      senderId: widget.currentUserId,
      senderName: 'Dr. ${widget.currentUserName}',
      senderRole: 'doctor',
      message: consentMessage,
      isSystemMessage: true,
    );
  }

  Future<void> _loadMessages() async {
    if (_consultationId == null) return;

    try {
      final messages = await _consultationService.getMessagesV2(consultationId: _consultationId!);
      if (mounted) {
        setState(() {
          _messages = messages
              .map((m) => ConsultationMessage.fromJson(m as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      await _consultationService.sendMessageV2(
        consultationId: _consultationId!,
        senderId: widget.currentUserId,
        senderName: widget.currentUserName,
        senderRole: widget.isDoctor ? 'doctor' : 'patient',
        message: message,
      );
      await _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _pickAndSendFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        // Upload attachment
        final uploadResult = await _consultationService.uploadAttachment(
          result.files.single.path!,
        );

        if (uploadResult['success'] == true) {
          await _consultationService.sendMessageV2(
            consultationId: _consultationId!,
            senderId: widget.currentUserId,
            senderName: widget.currentUserName,
            senderRole: widget.isDoctor ? 'doctor' : 'patient',
            message: 'Sent an attachment: ${result.files.single.name}',
            attachmentUrl: uploadResult['url'],
          );
          await _loadMessages();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload file: $e')),
        );
      }
    }
  }

  Future<void> _initiateCall({required bool audioOnly}) async {
    // Determine the other party's ID to send them a ring signal
    final receiverId = widget.isDoctor
        ? widget.appointment.patient?.id ?? ''
        : widget.appointment.doctor?.id ?? '';

    if (receiverId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot determine call recipient')),
      );
      return;
    }

    final channelName = _consultationId ?? widget.appointment.id ?? 'consultation';
    final remoteUserName = widget.isDoctor
        ? widget.appointment.patient?.name ?? 'Patient'
        : 'Dr. ${widget.appointment.doctor?.name ?? 'Doctor'}';

    // Send ring signal to the other party via call signaling backend
    final callService = CallService();
    await callService.initiateCall(
      receiverId: receiverId,
      channelName: channelName,
      callerName: widget.currentUserName,
      callType: audioOnly ? 'audio' : 'video',
    );

    if (!mounted) return;

    // Open call screen for the caller immediately
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => VideoCall(
          channelName: channelName,
          remoteUserName: remoteUserName,
          isAudioOnly: audioOnly,
          appointmentId: widget.appointment.id,
          consultationId: _consultationId,
          patientId: widget.appointment.patient?.id,
          currentUserName: widget.currentUserName,
          currentUserId: widget.currentUserId,
        ),
      ),
    );
  }

  void _startVideoCall() => _initiateCall(audioOnly: false);
  void _startVoiceCall() => _initiateCall(audioOnly: true);

  void _openHistoryForm() {
    if (!widget.isDoctor) return;
    if (_consultationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consultation not initialized yet')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => PatientHistoryFormScreen(
          appointment: widget.appointment,
          consultationId: _consultationId!,
        ),
      ),
    );
  }

  void _openPrescriptionForm() {
    if (!widget.isDoctor) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only doctors can create prescriptions')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => InConsultationPrescriptionForm(
          appointment: widget.appointment,
          consultationId: _consultationId!,
          onPrescriptionComplete: (isComplete) {
            setState(() => _prescriptionComplete = isComplete);
          },
        ),
      ),
    );
  }

  Future<void> _endConsultation() async {
    // Validate minimum duration
    final validationError = _timer.validateEndConsultation();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check prescription completion (doctor only)
    if (widget.isDoctor && !_prescriptionComplete) {
      _showPrescriptionIncompleteDialog();
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Consultation'),
        content: const Text(
          'Are you sure you want to end this consultation? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('End Consultation'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await _consultationService.endConsultationV2(
          consultationId: _consultationId!,
          duration: _timer.elapsed.inSeconds,
        );
        if (result['success'] == true && mounted) {
          _timer.stop();
          await _clearConsultationState();
          if (mounted) Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to end consultation: $e')),
          );
        }
      }
    }
  }

  Future<void> _clearConsultationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('doctor_in_consultation', false);
    } catch (_) {}
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Consultation Ending Soon'),
          ],
        ),
        content: Text(
          'The consultation will automatically end in ${_timer.remainingTimeFormatted}. Please wrap up.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showMaximumReachedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Maximum Duration Reached'),
        content: const Text(
          'The maximum consultation duration of 30 minutes has been reached. The consultation will now end.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _endConsultation();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrescriptionIncompleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Prescription Incomplete'),
          ],
        ),
        content: const Text(
          'You must complete the prescription before ending the consultation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _openPrescriptionForm();
            },
            child: const Text('Complete Prescription'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildConsultationHeader(),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (ctx, i) => _buildMessageBubble(_messages[i]),
                  ),
                ),
                _buildMessageInput(),
              ],
            ),
    );
  }

  // ── Screenshot-matched consultation header ──────────────────────────────
  Widget _buildConsultationHeader() {
    final patientName = widget.appointment.patient?.name ?? 'Patient';
    final doctorName = widget.appointment.doctor?.name ?? 'Doctor';
    final mins = (_timer.elapsed.inSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_timer.elapsed.inSeconds % 60).toString().padLeft(2, '0');

    final timerColor = (_timer.status == ConsultationTimerStatus.nearMaximum ||
            _timer.status == ConsultationTimerStatus.reachedMaximum)
        ? Colors.red
        : (_timer.status == ConsultationTimerStatus.belowMinimum
            ? Colors.orange
            : AppColors.primaryColor);

    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Names row ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                children: [
                  const CustomBackButton(),
                  Expanded(
                    child: Column(
                      children: [
                        _participantRow(Icons.person_outline, patientName),
                        const SizedBox(height: 4),
                        _participantRow(Icons.medical_services_outlined, 'Dr. $doctorName'),
                      ],
                    ),
                  ),
                  // Doctor action buttons (prescription + history)
                  if (widget.isDoctor) ...[
                    IconButton(
                      icon: const Icon(Icons.history_edu_rounded, size: 22),
                      color: AppColors.primaryColor,
                      onPressed: _openHistoryForm,
                      tooltip: 'History Form',
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.description_rounded,
                        size: 22,
                        color: _prescriptionComplete ? Colors.green : AppColors.primaryColor,
                      ),
                      onPressed: _openPrescriptionForm,
                      tooltip: 'Prescription',
                    ),
                  ],
                ],
              ),
            ),
            // ── Timer + call buttons row ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // ── Timer digits (Mins | Secs) ──
                  _timerDigits(mins, secs, timerColor),
                  const SizedBox(width: 16),
                  // ── Voice call circular button ──
                  _callButton(
                    icon: Icons.phone_rounded,
                    onTap: _startVoiceCall,
                    tooltip: 'Voice Call',
                  ),
                  const SizedBox(width: 10),
                  // ── Video call circular button ──
                  _callButton(
                    icon: Icons.videocam_rounded,
                    onTap: _startVideoCall,
                    tooltip: 'Video Call',
                  ),
                  const Spacer(),
                  // ── End Session button ──
                  ElevatedButton(
                    onPressed: _endConsultation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'End Session',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            // ── Progress bar ──
            LinearProgressIndicator(
              value: _timer.progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(timerColor),
              minHeight: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _participantRow(IconData icon, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryColor, width: 1.5),
            color: AppColors.primaryColor.withOpacity(0.08),
          ),
          child: Icon(icon, size: 18, color: AppColors.primaryColor),
        ),
        const SizedBox(width: 8),
        Text(
          name.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Color(0xFF0F172A),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _timerDigits(String mins, String secs, Color color) {
    return Row(
      children: [
        _digitBox(mins, 'Mins', color),
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(' : ', style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w900, color: color,
          )),
        ),
        _digitBox(secs, 'Secs', color),
      ],
    );
  }

  Widget _digitBox(String value, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Text(
                value[0],
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color),
              ),
              const SizedBox(width: 2),
              Text(
                value[1],
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color),
              ),
            ],
          ),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _callButton({required IconData icon, required VoidCallback onTap, String? tooltip}) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryColor,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }


  Widget _buildMessageBubble(ConsultationMessage message) {
    final isMe = message.senderId == widget.currentUserId;

    if (message.isSystemMessage) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message.message,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1E40AF),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.attachmentUrl != null) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.attach_file_rounded,
                    size: 16,
                    color: isMe ? Colors.white : AppColors.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Attachment',
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message.message,
              style: TextStyle(
                color: isMe ? Colors.white : const Color(0xFF0F172A),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                color: isMe ? Colors.white70 : const Color(0xFF94A3B8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file_rounded, color: Color(0xFF64748B)),
            onPressed: _pickAndSendFile,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
              enabled: !_isSending,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: _isSending ? Colors.grey : AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: _isSending ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _timer.stop();
    _messageController.dispose();
    _scrollController.dispose();
    
    // Clear doctor_in_consultation flag when leaving consultation
    if (widget.isDoctor) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('doctor_in_consultation', false);
        debugPrint('✅ Cleared doctor_in_consultation flag on dispose');
      });
    }
    
    super.dispose();
  }
}
