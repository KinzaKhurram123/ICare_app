import 'package:flutter/material.dart';
import 'package:icare/services/lms_service.dart';
import 'package:icare/widgets/instructor_sidebar.dart';
import 'package:icare/utils/theme.dart';
import 'package:go_router/go_router.dart';

/// Instructor LMS Dashboard - Google Classroom/Moodle style
class InstructorLmsDashboard extends StatefulWidget {
  const InstructorLmsDashboard({super.key});

  @override
  State<InstructorLmsDashboard> createState() => _InstructorLmsDashboardState();
}

class _InstructorLmsDashboardState extends State<InstructorLmsDashboard> {
  final LmsService _lmsService = LmsService();
  
  Map<String, dynamic> _stats = {
    'totalCourses': 0,
    'totalStudents': 0,
    'pendingAssignments': 0,
    'upcomingSessions': 0,
  };
  
  List<dynamic> _recentCourses = [];
  List<dynamic> _upcomingSessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      // Load instructor courses
      final coursesResponse = await _lmsService.getInstructorCourses();
      final courses = coursesResponse['courses'] ?? [];
      
      // Load upcoming sessions
      final sessions = await _lmsService.getUpcomingSessions();
      
      // Calculate stats
      int totalStudents = 0;
      for (var course in courses) {
        totalStudents += (course['enrolledCount'] ?? 0) as int;
      }
      
      setState(() {
        _recentCourses = courses.take(4).toList();
        _upcomingSessions = sessions.take(3).toList();
        _stats = {
          'totalCourses': courses.length,
          'totalStudents': totalStudents,
          'pendingAssignments': 0, // TODO: Implement
          'upcomingSessions': sessions.length,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    
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
          'LMS - Teaching Dashboard',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryColor),
            tooltip: 'Create New Course',
            onPressed: () => context.push('/instructor/lms/create-course'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF0F172A)),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const InstructorSidebar(currentRoute: 'lms'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(isDesktop ? 32 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    _buildWelcomeSection(),
                    const SizedBox(height: 24),
                    
                    // Stats Cards
                    _buildStatsGrid(isDesktop),
                    const SizedBox(height: 32),
                    
                    // Quick Actions
                    _buildQuickActions(isDesktop),
                    const SizedBox(height: 32),
                    
                    // Recent Courses & Upcoming Sessions
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildRecentCourses()),
                          const SizedBox(width: 24),
                          Expanded(child: _buildUpcomingSessions()),
                        ],
                      )
                    else ...[
                      _buildRecentCourses(),
                      const SizedBox(height: 24),
                      _buildUpcomingSessions(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryColor, Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back, Instructor! 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your courses, students, and teaching activities',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.school_rounded, color: Colors.white, size: 64),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(bool isDesktop) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: isDesktop ? 1.5 : 1.3,
      children: [
        _buildStatCard(
          'My Courses',
          '${_stats['totalCourses']}',
          Icons.menu_book_rounded,
          const Color(0xFF6366F1),
        ),
        _buildStatCard(
          'Total Students',
          '${_stats['totalStudents']}',
          Icons.group_rounded,
          const Color(0xFF10B981),
        ),
        _buildStatCard(
          'Pending Grading',
          '${_stats['pendingAssignments']}',
          Icons.assignment_turned_in_rounded,
          const Color(0xFFF59E0B),
        ),
        _buildStatCard(
          'Live Sessions',
          '${_stats['upcomingSessions']}',
          Icons.video_call_rounded,
          const Color(0xFFEC4899),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDesktop) {
    final actions = [
      {
        'title': 'Create Course',
        'icon': Icons.add_circle_outline,
        'color': const Color(0xFF6366F1),
        'route': '/instructor/lms/create-course',
      },
      {
        'title': 'Schedule Session',
        'icon': Icons.video_call_rounded,
        'color': const Color(0xFFEC4899),
        'route': '/instructor/lms/schedule-session',
      },
      {
        'title': 'Create Quiz',
        'icon': Icons.quiz_rounded,
        'color': const Color(0xFF10B981),
        'route': '/instructor/lms/create-quiz',
      },
      {
        'title': 'View Students',
        'icon': Icons.people_rounded,
        'color': const Color(0xFFF59E0B),
        'route': '/instructor/lms/students',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 4 : 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return InkWell(
              onTap: () => context.push(action['route'] as String),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      action['title'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentCourses() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Courses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              TextButton(
                onPressed: () => context.push('/instructor/lms/courses'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_recentCourses.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No courses yet. Create your first course!'),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentCourses.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final course = _recentCourses[index];
                return _buildCourseItem(course);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCourseItem(Map<String, dynamic> course) {
    return InkWell(
      onTap: () => context.push('/instructor/lms/course/${course['_id']}'),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: AppColors.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['title'] ?? 'Untitled Course',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${course['enrolledCount'] ?? 0} students • ${course['modules']?.length ?? 0} modules',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF64748B)),
        ],
      ),
    );
  }

  Widget _buildUpcomingSessions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Sessions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              TextButton(
                onPressed: () => context.push('/instructor/lms/sessions'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_upcomingSessions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No upcoming sessions'),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _upcomingSessions.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final session = _upcomingSessions[index];
                return _buildSessionItem(session);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSessionItem(Map<String, dynamic> session) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFEC4899).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.video_call_rounded,
            color: Color(0xFFEC4899),
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session['title'] ?? 'Untitled Session',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${session['duration'] ?? 60} min • ${session['participants']?.length ?? 0} registered',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
