import 'package:flutter/material.dart';
import 'package:icare/screens/instructor_assign_course_screen.dart';
import 'package:icare/screens/instructor_courses_management.dart';
import 'package:icare/screens/instructor_learners_screen.dart';
import 'package:icare/screens/instructor_precautions_management.dart';
import 'package:icare/screens/instructor_analytics.dart';
import 'package:icare/screens/instructor_qa_center_screen.dart';
import 'package:icare/screens/instructor_earnings_screen.dart';
import 'package:icare/screens/instructor_profile_setup.dart';
import 'package:icare/services/instructor_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/instructor_sidebar.dart';

class InstructorDashboardScreen extends StatefulWidget {
  const InstructorDashboardScreen({super.key});

  @override
  State<InstructorDashboardScreen> createState() =>
      _InstructorDashboardScreenState();
}

class _InstructorDashboardScreenState extends State<InstructorDashboardScreen> {
  final InstructorService _instructorService = InstructorService();
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _instructorService.getStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
          'Program Manager Dashboard',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFF0F172A)),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const InstructorProfileSetupScreen(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const InstructorSidebar(currentRoute: 'dashboard'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(isDesktop ? 32 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats — horizontal row of compact cards
                    if (isDesktop)
                      Row(
                        children: [
                          _buildStatCard('Total Programs', '${_stats['totalCourses'] ?? 0}', Icons.menu_book_rounded, const Color(0xFF6366F1)),
                          const SizedBox(width: 16),
                          _buildStatCard('Active Patients', '${_stats['totalStudents'] ?? 0}', Icons.group_rounded, const Color(0xFF10B981)),
                          const SizedBox(width: 16),
                          _buildStatCard('Avg. Rating', '${_stats['avgRating'] ?? 0}★', Icons.star_rounded, const Color(0xFFF59E0B)),
                          const SizedBox(width: 16),
                          _buildStatCard('Health Tips', '${_stats['totalPrecautions'] ?? 0}', Icons.health_and_safety_rounded, const Color(0xFF3B82F6)),
                        ],
                      )
                    else
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.8,
                        children: [
                          _buildStatCard('Total Programs', '${_stats['totalCourses'] ?? 0}', Icons.menu_book_rounded, const Color(0xFF6366F1)),
                          _buildStatCard('Active Patients', '${_stats['totalStudents'] ?? 0}', Icons.group_rounded, const Color(0xFF10B981)),
                          _buildStatCard('Avg. Rating', '${_stats['avgRating'] ?? 0}★', Icons.star_rounded, const Color(0xFFF59E0B)),
                          _buildStatCard('Health Tips', '${_stats['totalPrecautions'] ?? 0}', Icons.health_and_safety_rounded, const Color(0xFF3B82F6)),
                        ],
                      ),

                    const SizedBox(height: 28),

                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (isDesktop)
                      // Desktop: 2-column grid for action cards
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 4.0,
                        children: [
                          _buildActionCard('Manage Health Programs', 'Create, edit, and manage your health programs', Icons.health_and_safety_rounded, const Color(0xFF6366F1), () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InstructorCoursesManagementScreen()))),
                          _buildActionCard('Assign Programs', 'Assign development to doctors or patients', Icons.assignment_ind_rounded, const Color(0xFF8B5CF6), () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InstructorAssignCourseScreen()))),
                          _buildActionCard('Assigned Learners', 'Monitor patient and doctor progress', Icons.group_rounded, const Color(0xFF3B82F6), () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InstructorLearnersScreen()))),
                          _buildActionCard('Educational Analytics', 'Track completions and engagement', Icons.analytics_rounded, const Color(0xFFF59E0B), () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InstructorAnalytics()))),
                          _buildActionCard('Health Tips & Precautions', 'Share health tips with your patients', Icons.tips_and_updates_rounded, const Color(0xFF10B981), () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InstructorPrecautionsManagementScreen()))),
                          _buildActionCard('Profile Settings', 'Update your profile and availability', Icons.settings_rounded, const Color(0xFF64748B), () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InstructorProfileSetupScreen()))),
                        ],
                      )
                    else ...[
                      _buildActionCard('Manage Health Programs', 'Create, edit, and manage your health programs', Icons.health_and_safety_rounded, const Color(0xFF6366F1), () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InstructorCoursesManagementScreen()))),
                      const SizedBox(height: 10),
                      _buildActionCard('Assign Programs', 'Assign professional development to doctors or patients', Icons.assignment_ind_rounded, const Color(0xFF8B5CF6), () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InstructorAssignCourseScreen()))),
                      const SizedBox(height: 10),
                      _buildActionCard('Assigned Learners', 'Monitor patient and doctor progress', Icons.group_rounded, const Color(0xFF3B82F6), () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InstructorLearnersScreen()))),
                      const SizedBox(height: 10),
                      _buildActionCard('Educational Analytics', 'Track completions and learner engagement', Icons.analytics_rounded, const Color(0xFFF59E0B), () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InstructorAnalytics()))),
                      const SizedBox(height: 10),
                      _buildActionCard('Health Tips & Precautions', 'Share health tips with your patients', Icons.tips_and_updates_rounded, const Color(0xFF10B981), () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InstructorPrecautionsManagementScreen()))),
                      const SizedBox(height: 10),
                      _buildActionCard('Profile Settings', 'Update your profile and availability', Icons.settings_rounded, const Color(0xFF64748B), () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InstructorProfileSetupScreen()))),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final card = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: isDesktop ? 26 : 20,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return isDesktop ? Expanded(child: card) : card;
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
