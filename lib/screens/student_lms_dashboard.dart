import 'package:flutter/material.dart';
import 'package:icare/screens/lms_course_page.dart';
import 'package:icare/screens/lms_public_catalog.dart';
import 'package:icare/screens/quiz_take_screen.dart';
import 'package:icare/screens/assignment_submit_screen.dart';
import 'package:icare/services/course_service.dart';
import 'package:icare/services/lms_service.dart';
import 'package:icare/utils/shared_pref.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:intl/intl.dart';

class StudentLmsDashboard extends StatefulWidget {
  const StudentLmsDashboard({super.key});

  @override
  State<StudentLmsDashboard> createState() => _StudentLmsDashboardState();
}

class _StudentLmsDashboardState extends State<StudentLmsDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CourseService _courseService = CourseService();
  final LmsService _lmsService = LmsService();

  // Data
  List<dynamic> _enrollments = [];
  List<Map<String, dynamic>> _allAssignments = [];
  List<Map<String, dynamic>> _allQuizzes = [];
  List<dynamic> _liveSessions = [];
  List<dynamic> _pastSessions = [];

  bool _loadingCourses = true;
  bool _loadingAssignments = true;
  bool _loadingQuizzes = true;
  bool _loadingSessions = true;

  String _userName = '';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUserName();
    _loadEnrollments();
    _loadLiveSessions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final user = await SharedPref().getUserData();
    if (mounted && user != null) {
      setState(() {
        _userName = user.name ?? user.email?.split('@').first ?? 'Student';
      });
    }
  }

  Future<void> _loadEnrollments() async {
    setState(() {
      _loadingCourses = true;
      _loadingAssignments = true;
      _loadingQuizzes = true;
    });
    try {
      final enrollments = await _courseService.myPurchases();
      if (mounted) {
        setState(() {
          _enrollments = enrollments;
          _loadingCourses = false;
        });
        await _loadAssignmentsAndQuizzes(enrollments);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingCourses = false;
          _loadingAssignments = false;
          _loadingQuizzes = false;
        });
      }
    }
  }

  Future<void> _loadAssignmentsAndQuizzes(List<dynamic> enrollments) async {
    final List<Map<String, dynamic>> assignments = [];
    final List<Map<String, dynamic>> quizzes = [];

    for (final enrollment in enrollments) {
      final course = enrollment['course'] as Map<String, dynamic>? ?? {};
      final courseId = course['_id']?.toString() ?? '';
      final courseName = course['title'] ?? course['name'] ?? 'Unknown Course';
      final enrollmentId = enrollment['_id']?.toString() ?? '';

      if (courseId.isEmpty) continue;

      // Load assignments
      try {
        final courseAssignments = await _lmsService.getCourseAssignments(courseId);
        for (final a in courseAssignments) {
          assignments.add({
            ...Map<String, dynamic>.from(a is Map ? a : {}),
            '_courseName': courseName,
            '_courseId': courseId,
            '_enrollmentId': enrollmentId,
          });
        }
      } catch (_) {}

      // Load quizzes
      try {
        final courseQuizzes = await _lmsService.getCourseQuizzes(courseId);
        for (final q in courseQuizzes) {
          quizzes.add({
            ...Map<String, dynamic>.from(q is Map ? q : {}),
            '_courseName': courseName,
            '_courseId': courseId,
            '_enrollmentId': enrollmentId,
          });
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _allAssignments = assignments;
        _allQuizzes = quizzes;
        _loadingAssignments = false;
        _loadingQuizzes = false;
      });
    }
  }

  Future<void> _loadLiveSessions() async {
    setState(() => _loadingSessions = true);
    try {
      final sessions = await _lmsService.getUpcomingSessions();
      if (mounted) {
        final now = DateTime.now();
        final upcoming = <dynamic>[];
        final past = <dynamic>[];
        for (final s in sessions) {
          try {
            final dateStr = s['scheduledAt'] ?? s['date'] ?? s['startTime'] ?? '';
            if (dateStr.isNotEmpty) {
              final date = DateTime.parse(dateStr.toString());
              if (date.isAfter(now)) {
                upcoming.add(s);
              } else {
                past.add(s);
              }
            } else {
              upcoming.add(s);
            }
          } catch (_) {
            upcoming.add(s);
          }
        }
        setState(() {
          _liveSessions = upcoming;
          _pastSessions = past;
          _loadingSessions = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingSessions = false);
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _loadEnrollments(),
      _loadLiveSessions(),
    ]);
  }

  // ── Computed stats ──────────────────────────────────────────────────────

  int get _enrolledCount => _enrollments.length;

  double get _averageProgress {
    if (_enrollments.isEmpty) return 0;
    double total = 0;
    for (final e in _enrollments) {
      final p = e['progress'];
      if (p is int) total += p;
      else if (p is Map) total += (p['percent'] ?? 0).toDouble();
    }
    return total / _enrollments.length;
  }

  int get _certificatesCount => _enrollments.where((e) => e['status'] == 'completed').length;

  // ── Search helpers ──────────────────────────────────────────────────────

  List<dynamic> get _filteredEnrollments {
    if (_searchQuery.isEmpty) return _enrollments;
    final q = _searchQuery.toLowerCase();
    return _enrollments.where((e) {
      final c = e['course'] as Map? ?? {};
      return (c['title'] ?? '').toString().toLowerCase().contains(q) ||
          (c['category'] ?? '').toString().toLowerCase().contains(q);
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredAssignments {
    if (_searchQuery.isEmpty) return _allAssignments;
    final q = _searchQuery.toLowerCase();
    return _allAssignments.where((a) {
      return (a['title'] ?? '').toString().toLowerCase().contains(q) ||
          (a['_courseName'] ?? '').toString().toLowerCase().contains(q);
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredQuizzes {
    if (_searchQuery.isEmpty) return _allQuizzes;
    final q = _searchQuery.toLowerCase();
    return _allQuizzes.where((quiz) {
      return (quiz['title'] ?? '').toString().toLowerCase().contains(q) ||
          (quiz['_courseName'] ?? '').toString().toLowerCase().contains(q);
    }).toList();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  Color _courseColor(int index) {
    const colors = [
      Color(0xFF0036BC),
      Color(0xFF6366F1),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF8B5CF6),
      Color(0xFF0EA5E9),
    ];
    return colors[index % colors.length];
  }

  String _assignmentStatus(Map<String, dynamic> assignment) {
    final mySubmission = assignment['mySubmission'];
    if (mySubmission != null) return 'submitted';
    final dueDateStr = assignment['dueDate']?.toString() ?? '';
    if (dueDateStr.isNotEmpty) {
      try {
        final due = DateTime.parse(dueDateStr);
        if (DateTime.now().isAfter(due)) return 'late';
      } catch (_) {}
    }
    return 'pending';
  }

  // ── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primaryColor,
            leading: const CustomBackButton(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryColor, Color(0xFF1E3A8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 90, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName.isNotEmpty ? 'Hello, $_userName' : 'My Learning',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Track your courses, quizzes & assignments',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    // Stats row
                    Row(
                      children: [
                        _statPill(Icons.book_outlined, '$_enrolledCount Enrolled'),
                        const SizedBox(width: 8),
                        _statPill(Icons.trending_up_rounded,
                            '${_averageProgress.toStringAsFixed(0)}% Avg'),
                        const SizedBox(width: 8),
                        _statPill(Icons.workspace_premium_outlined,
                            '$_certificatesCount Certificates'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                tabs: const [
                  Tab(text: 'Courses'),
                  Tab(text: 'Assignments'),
                  Tab(text: 'Quizzes'),
                  Tab(text: 'Live'),
                ],
              ),
            ),
          ),
          // Search bar sliver
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v.trim()),
                decoration: InputDecoration(
                  hintText: 'Search courses, assignments, quizzes...',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: AppColors.primaryColor.withOpacity(0.4), width: 1.5),
                  ),
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildCoursesTab(),
            _buildAssignmentsTab(),
            _buildQuizzesTab(),
            _buildLiveSessionsTab(),
          ],
        ),
      ),
    );
  }

  // ── STAT PILL ────────────────────────────────────────────────────────────

  Widget _statPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 1: MY COURSES
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildCoursesTab() {
    if (_loadingCourses) {
      return const Center(child: CircularProgressIndicator());
    }

    final enrollments = _filteredEnrollments;

    if (enrollments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.school_outlined,
        title: 'No Courses Yet',
        subtitle: 'Browse the catalog and enroll in a course to get started.',
        buttonLabel: 'Browse Courses',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const LmsPublicCatalog())),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: enrollments.length,
        itemBuilder: (context, index) {
          final enrollment = enrollments[index];
          return _buildCourseCard(enrollment, index);
        },
      ),
    );
  }

  Widget _buildCourseCard(dynamic enrollment, int index) {
    final course = enrollment['course'] as Map<String, dynamic>? ?? {};
    final title = course['title'] ?? course['name'] ?? 'Untitled Course';
    final category = course['category'] ?? '';
    final instructor = (course['instructor'] as Map?)?['name'] ??
        (course['instructor'] as Map?)?['username'] ??
        'iCare Instructor';
    final progressData = enrollment['progress'];
    int progress = 0;
    if (progressData is int) progress = progressData;
    else if (progressData is Map) progress = (progressData['percent'] ?? 0).toInt();
    final status = enrollment['status'] ?? 'active';
    final isCompleted = status == 'completed';
    final enrollmentId = enrollment['_id']?.toString();
    final color = _courseColor(index);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LmsCoursePage(
            course: course,
            enrollmentId: enrollmentId,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail / color bar
            Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 22),
                  ),
                  const Spacer(),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Completed',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('$progress%',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(category,
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700, color: color)),
                    ),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_rounded, size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(instructor,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isCompleted ? const Color(0xFF10B981) : color,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('$progress%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isCompleted ? const Color(0xFF10B981) : color,
                          )),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LmsCoursePage(
                            course: course,
                            enrollmentId: enrollmentId,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Text(
                        isCompleted ? 'View Course' : 'Continue',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 2: ASSIGNMENTS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildAssignmentsTab() {
    if (_loadingAssignments) {
      return const Center(child: CircularProgressIndicator());
    }

    final assignments = _filteredAssignments;

    if (assignments.isEmpty && _enrollments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.assignment_outlined,
        title: 'No Assignments',
        subtitle: 'Enroll in courses to see your assignments here.',
        buttonLabel: 'Browse Courses',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const LmsPublicCatalog())),
      );
    }

    if (assignments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.assignment_turned_in_outlined,
        title: 'No Assignments Found',
        subtitle: 'Your enrolled courses have no assignments yet.',
      );
    }

    // Sort: pending first, then late, then submitted
    final sorted = List<Map<String, dynamic>>.from(assignments);
    sorted.sort((a, b) {
      final statusOrder = {'late': 0, 'pending': 1, 'submitted': 2};
      final aStatus = _assignmentStatus(a);
      final bStatus = _assignmentStatus(b);
      return (statusOrder[aStatus] ?? 1).compareTo(statusOrder[bStatus] ?? 1);
    });

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sorted.length,
        itemBuilder: (context, index) => _buildAssignmentCard(sorted[index]),
      ),
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    final title = assignment['title'] ?? 'Assignment';
    final courseName = assignment['_courseName'] ?? '';
    final courseId = assignment['_courseId'] ?? '';
    final enrollmentId = assignment['_enrollmentId'] ?? '';
    final dueDateStr = assignment['dueDate']?.toString() ?? '';
    final status = _assignmentStatus(assignment);
    final totalMarks = assignment['totalMarks']?.toString() ?? '';

    String dueDateLabel = '';
    if (dueDateStr.isNotEmpty) {
      try {
        final due = DateTime.parse(dueDateStr);
        dueDateLabel = 'Due ${DateFormat('MMM dd, yyyy').format(due)}';
      } catch (_) {}
    }

    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    switch (status) {
      case 'submitted':
        statusColor = const Color(0xFF10B981);
        statusLabel = 'Submitted';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'late':
        statusColor = const Color(0xFFEF4444);
        statusLabel = 'Late';
        statusIcon = Icons.warning_rounded;
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusLabel = 'Pending';
        statusIcon = Icons.pending_actions_rounded;
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AssignmentSubmitScreen(
            assignment: assignment,
            courseId: courseId,
            enrollmentId: enrollmentId.isNotEmpty ? enrollmentId : null,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: status == 'late'
                ? const Color(0xFFEF4444).withOpacity(0.3)
                : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.assignment_rounded, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      if (courseName.isNotEmpty)
                        Text(courseName,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(statusLabel,
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
                    ],
                  ),
                ),
              ],
            ),
            if (dueDateLabel.isNotEmpty || totalMarks.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  if (dueDateLabel.isNotEmpty) ...[
                    const Icon(Icons.calendar_today_rounded, size: 13, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(dueDateLabel,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                  const Spacer(),
                  if (totalMarks.isNotEmpty)
                    Text('$totalMarks marks',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: status == 'submitted'
                      ? const Color(0xFFECFDF5)
                      : AppColors.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      status == 'submitted' ? Icons.visibility_rounded : Icons.upload_file_rounded,
                      size: 14,
                      color: status == 'submitted'
                          ? const Color(0xFF10B981)
                          : AppColors.primaryColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      status == 'submitted' ? 'View Submission' : 'Submit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: status == 'submitted'
                            ? const Color(0xFF10B981)
                            : AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 3: QUIZZES
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildQuizzesTab() {
    if (_loadingQuizzes) {
      return const Center(child: CircularProgressIndicator());
    }

    final quizzes = _filteredQuizzes;

    if (quizzes.isEmpty && _enrollments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.quiz_outlined,
        title: 'No Quizzes',
        subtitle: 'Enroll in courses to see your quizzes here.',
        buttonLabel: 'Browse Courses',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const LmsPublicCatalog())),
      );
    }

    if (quizzes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.quiz_outlined,
        title: 'No Quizzes Found',
        subtitle: 'Your enrolled courses have no quizzes yet.',
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: quizzes.length,
        itemBuilder: (context, index) => _buildQuizCard(quizzes[index]),
      ),
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quiz) {
    final title = quiz['title'] ?? 'Quiz';
    final courseName = quiz['_courseName'] ?? '';
    final enrollmentId = quiz['_enrollmentId'] ?? '';
    final timeLimit = quiz['timeLimit']?.toString() ?? '';
    final questionsCount = (quiz['questions'] as List?)?.length ?? quiz['questionCount'] ?? 0;
    final attempts = (quiz['attempts'] as List?) ?? [];
    final latestAttempt = attempts.isNotEmpty ? attempts.last : null;
    final score = latestAttempt?['score'];
    final passed = latestAttempt?['passed'] == true;
    final hasAttempted = latestAttempt != null;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizTakeScreen(
            quiz: quiz,
            enrollmentId: enrollmentId,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.quiz_rounded, color: Color(0xFF6366F1), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      if (courseName.isNotEmpty)
                        Text(courseName,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                if (hasAttempted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: passed
                          ? const Color(0xFF10B981).withOpacity(0.1)
                          : const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      passed ? 'Passed' : 'Failed',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: passed ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (questionsCount > 0) ...[
                  const Icon(Icons.help_outline_rounded, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text('$questionsCount questions',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(width: 14),
                ],
                if (timeLimit.isNotEmpty) ...[
                  const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text('$timeLimit min',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
                if (score != null) ...[
                  const Spacer(),
                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 3),
                  Text('Score: $score',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                ],
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizTakeScreen(
                      quiz: quiz,
                      enrollmentId: enrollmentId,
                    ),
                  ),
                ),
                icon: Icon(
                  hasAttempted ? Icons.replay_rounded : Icons.play_arrow_rounded,
                  size: 18,
                ),
                label: Text(hasAttempted ? 'Retake Quiz' : 'Start Quiz'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6366F1),
                  side: const BorderSide(color: Color(0xFF6366F1)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 4: LIVE SESSIONS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildLiveSessionsTab() {
    if (_loadingSessions) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_liveSessions.isEmpty && _pastSessions.isEmpty) {
      return _buildEmptyState(
        icon: Icons.videocam_outlined,
        title: 'No Live Sessions',
        subtitle: 'No upcoming live sessions scheduled yet.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLiveSessions,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_liveSessions.isNotEmpty) ...[
            _sectionHeader('Upcoming Sessions', Icons.event_available_rounded,
                const Color(0xFF10B981)),
            const SizedBox(height: 10),
            ..._liveSessions.map((s) => _buildSessionCard(s, upcoming: true)),
            const SizedBox(height: 16),
          ],
          if (_pastSessions.isNotEmpty) ...[
            _sectionHeader('Past Sessions', Icons.history_rounded, const Color(0xFF64748B)),
            const SizedBox(height: 10),
            ..._pastSessions.map((s) => _buildSessionCard(s, upcoming: false)),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
      ],
    );
  }

  Widget _buildSessionCard(dynamic session, {required bool upcoming}) {
    final title = session['title'] ?? 'Live Session';
    final courseName = (session['course'] as Map?)?['title'] ??
        (session['course'] as Map?)?['name'] ??
        session['courseName'] ??
        '';
    final dateStr = session['scheduledAt'] ?? session['date'] ?? session['startTime'] ?? '';
    String dateLabel = '';
    if (dateStr.isNotEmpty) {
      try {
        final date = DateTime.parse(dateStr.toString());
        dateLabel = DateFormat('EEE, MMM dd • hh:mm a').format(date);
      } catch (_) {}
    }
    final meetingLink = session['meetingLink'] ?? session['joinUrl'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: upcoming
              ? const Color(0xFF10B981).withOpacity(0.3)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: upcoming
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFF64748B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  upcoming ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                  color: upcoming ? const Color(0xFF10B981) : const Color(0xFF64748B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    if (courseName.isNotEmpty)
                      Text(courseName,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              if (!upcoming)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Past',
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                ),
            ],
          ),
          if (dateLabel.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 5),
                Text(dateLabel,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ],
          if (upcoming && meetingLink.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _joinSession(session),
                icon: const Icon(Icons.video_call_rounded, size: 18),
                label: const Text('Join Session',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ] else if (upcoming) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _joinSession(session),
                icon: const Icon(Icons.video_call_rounded, size: 18),
                label: const Text('Join Session',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _joinSession(dynamic session) async {
    final sessionId = session['_id']?.toString() ?? '';
    if (sessionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot join session')),
      );
      return;
    }
    try {
      final result = await _lmsService.joinSession(sessionId);
      final link = result['joinUrl'] ?? result['meetingLink'] ?? session['meetingLink'] ?? '';
      if (mounted) {
        if (link.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Join link: $link')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Joined session successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join: ${e.toString()}')),
        );
      }
    }
  }

  // ── EMPTY STATE ──────────────────────────────────────────────────────────

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? buttonLabel,
    VoidCallback? onTap,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: const Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.5)),
            if (buttonLabel != null && onTap != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.explore_rounded, size: 18),
                label: Text(buttonLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
