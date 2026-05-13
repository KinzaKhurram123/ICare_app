import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:icare/services/lms_service.dart';
import 'package:icare/services/api_service.dart';
import 'package:icare/utils/theme.dart';

/// Course Creation Wizard - Google Classroom/Moodle style
class InstructorLmsCreateCourseScreen extends StatefulWidget {
  const InstructorLmsCreateCourseScreen({super.key});

  @override
  State<InstructorLmsCreateCourseScreen> createState() => _InstructorLmsCreateCourseScreenState();
}

class _InstructorLmsCreateCourseScreenState extends State<InstructorLmsCreateCourseScreen> {
  final LmsService _lmsService = LmsService();
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  
  int _currentStep = 0;
  bool _isSubmitting = false;
  
  // Course data
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _thumbnailController = TextEditingController();
  String _category = 'HealthProgram';
  String _targetAudience = 'Patient';
  String _difficulty = 'Beginner';
  int _duration = 4;
  bool _isPublished = false;
  bool _uploadingThumbnail = false;
  String? _thumbnailUrl;

  // Modules
  final List<Map<String, dynamic>> _modules = [];

  Future<void> _pickAndUploadThumbnail() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.bytes == null) return;

      setState(() => _uploadingThumbnail = true);
      // Get signed upload params from backend then upload directly to Cloudinary
      final signRes = await ApiService().get('/upload/sign?folder=icare/thumbnails');
      final signature = signRes.data['signature']?.toString() ?? '';
      final timestamp = signRes.data['timestamp']?.toString() ?? '';
      final apiKey = signRes.data['api_key']?.toString() ?? '';
      final cloudName = signRes.data['cloud_name']?.toString() ?? 'dzlcnyxgb';
      final folder = signRes.data['folder']?.toString() ?? 'icare/thumbnails';
      if (signature.isEmpty) throw Exception('Could not get upload signature');

      final dio = Dio();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(file.bytes!, filename: file.name),
        'signature': signature,
        'timestamp': timestamp,
        'api_key': apiKey,
        'folder': folder,
      });
      final response = await dio.post(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
        data: formData,
        options: Options(validateStatus: (s) => s != null && s < 600),
      );
      if (response.statusCode == 200 && response.data['secure_url'] != null) {
        final url = response.data['secure_url'] as String;
        setState(() {
          _thumbnailUrl = url;
          _thumbnailController.text = url;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thumbnail uploaded successfully'), backgroundColor: Colors.green),
          );
        }
      } else {
        throw Exception(response.data['message'] ?? 'Upload failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingThumbnail = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _thumbnailController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _submitCourse() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      final courseData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'thumbnail': _thumbnailController.text.isNotEmpty ? _thumbnailController.text : null,
        'category': _category,
        'targetAudience': _targetAudience,
        'difficulty': _difficulty,
        'duration': _duration,
        'isPublished': _isPublished,
        'modules': _modules,
      };
      
      await _lmsService.createCourse(courseData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course created successfully!')),
        );
        Navigator.pop(context); // Return to LMS dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      _submitCourse();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Create New Course',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          
          // Form content
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildBasicInfoStep(isDesktop),
                  _buildDetailsStep(isDesktop),
                  _buildModulesStep(isDesktop),
                ],
              ),
            ),
          ),
          
          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Basic Info'),
          Expanded(child: _buildStepLine(0)),
          _buildStepIndicator(1, 'Details'),
          Expanded(child: _buildStepLine(1)),
          _buildStepIndicator(2, 'Modules'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryColor : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? AppColors.primaryColor : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    final isActive = _currentStep > step;
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 30),
      color: isActive ? AppColors.primaryColor : Colors.grey[300],
    );
  }

  Widget _buildBasicInfoStep(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : 20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Let\'s start with the basics of your course',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 32),
              
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Course Title *',
                  hintText: 'e.g., Introduction to Diabetes Management',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Course Description *',
                  hintText: 'Describe what students will learn...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // ── Thumbnail Upload ──────────────────────────────
              const Text('Course Thumbnail (optional)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
              const SizedBox(height: 8),
              // Preview
              if (_thumbnailUrl != null && _thumbnailUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _thumbnailUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(Icons.broken_image_outlined, color: Color(0xFF94A3B8), size: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _thumbnailController,
                      onChanged: (v) => setState(() => _thumbnailUrl = v.trim().isEmpty ? null : v.trim()),
                      decoration: const InputDecoration(
                        labelText: 'Paste image URL',
                        hintText: 'https://example.com/image.jpg',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link_rounded),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _uploadingThumbnail
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : ElevatedButton.icon(
                          onPressed: _pickAndUploadThumbnail,
                          icon: const Icon(Icons.upload_rounded, size: 16),
                          label: const Text('Upload'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsStep(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : 20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Course Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Configure course settings and audience',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 32),
              
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'HealthProgram', child: Text('Health Program')),
                  DropdownMenuItem(value: 'Medical Training', child: Text('Medical Training')),
                  DropdownMenuItem(value: 'Wellness', child: Text('Wellness')),
                  DropdownMenuItem(value: 'Nutrition', child: Text('Nutrition')),
                  DropdownMenuItem(value: 'Mental Health', child: Text('Mental Health')),
                ],
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 20),
              
              DropdownButtonFormField<String>(
                value: _targetAudience,
                decoration: const InputDecoration(
                  labelText: 'Target Audience',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Patient', child: Text('Patients')),
                  DropdownMenuItem(value: 'Doctor', child: Text('Healthcare Professionals')),
                  DropdownMenuItem(value: 'All', child: Text('Everyone')),
                ],
                onChanged: (value) => setState(() => _targetAudience = value!),
              ),
              const SizedBox(height: 20),
              
              DropdownButtonFormField<String>(
                value: _difficulty,
                decoration: const InputDecoration(
                  labelText: 'Difficulty Level',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
                  DropdownMenuItem(value: 'Intermediate', child: Text('Intermediate')),
                  DropdownMenuItem(value: 'Advanced', child: Text('Advanced')),
                ],
                onChanged: (value) => setState(() => _difficulty = value!),
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                initialValue: _duration.toString(),
                decoration: const InputDecoration(
                  labelText: 'Duration (weeks)',
                  border: OutlineInputBorder(),
                  suffixText: 'weeks',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() => _duration = int.tryParse(value) ?? 4);
                },
              ),
              const SizedBox(height: 20),
              
              SwitchListTile(
                title: const Text('Publish immediately'),
                subtitle: const Text('Make this course visible to students'),
                value: _isPublished,
                onChanged: (value) => setState(() => _isPublished = value),
                activeColor: AppColors.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModulesStep(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : 20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Course Modules',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add modules and lessons (you can add more later)',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _addModule,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add Module'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              if (_modules.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No modules yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add your first module to organize course content',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _modules.length,
                  itemBuilder: (context, index) {
                    return _buildModuleCard(index);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard(int index) {
    final module = _modules[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryColor,
          child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
        ),
        title: Text(module['title'] ?? 'Module ${index + 1}'),
        subtitle: Text('${(module['lessons'] as List).length} lessons'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => setState(() => _modules.removeAt(index)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(module['description'] ?? 'No description'),
                const SizedBox(height: 16),
                const Text(
                  'Lessons:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...(module['lessons'] as List).map((lesson) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.play_circle_outline, size: 20),
                    title: Text(lesson['title']),
                    subtitle: Text('${lesson['duration']} min'),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addModule() {
    showDialog(
      context: context,
      builder: (context) => _ModuleDialog(
        onSave: (module) {
          setState(() => _modules.add(module));
        },
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _previousStep,
              child: const Text('Back'),
            )
          else
            const SizedBox(),
          
          ElevatedButton(
            onPressed: _isSubmitting ? null : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(_currentStep < 2 ? 'Next' : 'Create Course'),
          ),
        ],
      ),
    );
  }
}

// Module Dialog
class _ModuleDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  
  const _ModuleDialog({required this.onSave});

  @override
  State<_ModuleDialog> createState() => _ModuleDialogState();
}

class _ModuleDialogState extends State<_ModuleDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<Map<String, dynamic>> _lessons = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Module'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Module Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Lessons', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: _addLesson,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Lesson'),
                  ),
                ],
              ),
              ..._lessons.map((lesson) {
                return ListTile(
                  dense: true,
                  title: Text(lesson['title']),
                  subtitle: Text('${lesson['duration']} min'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => setState(() => _lessons.remove(lesson)),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              widget.onSave({
                'title': _titleController.text,
                'description': _descriptionController.text,
                'lessons': _lessons,
                'order': 0,
              });
              Navigator.pop(context);
            }
          },
          child: const Text('Save Module'),
        ),
      ],
    );
  }

  void _addLesson() {
    final titleController = TextEditingController();
    final durationController = TextEditingController(text: '15');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Lesson'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Lesson Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  _lessons.add({
                    'title': titleController.text,
                    'duration': int.tryParse(durationController.text) ?? 15,
                    'order': _lessons.length,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
