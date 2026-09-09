import 'package:flutter/material.dart';
import 'package:icare/screens/instructor_dashboard.dart' deferred as i_dash;
import 'package:icare/screens/instructor_courses_management.dart'
    deferred as i_courses_mgmt;
import 'package:icare/screens/instructor_assign_course_screen.dart'
    deferred as i_assign_course;
import 'package:icare/screens/instructor_create_course.dart'
    deferred as i_create_prog;
import 'package:icare/screens/instructor_learners_screen.dart'
    deferred as i_learners;
import 'package:icare/screens/instructor_analytics.dart'
    deferred as i_analytics_h;
import 'package:icare/screens/instructor_precautions_management.dart'
    deferred as i_precautions;
import 'package:icare/screens/instructor_profile_setup.dart'
    deferred as i_profile;
import 'package:icare/screens/instructor_lms_dashboard.dart'
    deferred as i_lms_dash;
import 'package:icare/screens/instructor_lms_courses.dart'
    deferred as i_lms_courses;
import 'package:icare/screens/instructor_lms_create_course.dart'
    deferred as i_lms_create;
import 'package:icare/navigators/deferred_route.dart';
import 'package:icare/utils/theme.dart';

class InstructorSidebar extends StatelessWidget {
  final String currentRoute;

  const InstructorSidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildNavItem(
                    context,
                    'Dashboard',
                    Icons.dashboard_rounded,
                    'dashboard',
                    () => DeferredScreen(
                      loader: i_dash.loadLibrary,
                      builder: () => i_dash.InstructorDashboardScreen(),
                    ),
                  ),

                  // LMS SECTION
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'LEARNING MANAGEMENT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  _buildNavItem(
                    context,
                    'LMS Dashboard',
                    Icons.school_rounded,
                    'lms',
                    () => DeferredScreen(
                      loader: i_lms_dash.loadLibrary,
                      builder: () => i_lms_dash.InstructorLmsDashboard(),
                    ),
                  ),
                  _buildNavItem(
                    context,
                    'My Courses',
                    Icons.menu_book_rounded,
                    'lms-courses',
                    () => DeferredScreen(
                      loader: i_lms_courses.loadLibrary,
                      builder: () => i_lms_courses.InstructorLmsCoursesScreen(),
                    ),
                  ),
                  _buildNavItem(
                    context,
                    'Create Course',
                    Icons.add_circle_outline_rounded,
                    'lms-create',
                    () => DeferredScreen(
                      loader: i_lms_create.loadLibrary,
                      builder: () =>
                          i_lms_create.InstructorLmsCreateCourseScreen(),
                    ),
                  ),

                  const Divider(),

                  // HEALTH PROGRAMS SECTION
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      'HEALTH PROGRAMS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  _buildNavItem(
                    context,
                    'Manage Programs',
                    Icons.health_and_safety_rounded,
                    'programs',
                    () => DeferredScreen(
                      loader: i_courses_mgmt.loadLibrary,
                      builder: () =>
                          i_courses_mgmt.InstructorCoursesManagementScreen(),
                    ),
                  ),
                  _buildNavItem(
                    context,
                    'Create New Program',
                    Icons.add_circle_outline_rounded,
                    'create',
                    () => DeferredScreen(
                      loader: i_create_prog.loadLibrary,
                      builder: () =>
                          i_create_prog.InstructorCreateCourseScreen(),
                    ),
                  ),
                  _buildNavItem(
                    context,
                    'Assign Programs',
                    Icons.assignment_ind_rounded,
                    'assign',
                    () => DeferredScreen(
                      loader: i_assign_course.loadLibrary,
                      builder: () =>
                          i_assign_course.InstructorAssignCourseScreen(),
                    ),
                  ),
                  _buildNavItem(
                    context,
                    'Assigned Learners',
                    Icons.group_rounded,
                    'learners',
                    () => DeferredScreen(
                      loader: i_learners.loadLibrary,
                      builder: () => i_learners.InstructorLearnersScreen(),
                    ),
                  ),
                  _buildNavItem(
                    context,
                    'Analytics',
                    Icons.analytics_rounded,
                    'analytics',
                    () => DeferredScreen(
                      loader: i_analytics_h.loadLibrary,
                      builder: () => i_analytics_h.InstructorAnalytics(),
                    ),
                  ),
                  _buildNavItem(
                    context,
                    'Health Tips',
                    Icons.tips_and_updates_rounded,
                    'tips',
                    () => DeferredScreen(
                      loader: i_precautions.loadLibrary,
                      builder: () =>
                          i_precautions.InstructorPrecautionsManagementScreen(),
                    ),
                  ),
                  const Divider(),
                  _buildNavItem(
                    context,
                    'Profile Settings',
                    Icons.settings_rounded,
                    'profile',
                    () => DeferredScreen(
                      loader: i_profile.loadLibrary,
                      builder: () => i_profile.InstructorProfileSetupScreen(),
                    ),
                  ),
                ],
              ),
            ),
            // footer removed (no logout in drawer)
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      color: Colors.white,
      child: Column(
        children: [
          Image.asset(
            'assets/Asset 1.png',
            height: 64,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primaryColor,
                radius: 22,
                child: Icon(Icons.person_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructor Panel',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Program Manager',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
    // A builder, not a built widget: a deferred screen's constructor cannot
    // be called until its chunk has loaded, so the nav item hands back a
    // DeferredScreen that does the loading when the item is actually tapped.
    Widget Function() screen,
  ) {
    final isSelected = currentRoute == route;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primaryColor : const Color(0xFF64748B),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primaryColor : const Color(0xFF0F172A),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primaryColor.withValues(alpha: 0.05),
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (!isSelected) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => screen()));
        }
      },
    );
  }
}
