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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icare/providers/navigation_provider.dart';
import 'package:icare/navigators/drawer.dart';

class InstructorDashboardScreen extends ConsumerStatefulWidget {
  const InstructorDashboardScreen({super.key});

  @override
  ConsumerState<InstructorDashboardScreen> createState() =>
      _InstructorDashboardScreenState();
}

class _InstructorDashboardScreenState extends ConsumerState<InstructorDashboardScreen> {
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                          'Total Programs',
                          '${_stats['totalCourses'] ?? 0}',
                          Icons.menu_book_rounded,
                          const Color(0xFF6366F1),
                        ),
                        _buildStatCard(
                          'Active Patients',
                          '${_stats['totalStudents'] ?? 0}',
                          Icons.group_rounded,
                          const Color(0xFF10B981),
                        ),
                        _buildStatCard(
                          'Avg. Rating',
                          '${_stats['avgRating'] ?? 0}★',
                          Icons.star_rounded,
                          const Color(0xFFF59E0B),
                        ),
                        _buildStatCard(
                          'Health Tips',
                          '${_stats['totalPrecautions'] ?? 0}',
                          Icons.health_and_safety_rounded,
                          const Color(0xFF3B82F6),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildActionCard(
                      'Manage Health Programs',
                      'Create, edit, and manage your health programs',
                      Icons.health_and_safety_rounded,
                      const Color(0xFF6366F1),
                      () {
                        final bool isWeb = MediaQuery.of(context).size.width > 600;
                        if (isWeb) {
                          ref.read(navigationProvider.notifier).setIndex(1);
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) =>
                                  const InstructorCoursesManagementScreen(),
                            ),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildActionCard(
                      'Assign Programs',
                      'Assign professional development to doctors or patients',
                      Icons.assignment_ind_rounded,
                      const Color(0xFF8B5CF6),
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) =>
                                const InstructorAssignCourseScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildActionCard(
                      'Assigned Learners',
                      'Monitor patient and doctor progress',
                      Icons.group_rounded,
                      const Color(0xFF3B82F6),
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const InstructorLearnersScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildActionCard(
                      'Educational Analytics',
                      'Track completions and learner engagement',
                      Icons.analytics_rounded,
                      const Color(0xFFF59E0B),
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const InstructorAnalytics(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildActionCard(
                      'Health Tips & Precautions',
                      'Share health tips with your patients',
                      Icons.tips_and_updates_rounded,
                      const Color(0xFF10B981),
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) =>
                                const InstructorPrecautionsManagementScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildActionCard(
                      'Profile Settings',
                      'Update your profile and availability',
                      Icons.settings_rounded,
                      const Color(0xFF64748B),
                      () {
                        final bool isWeb = MediaQuery.of(context).size.width > 600;
                        if (isWeb) {
                          ref.read(navigationProvider.notifier).setIndex(3);
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) =>
                                  const InstructorProfileSetupScreen(),
                            ),
                          );
                        }
                      },
                    ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
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
