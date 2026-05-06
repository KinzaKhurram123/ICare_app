import 'package:flutter/material.dart';
import 'package:icare/screens/lms_course_page.dart';
import 'package:icare/services/instructor_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/instructor_sidebar.dart';

class InstructorLmsScreen extends StatefulWidget {
  const InstructorLmsScreen({super.key});

  @override
  State<InstructorLmsScreen> createState() => _InstructorLmsScreenState();
}

class _InstructorLmsScreenState extends State<InstructorLmsScreen> {
  final InstructorService _service = InstructorService();
  List<dynamic> _courses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final courses = await _service.getMyCourses();
      if (mounted) setState(() { _courses = courses; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? const CustomBackButton()
            : Builder(builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: Color(0xFF0F172A)),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              )),
        title: const Text('LMS Classroom',
            style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
      ),
      drawer: const InstructorSidebar(currentRoute: 'lms'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _courses.length,
                    itemBuilder: (ctx, i) => _CourseCard(
                      course: _courses[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LmsCoursePage(
                          course: Map<String, dynamic>.from(_courses[i]),
                          isInstructor: true,
                        )),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.school_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 16),
        const Text('No courses yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
        const SizedBox(height: 8),
        const Text('Create a course from "Manage Health Programs"',
            style: TextStyle(color: Color(0xFF94A3B8))),
      ]),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final dynamic course;
  final VoidCallback onTap;
  const _CourseCard({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final modules = (course['modules'] as List?) ?? [];
    final lessonCount = modules.fold<int>(0, (s, m) => s + ((m['lessons'] as List?) ?? []).length);
    final isPublished = course['visibility'] == 'public';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header banner
            Container(
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.7)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.school_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(course['category'] ?? 'Healthcare',
                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPublished ? const Color(0xFF10B981) : Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(isPublished ? 'Published' : 'Draft',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 8),
                Text(course['title'] ?? 'Untitled',
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ]),
            ),

            // Stats row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                _Stat(icon: Icons.library_books_rounded, label: '${modules.length} modules', color: const Color(0xFF6366F1)),
                const SizedBox(width: 16),
                _Stat(icon: Icons.play_circle_rounded, label: '$lessonCount lessons', color: const Color(0xFF3B82F6)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text('Open'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Stat({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    ]);
  }
}
