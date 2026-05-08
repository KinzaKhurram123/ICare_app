import 'package:flutter/material.dart';
import 'package:icare/screens/classroom_course_view.dart';
import 'package:icare/screens/instructor_lms_create_course.dart';
import 'package:icare/services/lms_service.dart';
import 'package:icare/utils/shared_pref.dart';
import 'package:icare/utils/theme.dart';
import 'package:go_router/go_router.dart';

/// Instructor LMS Dashboard — Google Classroom style
class InstructorLmsDashboard extends StatefulWidget {
  const InstructorLmsDashboard({super.key});

  @override
  State<InstructorLmsDashboard> createState() => _InstructorLmsDashboardState();
}

class _InstructorLmsDashboardState extends State<InstructorLmsDashboard> {
  final LmsService _lmsService = LmsService();

  List<dynamic> _courses = [];
  bool _isLoading = true;
  String _userName = '';
  int _totalStudents = 0;

  static const List<Color> _classColors = [
    Color(0xFF1565C0),
    Color(0xFF2E7D32),
    Color(0xFF6A1B9A),
    Color(0xFFD84315),
    Color(0xFF00695C),
    Color(0xFF1976D2),
    Color(0xFFAD1457),
    Color(0xFF4527A0),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadCourses();
  }

  Future<void> _loadUserName() async {
    final user = await SharedPref().getUserData();
    if (mounted && user != null) {
      setState(() {
        _userName = user.name.isNotEmpty ? user.name : user.email.split('@').first;
      });
    }
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    try {
      final response = await _lmsService.getInstructorCourses();
      final courses = (response['courses'] ?? []) as List;
      int totalStudents = 0;
      for (final c in courses) {
        totalStudents += ((c['enrolledCount'] ?? 0) as num).toInt();
      }
      if (mounted) {
        setState(() {
          _courses = courses;
          _totalStudents = totalStudents;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _cardColor(int index) => _classColors[index % _classColors.length];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF0F172A)),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'iCare Academy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded, color: Color(0xFF64748B)),
            onPressed: () => context.go('/instructor/lms/courses'),
            tooltip: 'All Courses',
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'I',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const InstructorLmsCreateCourseScreen()),
        ).then((_) => _loadCourses()),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Create Class',
          style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCourses,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // Stats banner
                  SliverToBoxAdapter(
                    child: _buildStatsBanner(),
                  ),
                  // Section title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          isWide ? 24 : 16, 20, isWide ? 24 : 16, 8),
                      child: const Text(
                        'Your Classes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                  // Courses grid
                  _courses.isEmpty
                      ? SliverToBoxAdapter(child: _buildEmptyClasses())
                      : SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                              isWide ? 24 : 16, 0, isWide ? 24 : 16, 100),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isWide
                                  ? 3
                                  : (MediaQuery.of(context).size.width > 600
                                      ? 2
                                      : 1),
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: isWide ? 1.05 : 0.95,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) => _buildClassCard(_courses[i], i),
                              childCount: _courses.length,
                            ),
                          ),
                        ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatsBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, const Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _userName.isNotEmpty ? 'Welcome back, $_userName' : 'Welcome back',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statTile(
                  Icons.class_rounded, '${_courses.length}', 'Classes'),
              const SizedBox(width: 12),
              _statTile(Icons.people_rounded, '$_totalStudents', 'Students'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard(dynamic course, int index) {
    final title = course['title'] ?? course['name'] ?? 'Untitled Course';
    final section = course['category'] ?? course['section'] ?? '';
    final enrolledCount = (course['enrolledCount'] ?? 0) as int;
    final color = _cardColor(index);
    final courseId = course['_id']?.toString() ?? '';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClassroomCourseView(
            course: Map<String, dynamic>.from(course is Map ? course : {}),
            isInstructor: true,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colored header
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.menu_book_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                  if (section.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        section,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            // Enrolled count
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Row(
                children: [
                  Icon(Icons.people_alt_rounded, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(
                    '$enrolledCount student${enrolledCount != 1 ? 's' : ''}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Status indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: course['isPublished'] == true
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: course['isPublished'] == true
                        ? const Color(0xFF10B981).withOpacity(0.3)
                        : const Color(0xFFF59E0B).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  course['isPublished'] == true ? 'Published' : 'Draft',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: course['isPublished'] == true
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _cardIconBtn(
                    Icons.open_in_new_rounded,
                    'Open',
                    color,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClassroomCourseView(
                          course: Map<String, dynamic>.from(
                              course is Map ? course : {}),
                          isInstructor: true,
                        ),
                      ),
                    ),
                  ),
                  _cardIconBtn(
                    Icons.people_rounded,
                    'Students',
                    const Color(0xFF64748B),
                    () {
                      if (courseId.isNotEmpty) {
                        context.go(
                          '/instructor/lms/course/$courseId/students',
                          extra: {'title': title},
                        );
                      }
                    },
                  ),
                  _cardIconBtn(
                    Icons.more_vert_rounded,
                    'More',
                    const Color(0xFF64748B),
                    () => _showCourseMenu(course, color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardIconBtn(
      IconData icon, String tooltip, Color color, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  void _showCourseMenu(dynamic course, Color color) {
    final courseId = course['_id']?.toString() ?? '';
    final title = course['title'] ?? 'Course';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            _menuItem(Icons.edit_rounded, 'Edit Course', color, () {
              Navigator.pop(context);
              if (courseId.isNotEmpty) {
                context.go('/instructor/lms/course/$courseId/content');
              }
            }),
            _menuItem(Icons.quiz_rounded, 'Add Quiz', color, () {
              Navigator.pop(context);
              if (courseId.isNotEmpty) {
                context.go(
                    '/instructor/lms/create-quiz?courseId=$courseId');
              }
            }),
            _menuItem(Icons.assignment_rounded, 'Add Assignment', color, () {
              Navigator.pop(context);
              if (courseId.isNotEmpty) {
                context.go(
                    '/instructor/lms/create-assignment?courseId=$courseId');
              }
            }),
            _menuItem(Icons.videocam_rounded, 'Schedule Session', color, () {
              Navigator.pop(context);
              if (courseId.isNotEmpty) {
                context.go(
                    '/instructor/lms/schedule-session?courseId=$courseId');
              }
            }),
            _menuItem(Icons.analytics_rounded, 'View Analytics', color, () {
              Navigator.pop(context);
              if (courseId.isNotEmpty) {
                context.go('/instructor/lms/course/$courseId/analytics',
                    extra: {'title': title});
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 14),
            Text(label,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A))),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyClasses() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_box_rounded,
                  size: 64, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 24),
            const Text(
              'No classes yet',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first class to get started teaching.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const InstructorLmsCreateCourseScreen()),
              ).then((_) => _loadCourses()),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Create Class',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
