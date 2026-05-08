import 'package:flutter/material.dart';
import 'package:icare/screens/classroom_course_view.dart';
import 'package:icare/screens/instructor_lms_create_course.dart';
import 'package:icare/services/lms_service.dart';
import 'package:icare/utils/shared_pref.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────────────────────
// iCare Classroom — Instructor Shell
// Exact Google Classroom layout: persistent sidebar + content area
// ─────────────────────────────────────────────────────────────

class InstructorLmsDashboard extends StatefulWidget {
  const InstructorLmsDashboard({super.key});

  @override
  State<InstructorLmsDashboard> createState() => _InstructorLmsDashboardState();
}

class _InstructorLmsDashboardState extends State<InstructorLmsDashboard> {
  final LmsService _lms = LmsService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  List<dynamic> _courses = [];
  bool _isLoading = true;
  String _userName = '';
  String _userEmail = '';
  _NavPage _activePage = _NavPage.home;
  bool _enrolledExpanded = true;

  static const List<Color> _cardColors = [
    Color(0xFF1A73E8), // Google blue
    Color(0xFF188038), // Google green
    Color(0xFF9334E6), // Purple
    Color(0xFFE37400), // Orange
    Color(0xFF1E7E34), // Dark green
    Color(0xFFB3261E), // Red
    Color(0xFF006064), // Teal
    Color(0xFF4527A0), // Deep purple
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadCourses();
  }

  Future<void> _loadUser() async {
    final user = await SharedPref().getUserData();
    if (mounted && user != null) {
      setState(() {
        _userName = user.name.isNotEmpty ? user.name : user.email.split('@').first;
        _userEmail = user.email;
      });
    }
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    try {
      final res = await _lms.getInstructorCourses();
      if (mounted) {
        setState(() {
          _courses = (res['courses'] ?? []) as List;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _cardColor(int i) => _cardColors[i % _cardColors.length];

  String _courseInitial(dynamic course) {
    final t = (course['title'] ?? course['name'] ?? '?').toString();
    return t.isNotEmpty ? t[0].toUpperCase() : '?';
  }

  void _openCourse(dynamic course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClassroomCourseView(
          course: Map<String, dynamic>.from(course is Map ? course : {}),
          isInstructor: true,
        ),
      ),
    ).then((_) => _loadCourses());
  }

  void _createClass() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InstructorLmsCreateCourseScreen()),
    ).then((_) => _loadCourses());
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 840;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: isWide ? null : _buildSidebar(isDrawer: true),
      body: Row(
        children: [
          // ── Permanent sidebar on wide screens ──
          if (isWide) _buildSidebar(isDrawer: false),
          // ── Main content ──
          Expanded(
            child: Column(
              children: [
                _buildTopBar(isWide),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════
  // TOP BAR
  // ════════════════════════════════════════════════

  Widget _buildTopBar(bool isWide) {
    String title;
    switch (_activePage) {
      case _NavPage.home:
        title = 'Classroom';
        break;
      case _NavPage.calendar:
        title = 'Calendar';
        break;
      case _NavPage.todo:
        title = 'To do';
        break;
      case _NavPage.settings:
        title = 'Settings';
        break;
    }

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (!isWide)
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: Color(0xFF444746)),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          if (!isWide) const SizedBox(width: 4),
          // Logo chip
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            'iCare $title',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: Color(0xFF202124),
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          // Search
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF444746), size: 22),
            onPressed: () {},
          ),
          // Apps grid (like GC)
          IconButton(
            icon: const Icon(Icons.apps_rounded, color: Color(0xFF444746), size: 22),
            onPressed: () {},
          ),
          // Create class FAB in top bar
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 8),
            child: Tooltip(
              message: 'Create or join class',
              child: InkWell(
                onTap: _createClass,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  ),
                  child: const Icon(Icons.add_rounded, size: 20, color: Color(0xFF444746)),
                ),
              ),
            ),
          ),
          // Avatar
          GestureDetector(
            onTap: () => setState(() => _activePage = _NavPage.settings),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF1A73E8),
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'I',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════
  // LEFT SIDEBAR
  // ════════════════════════════════════════════════

  Widget _buildSidebar({required bool isDrawer}) {
    final content = Container(
      width: 256,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDrawer) ...[
            const SizedBox(height: 16),
            // Logo row in drawer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A73E8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.school_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'iCare Classroom',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF202124),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Nav items
          _navItem(Icons.home_rounded, 'Home', _NavPage.home),
          _navItem(Icons.calendar_today_rounded, 'Calendar', _NavPage.calendar),
          _navItem(Icons.check_circle_outline_rounded, 'To do', _NavPage.todo),
          const SizedBox(height: 4),
          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Divider(color: Colors.grey.shade200, height: 1),
          ),
          // Taught (instructor's courses)
          InkWell(
            onTap: () =>
                setState(() => _enrolledExpanded = !_enrolledExpanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Taught',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF444746),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _enrolledExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 18,
                    color: const Color(0xFF444746),
                  ),
                ],
              ),
            ),
          ),
          if (_enrolledExpanded)
            ..._courses.asMap().entries.map((e) {
              final i = e.key;
              final course = e.value;
              final initial = _courseInitial(course);
              final color = _cardColor(i);
              final title = (course['title'] ?? course['name'] ?? 'Course').toString();
              return InkWell(
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  _openCourse(course);
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: color,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF202124),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Divider(color: Colors.grey.shade200, height: 1),
          ),
          _navItem(Icons.archive_outlined, 'Archived classes', null),
          _navItem(Icons.settings_outlined, 'Settings', _NavPage.settings),
          const Spacer(),
        ],
      ),
    );

    if (isDrawer) {
      return Drawer(
        width: 256,
        elevation: 4,
        child: SafeArea(child: content),
      );
    }
    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: content,
    );
  }

  Widget _navItem(IconData icon, String label, _NavPage? page) {
    final isActive = page != null && _activePage == page;
    return InkWell(
      onTap: page != null ? () => setState(() => _activePage = page) : null,
      borderRadius: BorderRadius.circular(0),
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF1A73E8).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        margin: const EdgeInsets.only(right: 16, top: 1, bottom: 1),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive
                  ? const Color(0xFF1A73E8)
                  : const Color(0xFF444746),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? const Color(0xFF1A73E8)
                    : const Color(0xFF202124),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════
  // BODY ROUTER
  // ════════════════════════════════════════════════

  Widget _buildBody() {
    switch (_activePage) {
      case _NavPage.home:
        return _buildHomePage();
      case _NavPage.calendar:
        return _CalendarPage(courses: _courses);
      case _NavPage.todo:
        return _TodoPage(courses: _courses);
      case _NavPage.settings:
        return _SettingsPage(userName: _userName, userEmail: _userEmail);
    }
  }

  // ════════════════════════════════════════════════
  // HOME PAGE — Course card grid
  // ════════════════════════════════════════════════

  Widget _buildHomePage() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    final isWide = MediaQuery.of(context).size.width > 840;
    final crossCount = isWide
        ? (MediaQuery.of(context).size.width > 1200 ? 4 : 3)
        : (MediaQuery.of(context).size.width > 560 ? 2 : 1);

    return RefreshIndicator(
      onRefresh: _loadCourses,
      child: _courses.isEmpty
          ? _buildEmptyHome()
          : GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.35,
              ),
              itemCount: _courses.length,
              itemBuilder: (ctx, i) => _buildCourseCard(_courses[i], i),
            ),
    );
  }

  Widget _buildCourseCard(dynamic course, int index) {
    final color = _cardColor(index);
    final title = (course['title'] ?? course['name'] ?? 'Untitled').toString();
    final section = (course['category'] ?? course['section'] ?? '').toString();
    final instructor = _userName.isNotEmpty ? _userName : 'Instructor';
    final enrolledCount = ((course['enrolledCount'] ?? 0) as num).toInt();

    return GestureDetector(
      onTap: () => _openCourse(course),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDADCE0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Colored header ───────────────────────────
            Expanded(
              flex: 6,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background with subtle pattern
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Diagonal pattern overlay
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                            child: CustomPaint(
                              painter: _DiagonalPatternPainter(
                                  color.withValues(alpha: 0.15)),
                            ),
                          ),
                        ),
                        // Course name + section
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 60, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (section.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  section,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                instructor,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Instructor avatar — overlaps bottom-right of header
                  Positioned(
                    right: 12,
                    bottom: -20,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: _avatarColor(index),
                      child: Text(
                        instructor.isNotEmpty ? instructor[0].toUpperCase() : 'I',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── White bottom section ──────────────────────
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 4, 4, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Spacer(),
                    // Students icon button
                    _cardIconButton(
                      Icons.people_outlined,
                      '$enrolledCount',
                      () => _openCourse(course),
                    ),
                    // Folder icon button
                    _cardIconButton(
                      Icons.folder_outlined,
                      null,
                      () {
                        final id = course['_id']?.toString() ?? '';
                        if (id.isNotEmpty) {
                          context.go('/instructor/lms/course/$id/content');
                        }
                      },
                    ),
                    // Three-dots menu
                    _cardMoreButton(course),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _avatarColor(int index) {
    const avatarColors = [
      Color(0xFF1558D6),
      Color(0xFF137333),
      Color(0xFF7B1FA2),
      Color(0xFFBF360C),
      Color(0xFF00695C),
      Color(0xFF880E4F),
      Color(0xFF004D40),
      Color(0xFF311B92),
    ];
    return avatarColors[index % avatarColors.length];
  }

  Widget _cardIconButton(IconData icon, String? badge, VoidCallback onTap) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(icon, size: 20, color: const Color(0xFF444746)),
          onPressed: onTap,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
        if (badge != null && badge != '0')
          Positioned(
            top: 4,
            right: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF1A73E8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _cardMoreButton(dynamic course) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded,
          size: 20, color: Color(0xFF444746)),
      iconSize: 20,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'move',
          child: _PopupItem(Icons.drive_file_move_outlined, 'Move'),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: _PopupItem(Icons.edit_outlined, 'Edit'),
        ),
        const PopupMenuItem(
          value: 'copy_link',
          child: _PopupItem(Icons.link_rounded, 'Copy link'),
        ),
        const PopupMenuItem(
          value: 'archive',
          child: _PopupItem(Icons.archive_outlined, 'Archive'),
        ),
      ],
      onSelected: (val) {
        if (val == 'edit') {
          final id = course['_id']?.toString() ?? '';
          if (id.isNotEmpty) {
            context.go('/instructor/lms/course/$id/content');
          }
        }
      },
    );
  }

  Widget _buildEmptyHome() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.class_outlined,
                size: 56, color: Color(0xFF1A73E8)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Add a class to get started',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: Color(0xFF202124),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tap the + button to create your first class.',
            style: TextStyle(fontSize: 14, color: Color(0xFF5F6368)),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _createClass,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Create class'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A73E8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              elevation: 0,
              textStyle: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Custom painter: subtle diagonal pattern for card header
// ─────────────────────────────────────────────────────────────

class _DiagonalPatternPainter extends CustomPainter {
  final Color color;
  _DiagonalPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const gap = 18.0;
    for (double i = -size.height; i < size.width + size.height; i += gap) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DiagonalPatternPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────
// Navigation page enum
// ─────────────────────────────────────────────────────────────

enum _NavPage { home, calendar, todo, settings }

// ─────────────────────────────────────────────────────────────
// CALENDAR PAGE
// ─────────────────────────────────────────────────────────────

class _CalendarPage extends StatefulWidget {
  final List<dynamic> courses;
  const _CalendarPage({required this.courses});

  @override
  State<_CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<_CalendarPage> {
  DateTime _weekStart = _mondayOf(DateTime.now());

  static DateTime _mondayOf(DateTime d) {
    final diff = d.weekday - 1;
    return DateTime(d.year, d.month, d.day - diff);
  }

  void _prevWeek() =>
      setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));
  void _nextWeek() =>
      setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));

  String _formatRange() {
    final end = _weekStart.add(const Duration(days: 6));
    if (_weekStart.month == end.month) {
      return '${DateFormat('MMM d').format(_weekStart)} - ${DateFormat('d, yyyy').format(end)}';
    }
    return '${DateFormat('MMM d').format(_weekStart)} - ${DateFormat('MMM d, yyyy').format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (i) => _weekStart.add(Duration(days: i)));
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        // Header bar
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Row(
            children: [
              // Course filter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFDADCE0)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('All classes',
                        style: TextStyle(
                            fontSize: 14, color: Color(0xFF202124))),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_drop_down_rounded,
                        size: 20, color: Color(0xFF444746)),
                  ],
                ),
              ),
              const Spacer(),
              // Week navigation
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded,
                    color: Color(0xFF444746)),
                onPressed: _prevWeek,
              ),
              Text(
                _formatRange(),
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF202124)),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF444746)),
                onPressed: _nextWeek,
              ),
            ],
          ),
        ),
        // Calendar grid header
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey.shade200),
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Row(
            children: List.generate(7, (i) {
              final day = days[i];
              final isToday = day.day == today.day &&
                  day.month == today.month &&
                  day.year == today.year;
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                          color: i < 6
                              ? Colors.grey.shade200
                              : Colors.transparent),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        dayLabels[i],
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF70757A),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isToday
                              ? const Color(0xFF1A73E8)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: isToday
                                  ? Colors.white
                                  : const Color(0xFF202124),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        // Calendar body (empty — assignments would appear here)
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(7, (i) {
              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                          color: i < 6
                              ? Colors.grey.shade100
                              : Colors.transparent),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TO-DO PAGE
// ─────────────────────────────────────────────────────────────

class _TodoPage extends StatefulWidget {
  final List<dynamic> courses;
  const _TodoPage({required this.courses});

  @override
  State<_TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<_TodoPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final LmsService _lms = LmsService();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _loadItems();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() => _loading = true);
    final all = <Map<String, dynamic>>[];
    for (final course in widget.courses) {
      final id = course['_id']?.toString() ?? '';
      final name = (course['title'] ?? course['name'] ?? '').toString();
      if (id.isEmpty) continue;
      try {
        final a = await _lms.getCourseAssignments(id);
        for (final item in a) {
          all.add({
            ...Map<String, dynamic>.from(item is Map ? item : {}),
            '_type': 'assignment',
            '_courseName': name,
          });
        }
      } catch (_) {}
    }
    all.sort((a, b) {
      final aDate = _parseDate(a['dueDate']?.toString() ?? '');
      final bDate = _parseDate(b['dueDate']?.toString() ?? '');
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return aDate.compareTo(bDate);
    });
    if (mounted) setState(() { _items = all; _loading = false; });
  }

  DateTime? _parseDate(String s) {
    if (s.isEmpty) return null;
    try { return DateTime.parse(s); } catch (_) { return null; }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab row
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              TabBar(
                controller: _tabs,
                isScrollable: true,
                labelColor: const Color(0xFF1A73E8),
                unselectedLabelColor: const Color(0xFF444746),
                indicatorColor: const Color(0xFF1A73E8),
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500),
                unselectedLabelStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                tabs: const [
                  Tab(text: 'Assigned'),
                  Tab(text: 'Missing'),
                  Tab(text: 'Done'),
                ],
              ),
            ],
          ),
        ),
        // Filter row
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFDADCE0)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('All classes',
                      style: TextStyle(
                          fontSize: 14, color: Color(0xFF202124))),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_drop_down_rounded,
                      size: 20, color: Color(0xFF444746)),
                ],
              ),
            ),
          ),
        ),
        // Content
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : TabBarView(
                  controller: _tabs,
                  children: [
                    _buildItemList(_items
                        .where((i) => i['mySubmission'] == null)
                        .toList()),
                    _buildItemList(_items
                        .where((i) {
                          if (i['mySubmission'] != null) return false;
                          final d = _parseDate(i['dueDate']?.toString() ?? '');
                          return d != null && d.isBefore(DateTime.now());
                        }).toList()),
                    _buildItemList(_items
                        .where((i) => i['mySubmission'] != null)
                        .toList()),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildItemList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Nothing here — you are all caught up!',
                style:
                    TextStyle(fontSize: 14, color: Color(0xFF5F6368))),
          ],
        ),
      );
    }

    // Group by timeframe
    final now = DateTime.now();
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final item in items) {
      final d = _parseDate(item['dueDate']?.toString() ?? '');
      String group;
      if (d == null) {
        group = 'No due date';
      } else {
        final diff = d.difference(DateTime(now.year, now.month, now.day)).inDays;
        if (diff < 0) {
          group = 'Past due';
        } else if (diff <= 7) {
          group = 'This week';
        } else if (diff <= 14) {
          group = 'Next week';
        } else {
          group = 'Later';
        }
      }
      groups.putIfAbsent(group, () => []).add(item);
    }

    const order = ['Past due', 'No due date', 'This week', 'Next week', 'Later'];

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      children: [
        for (final key in order)
          if (groups.containsKey(key)) ...[
            _TodoSection(
                title: key,
                count: groups[key]!.length,
                items: groups[key]!),
            const SizedBox(height: 4),
          ],
      ],
    );
  }
}

class _TodoSection extends StatefulWidget {
  final String title;
  final int count;
  final List<Map<String, dynamic>> items;
  const _TodoSection(
      {required this.title, required this.count, required this.items});

  @override
  State<_TodoSection> createState() => _TodoSectionState();
}

class _TodoSectionState extends State<_TodoSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF202124),
                    ),
                  ),
                ),
                Text(
                  '${widget.count}',
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF70757A)),
                ),
                const SizedBox(width: 8),
                Icon(
                  _expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  size: 20,
                  color: const Color(0xFF70757A),
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          ...widget.items.map((item) => _TodoItem(item: item)),
      ],
    );
  }
}

class _TodoItem extends StatelessWidget {
  final Map<String, dynamic> item;
  const _TodoItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final title = item['title']?.toString() ?? 'Assignment';
    final courseName = item['_courseName']?.toString() ?? '';
    final postedDate = item['createdAt']?.toString() ?? '';
    String dateLabel = '';
    if (postedDate.isNotEmpty) {
      try {
        dateLabel = 'Posted ${DateFormat('EEEE, d MMMM yyyy').format(DateTime.parse(postedDate))}';
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Assignment icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.assignment_outlined,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF202124)),
                ),
                Text(
                  '$courseName${dateLabel.isNotEmpty ? '  •  $dateLabel' : ''}',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF70757A)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded,
                size: 18, color: Color(0xFF70757A)),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SETTINGS PAGE
// ─────────────────────────────────────────────────────────────

class _SettingsPage extends StatelessWidget {
  final String userName;
  final String userEmail;
  const _SettingsPage({required this.userName, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const Text(
          'Profile',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: Color(0xFF202124)),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: const Color(0xFF1A73E8),
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'I',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w400),
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF202124))),
                Text(userEmail,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF5F6368))),
                const SizedBox(height: 6),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFDADCE0)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Manage account',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFF1A73E8))),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        Divider(color: Colors.grey.shade200),
        const SizedBox(height: 20),
        const Text(
          'Notifications',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: Color(0xFF202124)),
        ),
        const SizedBox(height: 16),
        _settingRow('Allow email notifications',
            'Receive notifications about your classes'),
        const SizedBox(height: 12),
        _settingRow('Comments', 'Comments on your posts'),
        const SizedBox(height: 12),
        _settingRow(
            'Work notifications', 'New assignments and grades'),
      ],
    );
  }

  Widget _settingRow(String title, String subtitle) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF202124))),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF5F6368))),
            ],
          ),
        ),
        Switch(
          value: true,
          activeThumbColor: const Color(0xFF1A73E8),
          onChanged: (_) {},
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Helper widget
// ─────────────────────────────────────────────────────────────

class _PopupItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PopupItem(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF444746)),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(
                fontSize: 14, color: Color(0xFF202124))),
      ],
    );
  }
}
