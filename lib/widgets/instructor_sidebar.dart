import 'package:flutter/material.dart';
import 'package:icare/screens/instructor_dashboard.dart';
import 'package:icare/screens/instructor_courses_management.dart';
import 'package:icare/screens/instructor_assign_course_screen.dart';
import 'package:icare/screens/instructor_create_course.dart';
import 'package:icare/screens/instructor_learners_screen.dart';
import 'package:icare/screens/instructor_analytics.dart';
import 'package:icare/screens/instructor_precautions_management.dart';
import 'package:icare/screens/instructor_profile_setup.dart';
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
                    const InstructorDashboardScreen(),
                  ),
                  _buildNavItem(
                    context,
                    'Manage Programs',
                    Icons.health_and_safety_rounded,
                    'programs',
                    const InstructorCoursesManagementScreen(),
                  ),
                  _buildNavItem(
                    context,
                    'Create New Program',
                    Icons.add_circle_outline_rounded,
                    'create',
                    const InstructorCreateCourseScreen(),
                  ),
                  _buildNavItem(
                    context,
                    'Assign Programs',
                    Icons.assignment_ind_rounded,
                    'assign',
                    const InstructorAssignCourseScreen(),
                  ),
                  _buildNavItem(
                    context,
                    'Assigned Learners',
                    Icons.group_rounded,
                    'learners',
                    const InstructorLearnersScreen(),
                  ),
                  _buildNavItem(
                    context,
                    'Analytics',
                    Icons.analytics_rounded,
                    'analytics',
                    const InstructorAnalytics(),
                  ),
                  _buildNavItem(
                    context,
                    'Health Tips',
                    Icons.tips_and_updates_rounded,
                    'tips',
                    const InstructorPrecautionsManagementScreen(),
                  ),
                  const Divider(),
                  _buildNavItem(
                    context,
                    'Profile Settings',
                    Icons.settings_rounded,
                    'profile',
                    const InstructorProfileSetupScreen(),
                  ),
                ],
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      color: Colors.white,
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryColor,
            radius: 24,
            child: Icon(Icons.person_rounded, color: Colors.white),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructor Panel',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Program Manager',
                  style: TextStyle(color: AppColors.primaryColor, fontSize: 13),
                ),
              ],
            ),
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
    Widget screen,
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
      selectedTileColor: AppColors.primaryColor.withOpacity(0.05),
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (!isSelected) {
          Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (ctx) => screen));
        }
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: OutlinedButton.icon(
        onPressed: () {
          // Implement Logout
        },
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Color(0xFFF1F5F9)),
          minimumSize: const Size(double.infinity, 45),
        ),
      ),
    );
  }
}
