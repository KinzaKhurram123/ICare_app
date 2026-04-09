import 'package:flutter/material.dart';
import 'package:icare/models/course.dart';
import 'package:icare/screens/instructor_create_course.dart';
import 'package:icare/services/course_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/instructor_sidebar.dart';

class InstructorCoursesManagementScreen extends StatefulWidget {
  const InstructorCoursesManagementScreen({super.key});

  @override
  State<InstructorCoursesManagementScreen> createState() =>
      _InstructorCoursesManagementScreenState();
}

class _InstructorCoursesManagementScreenState
    extends State<InstructorCoursesManagementScreen> {
  final CourseService _courseService = CourseService();
  List<Course> _courses = [];
  bool _isLoading = true;
  String _filter = 'all'; // all, published, unpublished

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    try {
      final courses = await _courseService.getMyCourses();
      if (mounted) {
        setState(() {
          _courses = courses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: const Text('Unable to load data. Please try again.')));
      }
    }
  }

  List<Course> get _filteredCourses {
    if (_filter == 'published') {
      return _courses.where((c) => c.isPublished).toList();
    } else if (_filter == 'unpublished') {
      return _courses.where((c) => !c.isPublished).toList();
    }
    return _courses;
  }

  Future<void> _deleteCourse(Course course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Program'),
        content: Text('Are you sure you want to delete "${course.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _courseService.deleteCourse(course.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Course deleted successfully')),
          );
          _loadCourses();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: const Text('Something went wrong. Please try again.')));
        }
      }
    }
  }

  Future<void> _togglePublishStatus(Course course) async {
    try {
      if (course.isPublished) {
        await _courseService.unpublishCourse(course.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Course unpublished successfully')),
          );
        }
      } else {
        await _courseService.publishCourse(course.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Course published successfully')),
          );
        }
      }
      _loadCourses();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: const Text('Something went wrong. Please try again.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCourses = _filteredCourses;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF0F172A)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Manage Health Programs',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      drawer: const InstructorSidebar(currentRoute: 'programs'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => const InstructorCreateCourseScreen(),
            ),
          );
          if (result == true) _loadCourses();
        },
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('New Program'),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Published', 'published'),
                const SizedBox(width: 8),
                _buildFilterChip('Unpublished', 'unpublished'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredCourses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _filter == 'all'
                              ? 'No programs yet'
                              : 'No $_filter programs',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create your first health program to get started',
                          style: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadCourses,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: filteredCourses.length,
                      itemBuilder: (ctx, i) {
                        return _buildCourseCard(filteredCourses[i]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filter = value);
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.primaryColor.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryColor : const Color(0xFF64748B),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primaryColor : const Color(0xFFE2E8F0),
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    final moduleCount = course.modules.length;
    final lessonCount = course.modules.fold<int>(
      0,
      (sum, m) => sum + m.lessons.length,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.health_and_safety_rounded,
                    color: AppColors.primaryColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildBadge(
                            course.category.displayName,
                            Icons.category_outlined,
                            const Color(0xFF8B5CF6),
                          ),
                          _buildBadge(
                            '$moduleCount modules',
                            Icons.library_books_outlined,
                            const Color(0xFF6366F1),
                          ),
                          _buildBadge(
                            '$lessonCount lessons',
                            Icons.play_circle_outline,
                            const Color(0xFF3B82F6),
                          ),
                          _buildBadge(
                            course.isPublished ? 'Published' : 'Draft',
                            course.isPublished
                                ? Icons.public
                                : Icons.lock_outline,
                            course.isPublished
                                ? const Color(0xFF10B981)
                                : const Color(0xFF64748B),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _togglePublishStatus(course),
                  icon: Icon(
                    course.isPublished ? Icons.unpublished : Icons.publish,
                    size: 18,
                  ),
                  label: Text(course.isPublished ? 'Unpublish' : 'Publish'),
                  style: TextButton.styleFrom(
                    foregroundColor: course.isPublished
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) =>
                            InstructorCreateCourseScreen(course: course),
                      ),
                    );
                    if (result == true) _loadCourses();
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deleteCourse(course),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
