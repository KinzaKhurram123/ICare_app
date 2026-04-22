import 'package:flutter/material.dart';
import 'package:icare/services/instructor_service.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text_input.dart';
import 'package:icare/utils/theme.dart';

class InstructorCreatePrecautionScreen extends StatefulWidget {
  final Map<String, dynamic>? precaution;

  const InstructorCreatePrecautionScreen({super.key, this.precaution});

  @override
  State<InstructorCreatePrecautionScreen> createState() =>
      _InstructorCreatePrecautionScreenState();
}

class _InstructorCreatePrecautionScreenState
    extends State<InstructorCreatePrecautionScreen> {
  final InstructorService _instructorService = InstructorService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  bool _isLoading = false;
  bool get _isEditing => widget.precaution != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.precaution!['title'] ?? '';
      _bodyController.text = widget.precaution!['body'] ?? '';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'title': _titleController.text,
        'body': _bodyController.text,
        'attachments': [],
      };

      if (_isEditing) {
        await _instructorService.updatePrecaution(
          widget.precaution!['_id'],
          data,
        );
      } else {
        await _instructorService.createPrecaution(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF10B981),
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Health tip ${_isEditing ? 'updated' : 'created'} successfully!',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFFEF4444),
            content: Text('Something went wrong. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Decorative background circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3B82F6).withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withOpacity(0.05),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(
                            'What\'s on your mind?',
                            'Share a medical precaution or a healthy lifestyle tip.',
                          ),
                          const SizedBox(height: 32),
                          
                          _buildLabel('Tip Title'),
                          CustomInputField(
                            controller: _titleController,
                            hintText: 'e.g., Morning Hydration Routine',
                            borderRadius: 16,
                            borderColor: const Color(0xFFE2E8F0),
                            leadingIcon: const Icon(Icons.title, color: Color(0xFF3B82F6), size: 20),
                            validator: (val) => val?.isEmpty ?? true ? 'Please enter a title' : null,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          _buildLabel('Detailed Content'),
                          CustomInputField(
                            controller: _bodyController,
                            hintText: 'Write your advice here...\n\nBe specific and clear so your students can follow easily.',
                            maxLines: 8,
                            height: 200,
                            borderRadius: 16,
                            borderColor: const Color(0xFFE2E8F0),
                            leadingIcon: const Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Icon(Icons.description_outlined, color: Color(0xFF8B5CF6), size: 20),
                            ),
                            validator: (val) => val?.isEmpty ?? true ? 'Please enter some content' : null,
                          ),
                          
                          const SizedBox(height: 48),
                          
                          Center(
                            child: CustomButton(
                              width: double.infinity,
                              borderRadius: 16,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              label: _isLoading
                                  ? 'Saving...'
                                  : (_isEditing ? 'Update Health Tip' : 'Publish Health Tip'),
                              onPressed: _isLoading ? null : _save,
                              trailingIcon: _isLoading 
                                ? null 
                                : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          const CustomBackButton(),
          const SizedBox(width: 8),
          Text(
            _isEditing ? 'Edit Health Tip' : 'New Health Tip',
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF475569),
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
}
