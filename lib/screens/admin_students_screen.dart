import 'package:flutter/material.dart';
import 'package:icare/screens/admin_student_detail_screen.dart';

class AdminStudentsScreen extends StatelessWidget {
  final void Function(String) onViewProfile;
  const AdminStudentsScreen({super.key, required this.onViewProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section 1: Students Details ───────────────────────────────
            const Text(
              'Students Details',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildTopStatCard(
                    title: 'Total Courses',
                    count: '545',
                    icon: Icons.school_rounded,
                    iconBg: const Color(0xFF1CB0F6),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildTopStatCard(
                    title: 'Enrolled Students',
                    count: '376',
                    icon: Icons.group_rounded,
                    iconBg: const Color(0xFF0B2D6E),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Section 2: Students Profile ───────────────────────────────
            const Text(
              'Students Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 24),

            // Horizontal list of patient/student profiles
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStudentProfileCard(context, 'Ahsan'),
                  _buildStudentProfileCard(context, 'Jordan'),
                  _buildStudentProfileCard(context, 'Jordan'),
                  _buildStudentProfileCard(context, 'Jordan'),
                  _buildStudentProfileCard(context, 'Jordan'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF718096),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2D3748),
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentProfileCard(BuildContext context, String name) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 24, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=200&auto=format&fit=crop'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 24),
          _buildDetailRow('Name', name),
          _buildDetailRow('Total Enrolled Course', '80'),
          _buildDetailRow('Age', '32'),
          _buildDetailRow('Qualification', 'Bachelors'),
          _buildDetailRow('Gender', 'Male'),
          _buildDetailRow('Phone Number', '03098949375'),
          _buildDetailRow('Address', 'Lorem Ipsum'),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => onViewProfile(name),
            child: const Text(
              'View Full Profile',
              style: TextStyle(
                color: Color(0xFF1CB0F6),
                fontWeight: FontWeight.w700,
                fontSize: 13,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF718096),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF2D3748),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
