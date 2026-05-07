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

  void _startVideoCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => VideoCall(
          channelName: _consultationId ?? widget.appointment.id ?? 'consultation',
          remoteUserName: widget.isDoctor 
              ? widget.appointment.patient?.name ?? 'Patient'
              : 'Dr. ${widget.appointment.doctor?.name ?? 'Doctor'}',
          isAudioOnly: false,
          appointmentId: widget.appointment.id,
          consultationId: _consultationId,
          patientId: widget.appointment.patient?.id,
          currentUserName: widget.currentUserName,
          currentUserId: widget.currentUserId,
        ),
      ),
    );
  }

  void _startVoiceCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => VideoCall(
          channelName: _consultationId ?? widget.appointment.id ?? 'consultation',
          remoteUserName: widget.isDoctor 
              ? widget.appointment.patient?.name ?? 'Patient'
              : 'Dr. ${widget.appointment.doctor?.name ?? 'Doctor'}',
          isAudioOnly: true,
          appointmentId: widget.appointment.id,
          consultationId: _consultationId,
          patientId: widget.appointment.patient?.id,
          currentUserName: widget.currentUserName,
          currentUserId: widget.currentUserId,
        ),
      ),
    );
  }

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
          Navigator.pop(context);
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
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildTimerBar(),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: const CustomBackButton(),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isDoctor
                ? widget.appointment.patient?.name ?? 'Patient'
                : 'Dr. ${widget.appointment.doctor?.name ?? 'Doctor'}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          Text(
            'Consultation - ${_timer.formattedTime}',
            style: TextStyle(
              fontSize: 12,
              color: _timer.status == ConsultationTimerStatus.nearMaximum
                  ? Colors.orange
                  : const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        // Voice Call Button
        IconButton(
          icon: const Icon(Icons.phone_rounded, color: AppColors.primaryColor),
          onPressed: _startVoiceCall,
          tooltip: 'Voice Call',
        ),
        // Video Call Button
        IconButton(
          icon: const Icon(Icons.videocam_rounded, color: AppColors.primaryColor),
          onPressed: _startVideoCall,
          tooltip: 'Video Call',
        ),
        // History Form Button (Doctor only)
        if (widget.isDoctor)
          IconButton(
            icon: const Icon(Icons.history_edu_rounded, color: AppColors.primaryColor),
            onPressed: _openHistoryForm,
            tooltip: 'Patient History Form',
          ),
        // Prescription Button (Doctor only)
        if (widget.isDoctor)
          IconButton(
            icon: Icon(
              Icons.description_rounded,
              color: _prescriptionComplete ? Colors.green : AppColors.primaryColor,
            ),
            onPressed: _openPrescriptionForm,
            tooltip: 'Prescription',
          ),
        // End Consultation Button
        IconButton(
          icon: const Icon(Icons.call_end_rounded, color: Colors.red),
          onPressed: _endConsultation,
          tooltip: 'End Consultation',
        ),
      ],
    );
  }

  Widget _buildTimerBar() {
    Color barColor;
    switch (_timer.status) {
      case ConsultationTimerStatus.belowMinimum:
        barColor = Colors.orange;
        break;
      case ConsultationTimerStatus.nearMaximum:
        barColor = Colors.red;
        break;
      case ConsultationTimerStatus.reachedMaximum:
        barColor = Colors.red;
        break;
      default:
        barColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 16, color: barColor),
              const SizedBox(width: 8),
              Text(
                _timer.statusMessage,
                style: TextStyle(
                  fontSize: 12,
                  color: barColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_timer.status == ConsultationTimerStatus.nearMaximum ||
                  _timer.status == ConsultationTimerStatus.reachedMaximum)
                Text(
                  'Remaining: ${_timer.remainingTimeFormatted}',
                  style: TextStyle(
                    fontSize: 12,
                    color: barColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: _timer.progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ],
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
