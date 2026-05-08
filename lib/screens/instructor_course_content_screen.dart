import 'package:flutter/material.dart';
import 'package:icare/services/lms_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:go_router/go_router.dart';

/// Course Content Management - Moodle/Udemy style
class InstructorCourseContentScreen extends StatefulWidget {
  final String courseId;

  const InstructorCourseContentScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<InstructorCourseContentScreen> createState() => _InstructorCourseContentScreenState();
}

class _InstructorCourseContentScreenState extends State<InstructorCourseContentScreen> {
  final LmsService _lmsService = LmsService();

  Map<String, dynamic>? _course;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    setState(() => _isLoading = true);
    try {
      final response = await _lmsService.getCourseDetails(widget.courseId);
      if (mounted) {
        setState(() {
          _course = response['course'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _addModule() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ModuleDialog(),
    );

    if (result != null) {
      // Add module to course
      final modules = List<Map<String, dynamic>>.from(_course?['modules'] ?? []);
      modules.add(result);

      try {
        await _lmsService.updateCourse(widget.courseId, {'modules': modules});
        _loadCourse();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Module added successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _editModule(int index) async {
    final modules = List<Map<String, dynamic>>.from(_course?['modules'] ?? []);
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ModuleDialog(module: modules[index]),
    );

    if (result != null) {
      modules[index] = result;
      try {
        await _lmsService.updateCourse(widget.courseId, {'modules': modules});
        _loadCourse();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Module updated successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _deleteModule(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Module'),
        content: const Text('Are you sure you want to delete this module?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final modules = List<Map<String, dynamic>>.from(_course?['modules'] ?? []);
      modules.removeAt(index);
      try {
        await _lmsService.updateCourse(widget.courseId, {'modules': modules});
        _loadCourse();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Module deleted successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final modules = List<Map<String, dynamic>>.from(_course?['modules'] ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Course Content',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            Text(
              _course?['title'] ?? 'Untitled Course',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryColor),
            tooltip: 'Add Module',
            onPressed: _addModule,
          ),
        ],
      ),
      body: modules.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadCourse,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  return _buildModuleCard(modules[index], index);
                },
              ),
            ),
    );
  }

  Widget _buildModuleCard(Map<String, dynamic> module, int index) {
    final lessons = List<Map<String, dynamic>>.from(module['lessons'] ?? []);
    final title = module['title'] ?? 'Module ${index + 1}';
    final description = module['description'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: CircleAvatar(
            backgroundColor: AppColors.primaryColor,
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          subtitle: description.isNotEmpty
              ? Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${lessons.length} lessons',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 12),
                        Text('Edit'),
                      ],
                    ),
                    onTap: () => Future.delayed(
                      const Duration(milliseconds: 100),
                      () => _editModule(index),
                    ),
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    onTap: () => Future.delayed(
                      const Duration(milliseconds: 100),
                      () => _deleteModule(index),
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            if (lessons.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No lessons yet. Edit module to add lessons.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
              )
            else
              ...lessons.asMap().entries.map((entry) {
                final lessonIndex = entry.key;
                final lesson = entry.value;
                return _buildLessonItem(lesson, lessonIndex);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonItem(Map<String, dynamic> lesson, int index) {
    final title = lesson['title'] ?? 'Lesson ${index + 1}';
    final duration = lesson['duration'] ?? 0;
    final hasVideo = lesson['videoUrl'] != null && lesson['videoUrl'].toString().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasVideo
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : const Color(0xFF94A3B8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              hasVideo ? Icons.play_circle_outline : Icons.article_outlined,
              size: 20,
              color: hasVideo ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (duration > 0)
                  Text(
                    '$duration min',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first module to organize course content',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addModule,
            icon: const Icon(Icons.add),
            label: const Text('Add Module'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// Module Dialog
class _ModuleDialog extends StatefulWidget {
  final Map<String, dynamic>? module;

  const _ModuleDialog({this.module});

  @override
  State<_ModuleDialog> createState() => _ModuleDialogState();
}

class _ModuleDialogState extends State<_ModuleDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<Map<String, dynamic>> _lessons = [];

  @override
  void initState() {
    super.initState();
    if (widget.module != null) {
      _titleController.text = widget.module!['title'] ?? '';
      _descriptionController.text = widget.module!['description'] ?? '';
      if (widget.module!['lessons'] != null) {
        _lessons.addAll(List<Map<String, dynamic>>.from(widget.module!['lessons']));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addLesson() {
    showDialog(
      context: context,
      builder: (context) => _LessonDialog(
        onSave: (lesson) {
          setState(() => _lessons.add(lesson));
        },
      ),
    );
  }

  void _editLesson(int index) {
    showDialog(
      context: context,
      builder: (context) => _LessonDialog(
        lesson: _lessons[index],
        onSave: (lesson) {
          setState(() => _lessons[index] = lesson);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.module != null ? 'Edit Module' : 'Add Module'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Module Title *',
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
                  Text(
                    'Lessons (${_lessons.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextButton.icon(
                    onPressed: _addLesson,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Lesson'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_lessons.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No lessons yet', style: TextStyle(color: Color(0xFF94A3B8))),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = _lessons[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.play_circle_outline, size: 20),
                      title: Text(lesson['title'] ?? 'Lesson ${index + 1}'),
                      subtitle: Text('${lesson['duration'] ?? 0} min'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () => _editLesson(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                            onPressed: () => setState(() => _lessons.removeAt(index)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
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
            if (_titleController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Module title is required')),
              );
              return;
            }

            Navigator.pop(context, {
              'title': _titleController.text,
              'description': _descriptionController.text,
              'lessons': _lessons,
              'order': widget.module?['order'] ?? 0,
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Lesson Dialog
class _LessonDialog extends StatefulWidget {
  final Map<String, dynamic>? lesson;
  final Function(Map<String, dynamic>) onSave;

  const _LessonDialog({this.lesson, required this.onSave});

  @override
  State<_LessonDialog> createState() => _LessonDialogState();
}

class _LessonDialogState extends State<_LessonDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _videoUrlController = TextEditingController();
  int _duration = 15;

  @override
  void initState() {
    super.initState();
    if (widget.lesson != null) {
      _titleController.text = widget.lesson!['title'] ?? '';
      _contentController.text = widget.lesson!['content'] ?? '';
      _videoUrlController.text = widget.lesson!['videoUrl'] ?? '';
      _duration = widget.lesson!['duration'] ?? 15;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.lesson != null ? 'Edit Lesson' : 'Add Lesson'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Lesson Title *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content/Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _videoUrlController,
                decoration: const InputDecoration(
                  labelText: 'Video URL (YouTube, Vimeo, etc.)',
                  hintText: 'https://youtube.com/watch?v=...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.video_library),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: _duration.toString()),
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _duration = int.tryParse(value) ?? 15,
              ),
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
            if (_titleController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lesson title is required')),
              );
              return;
            }

            widget.onSave({
              'title': _titleController.text,
              'content': _contentController.text,
              'videoUrl': _videoUrlController.text,
              'duration': _duration,
              'order': widget.lesson?['order'] ?? 0,
            });
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
