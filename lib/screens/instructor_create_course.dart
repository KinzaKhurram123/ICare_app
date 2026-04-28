import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:icare/models/course.dart';
import 'package:icare/services/instructor_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text_input.dart';

class InstructorCreateCourseScreen extends StatefulWidget {
  final Course? course;

  const InstructorCreateCourseScreen({super.key, this.course});

  @override
  State<InstructorCreateCourseScreen> createState() =>
      _InstructorCreateCourseScreenState();
}

class _InstructorCreateCourseScreenState
    extends State<InstructorCreateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final InstructorService _instructorService = InstructorService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _thumbnailController;
  late TextEditingController _durationController;

  CourseCategory _category = CourseCategory.healthProgram;
  TargetAudience _targetAudience = TargetAudience.patient;
  CourseDifficulty? _difficulty;

  bool _isLoading = false;
  bool _isEditing = false;
  String? _uploadedThumbnailUrl;
  List<String> _healthConditions = [];
  List<CourseModule> _modules = [];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.course != null;

    _titleController = TextEditingController(text: widget.course?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.course?.description ?? '',
    );
    _thumbnailController = TextEditingController(
      text: widget.course?.thumbnail ?? '',
    );
    _durationController = TextEditingController(
      text: widget.course?.duration?.toString() ?? '',
    );

    if (_isEditing) {
      _category = widget.course!.category;
      _targetAudience = widget.course!.targetAudience;
      _difficulty = widget.course!.difficulty;
      _healthConditions = List.from(widget.course!.healthConditions);
      _modules = List.from(widget.course!.modules);
      _uploadedThumbnailUrl = widget.course!.thumbnail;
    }
  }

  Future<void> _pickAndUploadThumbnail() async {
    // Show dialog to paste image URL
    final urlController = TextEditingController(text: _thumbnailController.text);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Course Thumbnail'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste an image URL (Imgur, Cloudinary, or any direct image link):',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                hintText: 'https://i.imgur.com/...',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, urlController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _uploadedThumbnailUrl = result;
        _thumbnailController.text = result;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _thumbnailController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;
    if (_modules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one module')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final courseData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'thumbnail': _thumbnailController.text.trim().isNotEmpty
            ? _thumbnailController.text.trim()
            : (_uploadedThumbnailUrl ?? ''),
        'thumbnail_url': _thumbnailController.text.trim().isNotEmpty
            ? _thumbnailController.text.trim()
            : (_uploadedThumbnailUrl ?? ''),
        'duration': int.tryParse(_durationController.text) ?? 0,
        'category': _category.value,
        'targetAudience': _targetAudience.value,
        if (_difficulty != null) 'difficulty': _difficulty!.value,
        'healthConditions': _healthConditions,
        'modules': _modules.map((m) => m.toJson()).toList(),
        'isPublished': false,
        'visibility': 'private',
      };

      if (_isEditing) {
        await _instructorService.updateCourse(widget.course!.id ?? '', courseData);
      } else {
        await _instructorService.createCourse(courseData);
      }

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Course updated successfully!'
                  : 'Course created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String msg = 'Something went wrong. Please try again.';
        if (e is DioException) {
          msg = e.response?.data?['message'] as String? ?? e.message ?? msg;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _addHealthCondition(String condition) {
    if (condition.isNotEmpty && !_healthConditions.contains(condition)) {
      setState(() => _healthConditions.add(condition));
    }
  }

  void _removeHealthCondition(String condition) {
    setState(() => _healthConditions.remove(condition));
  }

  void _addModule() async {
    final module = await Navigator.of(context).push<CourseModule>(
      MaterialPageRoute(
        builder: (ctx) => ModuleEditorScreen(order: _modules.length + 1),
      ),
    );

    if (module != null) {
      setState(() => _modules.add(module));
    }
  }

  void _editModule(int index) async {
    final module = await Navigator.of(context).push<CourseModule>(
      MaterialPageRoute(
        builder: (ctx) =>
            ModuleEditorScreen(module: _modules[index], order: index + 1),
      ),
    );

    if (module != null) {
      setState(() => _modules[index] = module);
    }
  }

  void _deleteModule(int index) {
    setState(() => _modules.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const CustomBackButton(),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Course' : 'Create New Course',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildCategorySection(),
              const SizedBox(height: 24),
              _buildModulesSection(),
              const SizedBox(height: 32),
              CustomButton(
                label: _isLoading
                    ? 'Saving...'
                    : (_isEditing ? 'Update Course' : 'Create Course'),
                onPressed: _isLoading ? null : _saveCourse,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        CustomInputField(
          controller: _titleController,
          hintText: 'Course Title',
          validator: (val) => val?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        CustomInputField(
          controller: _descriptionController,
          hintText: 'Course Description',
          maxLines: 3,
          validator: (val) => val?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomInputField(
                controller: _durationController,
                hintText: 'Duration (hours)',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Thumbnail upload
        GestureDetector(
          onTap: _pickAndUploadThumbnail,
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _uploadedThumbnailUrl != null
                    ? AppColors.primaryColor.withValues(alpha: 0.4)
                    : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: _uploadedThumbnailUrl != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Image.network(
                              _uploadedThumbnailUrl!,
                              width: double.infinity,
                              height: 160,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.broken_image_outlined, size: 40, color: Color(0xFFCBD5E1)),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: _pickAndUploadThumbnail,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.edit, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.add_photo_alternate_outlined, size: 32, color: AppColors.primaryColor),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Upload Course Thumbnail',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'JPG, PNG or WebP — max 5MB',
                            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category & Audience',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<CourseCategory>(
          value: _category,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
          ),
          items: CourseCategory.values.map((cat) {
            return DropdownMenuItem(value: cat, child: Text(cat.displayName));
          }).toList(),
          onChanged: (val) => setState(() => _category = val!),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<TargetAudience>(
          value: _targetAudience,
          decoration: const InputDecoration(
            labelText: 'Target Audience',
            border: OutlineInputBorder(),
          ),
          items: [
            TargetAudience.patient,
            TargetAudience.doctor,
            TargetAudience.student,
            TargetAudience.both,
            TargetAudience.all,
          ].map((aud) {
            return DropdownMenuItem(value: aud, child: Text(aud.displayName));
          }).toList(),
          onChanged: (val) => setState(() => _targetAudience = val!),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<CourseDifficulty?>(
          value: _difficulty,
          decoration: const InputDecoration(
            labelText: 'Difficulty (optional)',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('Not specified')),
            ...CourseDifficulty.values.map((diff) {
              return DropdownMenuItem(
                value: diff,
                child: Text(diff.displayName),
              );
            }),
          ],
          onChanged: (val) => setState(() => _difficulty = val),
        ),
      ],
    );
  }

  Widget _buildHealthConditionsSection() {
    final TextEditingController conditionController = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Conditions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Add relevant health conditions for this course',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: conditionController,
                decoration: const InputDecoration(
                  hintText: 'Enter condition',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (val) {
                  _addHealthCondition(val);
                  conditionController.clear();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _healthConditions.map((condition) {
            return Chip(
              label: Text(condition),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => _removeHealthCondition(condition),
              backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
              labelStyle: const TextStyle(color: AppColors.primaryColor),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildModulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Course Modules',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            TextButton.icon(
              onPressed: _addModule,
              icon: const Icon(Icons.add),
              label: const Text('Add Module'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_modules.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 48,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No modules yet',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Add modules with lessons and quizzes',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ],
              ),
            ),
          )
        else
          ..._modules.asMap().entries.map((entry) {
            final i = entry.key;
            final module = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryColor.withValues(
                    alpha: 0.1,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(color: AppColors.primaryColor),
                  ),
                ),
                title: Text(
                  module.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${module.lessons.length} lessons${module.quiz != null ? ' • Quiz included' : ''}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => _editModule(i),
                      color: AppColors.primaryColor,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => _deleteModule(i),
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

class ModuleEditorScreen extends StatefulWidget {
  final CourseModule? module;
  final int order;

  const ModuleEditorScreen({super.key, this.module, required this.order});

  @override
  State<ModuleEditorScreen> createState() => _ModuleEditorScreenState();
}

class _ModuleEditorScreenState extends State<ModuleEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Lesson> _lessons = [];
  Quiz? _quiz;

  @override
  void initState() {
    super.initState();
    if (widget.module != null) {
      _titleController.text = widget.module!.title;
      _descriptionController.text = widget.module!.description;
      _lessons = List.from(widget.module!.lessons);
      _quiz = widget.module!.quiz;
    }
  }

  void _saveModule() {
    if (!_formKey.currentState!.validate()) return;

    final module = CourseModule(
      id: widget.module?.id,
      title: _titleController.text,
      description: _descriptionController.text,
      order: widget.order,
      lessons: _lessons,
      quiz: _quiz,
    );

    Navigator.of(context).pop(module);
  }

  void _addLesson() async {
    final lesson = await Navigator.of(context).push<Lesson>(
      MaterialPageRoute(
        builder: (ctx) => LessonEditorScreen(order: _lessons.length + 1),
      ),
    );

    if (lesson != null) {
      setState(() => _lessons.add(lesson));
    }
  }

  void _editLesson(int index) async {
    final lesson = await Navigator.of(context).push<Lesson>(
      MaterialPageRoute(
        builder: (ctx) =>
            LessonEditorScreen(lesson: _lessons[index], order: index + 1),
      ),
    );

    if (lesson != null) {
      setState(() => _lessons[index] = lesson);
    }
  }

  void _deleteLesson(int index) {
    setState(() => _lessons.removeAt(index));
  }

  void _addQuiz() async {
    final quiz = await Navigator.of(context).push<Quiz>(
      MaterialPageRoute(builder: (ctx) => QuizEditorScreen(quiz: _quiz)),
    );

    if (quiz != null) {
      setState(() => _quiz = quiz);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const CustomBackButton(),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.module == null ? 'Add Module' : 'Edit Module',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveModule,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomInputField(
                controller: _titleController,
                hintText: 'Module Title',
                validator: (val) => val?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _descriptionController,
                hintText: 'Module Description',
                maxLines: 3,
                validator: (val) => val?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lessons',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  TextButton.icon(
                    onPressed: _addLesson,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Lesson'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_lessons.isEmpty)
                const Text(
                  'No lessons yet',
                  style: TextStyle(color: Color(0xFF64748B)),
                )
              else
                ..._lessons.asMap().entries.map((entry) {
                  final i = entry.key;
                  final lesson = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryColor.withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(lesson.title),
                      subtitle: Text('${lesson.duration ?? 0} min'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () => _editLesson(i),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            onPressed: () => _deleteLesson(i),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quiz',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  TextButton.icon(
                    onPressed: _addQuiz,
                    icon: Icon(_quiz == null ? Icons.add : Icons.edit),
                    label: Text(_quiz == null ? 'Add Quiz' : 'Edit Quiz'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_quiz != null)
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.quiz_outlined,
                      color: AppColors.primaryColor,
                    ),
                    title: Text('${_quiz!.questions.length} questions'),
                    subtitle: Text('Passing score: ${_quiz!.passingScore}%'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => setState(() => _quiz = null),
                    ),
                  ),
                )
              else
                const Text(
                  'No quiz added',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class LessonEditorScreen extends StatefulWidget {
  final Lesson? lesson;
  final int order;

  const LessonEditorScreen({super.key, this.lesson, required this.order});

  @override
  State<LessonEditorScreen> createState() => _LessonEditorScreenState();
}

class _LessonEditorScreenState extends State<LessonEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  String? _uploadedVideoUrl;

  @override
  void initState() {
    super.initState();
    if (widget.lesson != null) {
      _titleController.text = widget.lesson!.title;
      _contentController.text = widget.lesson!.content;
      _videoUrlController.text = widget.lesson!.videoUrl ?? '';
      _durationController.text = widget.lesson!.duration?.toString() ?? '';
      _uploadedVideoUrl = widget.lesson!.videoUrl;
    }
  }

  bool _isUploadingVideo = false;

  Future<void> _pickAndUploadVideo() async {
    // Show options: URL paste OR file upload
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Lesson Video'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link_rounded, color: Color(0xFF3B82F6)),
              title: const Text('Paste Video URL'),
              subtitle: const Text('YouTube, Vimeo, or direct .mp4 link'),
              onTap: () => Navigator.pop(ctx, 'url'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.upload_file_rounded, color: Color(0xFF10B981)),
              title: const Text('Upload Video File'),
              subtitle: const Text('MP4, MOV, AVI (max 100MB)'),
              onTap: () => Navigator.pop(ctx, 'file'),
            ),
          ],
        ),
      ),
    );

    if (choice == 'url') {
      await _pasteVideoUrl();
    } else if (choice == 'file') {
      await _uploadVideoFile();
    }
  }

  Future<void> _pasteVideoUrl() async {
    final urlController = TextEditingController(text: _videoUrlController.text);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Paste Video URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'YouTube, Vimeo, or direct .mp4 link:',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                hintText: 'https://youtube.com/watch?v=...',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, urlController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        _uploadedVideoUrl = result;
        _videoUrlController.text = result;
      });
    }
  }

  Future<void> _uploadVideoFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not read file. Try pasting a URL instead.'), backgroundColor: Colors.orange),
          );
        }
        return;
      }

      // Check file size (100MB limit)
      if (file.size > 100 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File too large. Max 100MB. Please use a URL instead.'), backgroundColor: Colors.red),
          );
        }
        return;
      }

      setState(() => _isUploadingVideo = true);

      // Upload to Cloudinary (free unsigned upload)
      // Using icare's Cloudinary cloud - unsigned upload preset
      const cloudName = 'demoicare'; // Cloudinary cloud name
      const uploadPreset = 'icare_videos'; // unsigned upload preset

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
        ),
        'upload_preset': uploadPreset,
        'resource_type': 'video',
        'folder': 'icare_lessons',
      });

      final dio = Dio();
      final response = await dio.post(
        'https://api.cloudinary.com/v1_1/$cloudName/video/upload',
        data: formData,
        onSendProgress: (sent, total) {
          // Could show progress here
        },
      );

      if (response.statusCode == 200) {
        final videoUrl = response.data['secure_url'] as String;
        setState(() {
          _uploadedVideoUrl = videoUrl;
          _videoUrlController.text = videoUrl;
          _isUploadingVideo = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Video uploaded successfully!'), backgroundColor: Colors.green),
          );
        }
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isUploadingVideo = false);
      if (mounted) {
        // If Cloudinary fails, offer URL option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Upload failed. Please paste a video URL instead.'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Paste URL',
              textColor: Colors.white,
              onPressed: _pasteVideoUrl,
            ),
          ),
        );
      }
    }
  }

  void _saveLesson() {
    if (!_formKey.currentState!.validate()) return;

    final lesson = Lesson(
      id: widget.lesson?.id,
      title: _titleController.text,
      content: _contentController.text,
      videoUrl: _videoUrlController.text.isNotEmpty
          ? _videoUrlController.text
          : null,
      duration: _durationController.text.isNotEmpty
          ? int.parse(_durationController.text)
          : null,
      order: widget.order,
    );

    Navigator.of(context).pop(lesson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const CustomBackButton(),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.lesson == null ? 'Add Lesson' : 'Edit Lesson',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveLesson,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CustomInputField(
                controller: _titleController,
                hintText: 'Lesson Title',
                validator: (val) => val?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _contentController,
                hintText: 'Lesson Content',
                maxLines: 5,
                validator: (val) => val?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              // Video URL section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _uploadedVideoUrl != null
                        ? Colors.green.withOpacity(0.4)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lesson Video',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'YouTube, Vimeo, or direct .mp4 link',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomInputField(
                            controller: _videoUrlController,
                            hintText: 'https://youtube.com/watch?v=...',
                            onChanged: (val) {
                              setState(() => _uploadedVideoUrl = val.isNotEmpty ? val : null);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        _isUploadingVideo
                            ? const SizedBox(
                                width: 44,
                                height: 44,
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: _pickAndUploadVideo,
                                icon: const Icon(Icons.video_call_rounded, size: 18),
                                label: const Text('Add Video'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                      ],
                    ),
                    if (_isUploadingVideo)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            SizedBox(width: 4),
                            Text(
                              'Uploading video... please wait',
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    if (_uploadedVideoUrl != null && _uploadedVideoUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: Colors.green, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _uploadedVideoUrl!,
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xFF64748B)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  size: 16, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _uploadedVideoUrl = null;
                                  _videoUrlController.clear();
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _durationController,
                hintText: 'Duration (minutes)',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _videoUrlController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}

class QuizEditorScreen extends StatefulWidget {
  final Quiz? quiz;

  const QuizEditorScreen({super.key, this.quiz});

  @override
  State<QuizEditorScreen> createState() => _QuizEditorScreenState();
}

class _QuizEditorScreenState extends State<QuizEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passingScoreController = TextEditingController();
  List<QuizQuestion> _questions = [];

  @override
  void initState() {
    super.initState();
    if (widget.quiz != null) {
      _passingScoreController.text = widget.quiz!.passingScore.toString();
      _questions = List.from(widget.quiz!.questions);
    } else {
      _passingScoreController.text = '70';
    }
  }

  void _saveQuiz() {
    if (!_formKey.currentState!.validate()) return;

    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one question')),
      );
      return;
    }

    final quiz = Quiz(
      questions: _questions,
      passingScore: int.parse(_passingScoreController.text),
    );

    Navigator.of(context).pop(quiz);
  }

  void _addQuestion() async {
    final question = await Navigator.of(context).push<QuizQuestion>(
      MaterialPageRoute(builder: (ctx) => const QuestionEditorScreen()),
    );

    if (question != null) {
      setState(() => _questions.add(question));
    }
  }

  void _editQuestion(int index) async {
    final question = await Navigator.of(context).push<QuizQuestion>(
      MaterialPageRoute(
        builder: (ctx) => QuestionEditorScreen(question: _questions[index]),
      ),
    );

    if (question != null) {
      setState(() => _questions[index] = question);
    }
  }

  void _deleteQuestion(int index) {
    setState(() => _questions.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const CustomBackButton(),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Quiz Editor',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveQuiz,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomInputField(
                controller: _passingScoreController,
                hintText: 'Passing Score (%)',
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val?.isEmpty ?? true) return 'Required';
                  final score = int.tryParse(val!);
                  if (score == null || score < 0 || score > 100) {
                    return 'Enter a value between 0 and 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Questions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  TextButton.icon(
                    onPressed: _addQuestion,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Question'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_questions.isEmpty)
                const Text(
                  'No questions yet',
                  style: TextStyle(color: Color(0xFF64748B)),
                )
              else
                ..._questions.asMap().entries.map((entry) {
                  final i = entry.key;
                  final question = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryColor.withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        question.question,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('${question.options.length} options'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () => _editQuestion(i),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            onPressed: () => _deleteQuestion(i),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passingScoreController.dispose();
    super.dispose();
  }
}

class QuestionEditorScreen extends StatefulWidget {
  final QuizQuestion? question;

  const QuestionEditorScreen({super.key, this.question});

  @override
  State<QuestionEditorScreen> createState() => _QuestionEditorScreenState();
}

class _QuestionEditorScreenState extends State<QuestionEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _explanationController = TextEditingController();
  final List<TextEditingController> _optionControllers = [];
  int _correctAnswer = 0;

  @override
  void initState() {
    super.initState();
    if (widget.question != null) {
      _questionController.text = widget.question!.question;
      _explanationController.text = widget.question!.explanation ?? '';
      _correctAnswer = widget.question!.correctAnswer;
      for (var option in widget.question!.options) {
        final controller = TextEditingController(text: option);
        _optionControllers.add(controller);
      }
    } else {
      for (int i = 0; i < 4; i++) {
        _optionControllers.add(TextEditingController());
      }
    }
  }

  void _saveQuestion() {
    if (!_formKey.currentState!.validate()) return;

    final options = _optionControllers
        .map((c) => c.text)
        .where((text) => text.isNotEmpty)
        .toList();

    if (options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 2 options')),
      );
      return;
    }

    final question = QuizQuestion(
      question: _questionController.text,
      options: options,
      correctAnswer: _correctAnswer,
      explanation: _explanationController.text.isNotEmpty
          ? _explanationController.text
          : null,
    );

    Navigator.of(context).pop(question);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const CustomBackButton(),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Question Editor',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveQuestion,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomInputField(
                controller: _questionController,
                hintText: 'Question',
                maxLines: 2,
                validator: (val) => val?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Options',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ..._optionControllers.asMap().entries.map((entry) {
                final i = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Radio<int>(
                        value: i,
                        groupValue: _correctAnswer,
                        onChanged: (val) =>
                            setState(() => _correctAnswer = val!),
                        activeColor: AppColors.primaryColor,
                      ),
                      Expanded(
                        child: CustomInputField(
                          controller: controller,
                          hintText: 'Option ${i + 1}',
                          validator: (val) {
                            if (i < 2 && (val?.isEmpty ?? true))
                              return 'Required';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
              CustomInputField(
                controller: _explanationController,
                hintText: 'Explanation (optional)',
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _explanationController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
