import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icare/screens/assignment_submit_screen.dart';
import 'package:icare/screens/quiz_take_screen.dart';
import 'package:icare/services/lms_service.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Google Classroom-inspired course view.
/// Works for both students and instructors.
class ClassroomCourseView extends StatefulWidget {
  final Map<String, dynamic> course;
  final String? enrollmentId;
  final bool isInstructor;
  final int initialTab;

  const ClassroomCourseView({
    super.key,
    required this.course,
    this.enrollmentId,
    this.isInstructor = false,
    this.initialTab = 0,
  });

  @override
  State<ClassroomCourseView> createState() => _ClassroomCourseViewState();
}

class _ClassroomCourseViewState extends State<ClassroomCourseView>
    with TickerProviderStateMixin {
  late TabController _tabs;
  final LmsService _lms = LmsService();

  // Stream data
  List<dynamic> _announcements = [];
  bool _loadingStream = true;
  final TextEditingController _postCtrl = TextEditingController();
  bool _posting = false;

  // Classwork data
  List<dynamic> _assignments = [];
  List<dynamic> _quizzes = [];
  List<dynamic> _sessions = [];
  bool _loadingClasswork = true;

  // People data
  List<dynamic> _students = [];
  bool _loadingPeople = true;

  String get _courseId => widget.course['_id']?.toString() ?? '';
  String get _courseTitle =>
      widget.course['title'] ?? widget.course['name'] ?? 'Course';

  static const Color _headerColor = Color(0xFF1565C0);

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _tabs.addListener(_onTabChange);
    _loadStream();
    _loadClasswork();
    _loadPeople();
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabChange);
    _tabs.dispose();
    _postCtrl.dispose();
    super.dispose();
  }

  void _onTabChange() {
    setState(() {});
  }

  Future<void> _loadStream() async {
    if (_courseId.isEmpty) {
      setState(() => _loadingStream = false);
      return;
    }
    setState(() => _loadingStream = true);
    try {
      final data = await _lms.getCourseAnnouncements(_courseId);
      if (mounted) {
        setState(() {
          _announcements = data;
          _loadingStream = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingStream = false);
    }
  }

  Future<void> _loadClasswork() async {
    if (_courseId.isEmpty) {
      setState(() => _loadingClasswork = false);
      return;
    }
    setState(() => _loadingClasswork = true);
    try {
      final assignments = await _lms.getCourseAssignments(_courseId);
      final quizzes = await _lms.getCourseQuizzes(_courseId);
      final sessions = await _lms.getCourseSessions(_courseId);
      if (mounted) {
        setState(() {
          _assignments = assignments;
          _quizzes = quizzes;
          _sessions = sessions;
          _loadingClasswork = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingClasswork = false);
    }
  }

  Future<void> _loadPeople() async {
    if (_courseId.isEmpty) {
      setState(() => _loadingPeople = false);
      return;
    }
    setState(() => _loadingPeople = true);
    try {
      final result = await _lms.getEnrolledStudents(_courseId);
      if (mounted) {
        setState(() {
          _students = result;
          _loadingPeople = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingPeople = false);
    }
  }

  Future<void> _postAnnouncement() async {
    final text = _postCtrl.text.trim();
    if (text.isEmpty || _courseId.isEmpty) return;
    setState(() => _posting = true);
    try {
      await _lms.postAnnouncement(_courseId, text);
      _postCtrl.clear();
      await _loadStream();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to post: ${e.toString()}'),
              backgroundColor: const Color(0xFFEF4444)),
        );
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: _headerColor,
            leading: const CustomBackButton(color: Colors.white),
            actions: [
              if (widget.isInstructor) ...[
                IconButton(
                  icon: const Icon(Icons.settings_rounded, color: Colors.white),
                  onPressed: () {
                    if (_courseId.isNotEmpty) {
                      context.go('/instructor/lms/course/$_courseId/content');
                    }
                  },
                  tooltip: 'Course Settings',
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                  onPressed: () => _showInstructorMenu(),
                ),
              ],
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Pattern overlay
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 40,
                      bottom: 60,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _courseTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (widget.course['category'] != null) ...[
                                Text(
                                  widget.course['category'].toString(),
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                        color: Colors.white54,
                                        shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                              ],
                              if (_courseId.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(
                                        ClipboardData(text: _courseId));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Class code copied!')),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(Icons.vpn_key_rounded,
                                          color: Colors.white70, size: 13),
                                      const SizedBox(width: 4),
                                      Text(
                                        _courseId.length >= 6
                                            ? _courseId.substring(
                                                _courseId.length - 6)
                                            : _courseId,
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabs,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [
                Tab(text: 'Stream'),
                Tab(text: 'Classwork'),
                Tab(text: 'People'),
                Tab(text: 'Grades'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            _buildStreamTab(),
            _buildClassworkTab(),
            _buildPeopleTab(),
            _buildGradesTab(),
          ],
        ),
      ),
      floatingActionButton: widget.isInstructor && _tabs.index == 1
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateMenu(),
              backgroundColor: _headerColor,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Create',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            )
          : null,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // STREAM TAB
  // ═══════════════════════════════════════════════════════════

  Widget _buildStreamTab() {
    return RefreshIndicator(
      onRefresh: _loadStream,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Post input (instructor only)
          if (widget.isInstructor) ...[
            _buildPostInput(),
            const SizedBox(height: 16),
          ],
          // Classwork summary card (like Google Classroom)
          if (_assignments.isNotEmpty || _quizzes.isNotEmpty)
            _buildClassworkSummaryCard(),
          if (_assignments.isNotEmpty || _quizzes.isNotEmpty)
            const SizedBox(height: 16),
          // Announcements
          if (_loadingStream)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator()))
          else if (_announcements.isEmpty)
            _buildStreamEmpty()
          else
            ..._announcements.map((a) => _buildAnnouncementCard(a)),
        ],
      ),
    );
  }

  Widget _buildPostInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _headerColor.withOpacity(0.1),
                child: const Icon(Icons.person_rounded,
                    color: _headerColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _postCtrl,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Announce something to your class...',
                    hintStyle:
                        TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _postCtrl.clear(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _posting ? null : _postAnnouncement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _headerColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                child: _posting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Post',
                        style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassworkSummaryCard() {
    final total = _assignments.length + _quizzes.length;
    return GestureDetector(
      onTap: () => _tabs.animateTo(1),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _headerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.assignment_rounded, color: _headerColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$total classwork item${total != 1 ? 's' : ''} available',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A)),
                  ),
                  const Text(
                    'Tap to view all assignments and quizzes',
                    style:
                        TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFCBD5E1), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(dynamic announcement) {
    final content =
        announcement['content'] ?? announcement['message'] ?? '';
    final authorName = (announcement['author'] as Map?)?['name'] ??
        (announcement['authorName'] ?? 'Instructor');
    final createdAt = announcement['createdAt']?.toString() ?? '';
    String timeLabel = '';
    if (createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt);
        timeLabel = DateFormat('MMM dd').format(dt);
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _headerColor.withOpacity(0.1),
                  child: Text(
                    authorName.isNotEmpty
                        ? authorName[0].toUpperCase()
                        : 'I',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _headerColor),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(authorName,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A))),
                      if (timeLabel.isNotEmpty)
                        Text(timeLabel,
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
                if (widget.isInstructor)
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded,
                        size: 18, color: Color(0xFF94A3B8)),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Text(
              content,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF374151), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.campaign_outlined,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No announcements yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B)),
            ),
            if (widget.isInstructor)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Post an announcement to your class above.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CLASSWORK TAB
  // ═══════════════════════════════════════════════════════════

  Widget _buildClassworkTab() {
    if (_loadingClasswork) {
      return const Center(child: CircularProgressIndicator());
    }

    final allItems = [
      ..._assignments.map((a) => {'type': 'assignment', 'data': a}),
      ..._quizzes.map((q) => {'type': 'quiz', 'data': q}),
      ..._sessions.map((s) => {'type': 'session', 'data': s}),
    ];

    if (allItems.isEmpty) {
      return _buildClassworkEmpty();
    }

    // Group by topic if available, otherwise show all under one section
    final Map<String, List<Map<String, dynamic>>> topics = {};
    for (final item in allItems) {
      final d = item['data'] as Map?;
      final topic = d?['topic']?.toString() ?? d?['section']?.toString() ?? 'Class Materials';
      topics.putIfAbsent(topic, () => []).add(item);
    }

    return RefreshIndicator(
      onRefresh: _loadClasswork,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.isInstructor) ...[
            _buildInstructorClassworkActions(),
            const SizedBox(height: 16),
          ],
          for (final entry in topics.entries) ...[
            _buildTopicSection(entry.key, entry.value),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildInstructorClassworkActions() {
    return Row(
      children: [
        Expanded(
          child: _actionChip(
            Icons.assignment_add,
            'Assignment',
            () {
              if (_courseId.isNotEmpty) {
                context.go(
                    '/instructor/lms/create-assignment?courseId=$_courseId');
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _actionChip(
            Icons.quiz_rounded,
            'Quiz',
            () {
              if (_courseId.isNotEmpty) {
                context.go(
                    '/instructor/lms/create-quiz?courseId=$_courseId');
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _actionChip(
            Icons.videocam_rounded,
            'Session',
            () {
              if (_courseId.isNotEmpty) {
                context.go(
                    '/instructor/lms/schedule-session?courseId=$_courseId');
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _actionChip(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _headerColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: _headerColor, size: 20),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _headerColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicSection(
      String topic, List<Map<String, dynamic>> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Topic header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                const Icon(Icons.folder_outlined,
                    size: 18, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    topic,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          // Items
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                _buildClassworkItem(item),
                if (i < items.length - 1)
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildClassworkItem(Map<String, dynamic> item) {
    final type = item['type'] as String;
    final data = item['data'] as Map;
    final title = data['title']?.toString() ?? (type == 'assignment' ? 'Assignment' : type == 'quiz' ? 'Quiz' : 'Live Session');
    final dueDateStr = data['dueDate']?.toString() ?? data['scheduledAt']?.toString() ?? '';
    final points = data['totalMarks']?.toString() ?? data['points']?.toString() ?? '';

    String? dueLabel;
    if (dueDateStr.isNotEmpty) {
      try {
        final dt = DateTime.parse(dueDateStr);
        dueLabel = DateFormat('MMM dd').format(dt);
      } catch (_) {}
    }

    IconData icon;
    Color color;
    switch (type) {
      case 'quiz':
        icon = Icons.quiz_rounded;
        color = const Color(0xFF8B5CF6);
        break;
      case 'session':
        icon = Icons.videocam_rounded;
        color = const Color(0xFF10B981);
        break;
      default:
        icon = Icons.assignment_rounded;
        color = const Color(0xFF0EA5E9);
    }

    return InkWell(
      onTap: () => _openClassworkItem(type, data),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (dueLabel != null) ...[
                        Text('Due $dueLabel',
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF94A3B8))),
                        const SizedBox(width: 8),
                        Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                                color: Color(0xFFCBD5E1),
                                shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                      ],
                      if (points.isNotEmpty)
                        Text('$points pts',
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.isInstructor)
              IconButton(
                icon: const Icon(Icons.more_vert_rounded,
                    size: 18, color: Color(0xFF94A3B8)),
                onPressed: () => _showClassworkItemMenu(type, data),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            else
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }

  void _openClassworkItem(String type, Map data) {
    final courseId = _courseId;
    final enrollmentId = widget.enrollmentId;

    if (type == 'assignment') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AssignmentSubmitScreen(
            assignment: Map<String, dynamic>.from(data),
            courseId: courseId,
            enrollmentId: enrollmentId,
          ),
        ),
      );
    } else if (type == 'quiz') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizTakeScreen(
            quiz: Map<String, dynamic>.from(data),
            enrollmentId: enrollmentId ?? '',
          ),
        ),
      );
    }
  }

  void _showClassworkItemMenu(String type, Map data) {
    final id = data['_id']?.toString() ?? '';
    final title = data['title']?.toString() ?? type;

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
            if (type == 'assignment' && id.isNotEmpty)
              _sheetItem(
                Icons.grade_rounded,
                'Grade Submissions',
                _headerColor,
                () {
                  Navigator.pop(context);
                  context.go('/instructor/lms/assignment/$id/grade',
                      extra: {'title': title});
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassworkEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No classwork yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B)),
            ),
            if (widget.isInstructor) ...[
              const SizedBox(height: 8),
              const Text(
                'Create assignments, quizzes, and live sessions for your class.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 20),
              _buildInstructorClassworkActions(),
            ],
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // PEOPLE TAB
  // ═══════════════════════════════════════════════════════════

  Widget _buildPeopleTab() {
    final instructor = widget.course['instructor'] as Map?;
    final instructorName = instructor?['name'] ??
        instructor?['username'] ??
        'iCare Instructor';

    return RefreshIndicator(
      onRefresh: _loadPeople,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Teachers section
          _peopleSectionHeader('Teacher'),
          const SizedBox(height: 8),
          _personTile(
              name: instructorName,
              subtitle: 'Instructor',
              isInstructor: true),
          const SizedBox(height: 20),

          // Students section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _peopleSectionHeader('Students'),
              if (widget.isInstructor)
                TextButton.icon(
                  onPressed: () {
                    if (_courseId.isNotEmpty) {
                      context.go('/instructor/lms/course/$_courseId/students',
                          extra: {'title': _courseTitle});
                    }
                  },
                  icon: const Icon(Icons.people_rounded, size: 16),
                  label: const Text('Manage'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_loadingPeople)
            const Center(child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator()))
          else if (_students.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No students enrolled yet',
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade400),
                ),
              ),
            )
          else
            ..._students.map((s) {
              final name = (s['user'] as Map?)?['name'] ??
                  (s['user'] as Map?)?['username'] ??
                  s['name'] ??
                  'Student';
              final email = (s['user'] as Map?)?['email'] ?? s['email'] ?? '';
              return _personTile(name: name, subtitle: email);
            }),
        ],
      ),
    );
  }

  Widget _peopleSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0F172A),
      ),
    );
  }

  Widget _personTile(
      {required String name, String? subtitle, bool isInstructor = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isInstructor
                ? _headerColor.withOpacity(0.1)
                : const Color(0xFFF1F5F9),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isInstructor
                      ? _headerColor
                      : const Color(0xFF64748B)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                if (subtitle != null && subtitle.isNotEmpty)
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // GRADES TAB
  // ═══════════════════════════════════════════════════════════

  Widget _buildGradesTab() {
    if (widget.isInstructor) {
      return _buildInstructorGrades();
    } else {
      return _buildStudentGrades();
    }
  }

  Widget _buildStudentGrades() {
    if (_loadingClasswork) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_assignments.isEmpty && _quizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grade_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('No grades yet',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B))),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Assignment grades
        if (_assignments.isNotEmpty) ...[
          const Text('Assignments',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          ..._assignments.map((a) => _gradeItem(a, 'assignment')),
          const SizedBox(height: 16),
        ],
        // Quiz grades
        if (_quizzes.isNotEmpty) ...[
          const Text('Quizzes',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          ..._quizzes.map((q) => _gradeItem(q, 'quiz')),
        ],
      ],
    );
  }

  Widget _gradeItem(dynamic item, String type) {
    final title = item['title'] ?? (type == 'quiz' ? 'Quiz' : 'Assignment');
    final submission = item['mySubmission'];
    final attempt = item['myAttempt'] ?? (item['attempts'] as List?)?.lastOrNull;
    final isSubmitted = submission != null || attempt != null;
    final score = submission?['grade'] ?? attempt?['score'];
    final totalMarks = item['totalMarks'] ?? item['points'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: type == 'quiz'
                  ? const Color(0xFF8B5CF6).withOpacity(0.1)
                  : const Color(0xFF0EA5E9).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              type == 'quiz' ? Icons.quiz_rounded : Icons.assignment_rounded,
              size: 16,
              color: type == 'quiz'
                  ? const Color(0xFF8B5CF6)
                  : const Color(0xFF0EA5E9),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A))),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (score != null && totalMarks != null)
                Text('$score / $totalMarks',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF10B981)))
              else if (isSubmitted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Submitted',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981)))
                )
              else
                const Text('Missing',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructorGrades() {
    if (_assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grade_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('No assignments to grade',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _assignments.length,
      itemBuilder: (ctx, i) {
        final a = _assignments[i];
        final title = a['title'] ?? 'Assignment';
        final id = a['_id']?.toString() ?? '';
        final submissionCount =
            (a['submissionCount'] ?? a['submissions']?.length ?? 0) as int;
        final totalMarks = a['totalMarks'] ?? '--';

        return GestureDetector(
          onTap: () {
            if (id.isNotEmpty) {
              context.go('/instructor/lms/assignment/$id/grade',
                  extra: {'title': title});
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.assignment_rounded,
                      color: Color(0xFF0EA5E9), size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A))),
                      Text('$submissionCount submitted  •  $totalMarks pts',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _headerColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Grade',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _headerColor)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════

  void _showCreateMenu() {
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
            _sheetItem(Icons.assignment_rounded, 'Create Assignment',
                _headerColor, () {
              Navigator.pop(context);
              if (_courseId.isNotEmpty) {
                context.go(
                    '/instructor/lms/create-assignment?courseId=$_courseId');
              }
            }),
            _sheetItem(Icons.quiz_rounded, 'Create Quiz', _headerColor, () {
              Navigator.pop(context);
              if (_courseId.isNotEmpty) {
                context
                    .go('/instructor/lms/create-quiz?courseId=$_courseId');
              }
            }),
            _sheetItem(
                Icons.videocam_rounded, 'Schedule Live Session', _headerColor,
                () {
              Navigator.pop(context);
              if (_courseId.isNotEmpty) {
                context.go(
                    '/instructor/lms/schedule-session?courseId=$_courseId');
              }
            }),
          ],
        ),
      ),
    );
  }

  void _showInstructorMenu() {
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
            _sheetItem(Icons.edit_rounded, 'Edit Course', _headerColor, () {
              Navigator.pop(context);
              if (_courseId.isNotEmpty) {
                context.go('/instructor/lms/course/$_courseId/content');
              }
            }),
            _sheetItem(Icons.analytics_rounded, 'View Analytics', _headerColor,
                () {
              Navigator.pop(context);
              if (_courseId.isNotEmpty) {
                context.go('/instructor/lms/course/$_courseId/analytics',
                    extra: {'title': _courseTitle});
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _sheetItem(
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
}
