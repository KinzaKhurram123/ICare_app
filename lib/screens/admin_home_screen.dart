import 'package:flutter/material.dart';
import 'package:icare/screens/courses.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  // ── Course data ─────────────────────────────────────────────────────────
  static const List<Map<String, String>> _courses = [
    {
      'title': 'Child Therapist',
      'description':
          'Learn evidence-based techniques for supporting children\'s emotional and behavioral development through therapeutic play and structured interventions.',
      'instructor': 'Dr. Aisha Kamara',
      'image':
          'https://images.unsplash.com/photo-1607990281513-2c110a25bd8c?auto=format&fit=crop&w=500&q=80',
    },
    {
      'title': 'Behavioral Therapist',
      'description':
          'Master cognitive-behavioral strategies to help clients overcome anxiety, depression, and other behavioral challenges in clinical settings.',
      'instructor': 'Prof. Linda Osei',
      'image':
          'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?auto=format&fit=crop&w=500&q=80',
    },
    {
      'title': 'Pediatric Nutrition',
      'description':
          'Understand the nutritional needs of children at every growth stage and design meal plans that promote healthy development and immunity.',
      'instructor': 'Dr. Yemi Adeyemi',
      'image':
          'https://images.unsplash.com/photo-1529390079861-591de354faf5?auto=format&fit=crop&w=500&q=80',
    },
    {
      'title': 'Early Childhood Education',
      'description':
          'Explore foundational principles of early learning, classroom management, and curriculum design tailored for children aged 2–7 years.',
      'instructor': 'Ms. Grace Nwachukwu',
      'image':
          'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=500&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Page title ────────────────────────────────────────────────
            const Text(
              'Home',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 28),

            // ── Stat cards grid ───────────────────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final int crossAxisCount = constraints.maxWidth > 800 ? 2 : 1;
                final double childAspectRatio =
                    constraints.maxWidth > 800 ? 2.6 : 2.4;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 28,
                  mainAxisSpacing: 28,
                  childAspectRatio: childAspectRatio,
                  children: [
                    _buildStatCard(
                      title: 'Pharmacy Orders',
                      count: '668',
                      icon: Icons.local_pharmacy_outlined,
                      onTap: () => _showPharmacyOrdersModal(context),
                    ),
                    _buildStatCard(
                      title: 'Doctors Appointments',
                      count: '67',
                      icon: Icons.medical_services_outlined,
                    ),
                    _buildStatCard(
                      title: 'Lab Orders',
                      count: '313',
                      icon: Icons.biotech_outlined,
                    ),
                    _buildStatCard(
                      title: 'Courses Upload',
                      count: '545',
                      icon: Icons.school_outlined,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 48),

            // ── Course Library header ─────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Course Library',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D3748),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const Courses(),
                      ),
                    );
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Color(0xFF1EA6FC),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF1EA6FC),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Horizontal course cards list ───────────────────────────────
            SizedBox(
              height: 370,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  return _buildCourseCard(_courses[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stat card ────────────────────────────────────────────────────────────
  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Left blue icon section ────────────────────────────────────
            Container(
              width: 130,
              decoration: const BoxDecoration(
                color: Color(0xFF1CB0F6),
                borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
              ),
              child: Center(
                child: Icon(icon, color: Colors.white, size: 52),
              ),
            ),

            // ── Right text section ────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 18.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF718096),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      count,
                      style: const TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D3748),
                        height: 1.1,
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

  // ── Pharmacy Orders Modal ────────────────────────────────────────────────
  void _showPharmacyOrdersModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1CB0F6),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF1CB0F6),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Pharmacy Orders',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 32),

              // Orders List
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return _buildOrderCard();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard() {
    return Container(
      width: 420,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quantum Spar Lab',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Products',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF718096),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildProductIcon(Icons.medication_rounded),
              const SizedBox(width: 8),
              _buildProductIcon(Icons.medical_services_rounded),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow('Name', 'Sadia'),
          _buildDetailRow('Patient Name', 'Sadia', alignRight: true),
          _buildDetailRow('', 'Shahrah - e\nfaisal near KFC\nStreet 1', alignRight: true),
          _buildDetailRow('Age', '32'),
          _buildDetailRow('Date', '21 June 2025'),
          _buildDetailRow('Time', '12:PM'),
          _buildDetailRow('Phone Number', '03098949375'),
          _buildDetailRow('Amount', '6000'),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4A5568),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                'Delievered',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF48BB78),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductIcon(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Icon(icon, color: const Color(0xFF3182CE), size: 24),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool alignRight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (label.isNotEmpty)
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4A5568),
                fontWeight: FontWeight.w500,
              ),
            ),
          if (label.isEmpty) const Spacer(),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3748),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Course card ──────────────────────────────────────────────────────────
  Widget _buildCourseCard(Map<String, String> course) {
    return Container(
      width: 290,
      margin: const EdgeInsets.only(right: 22, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Course thumbnail ────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              course['image']!,
              height: 155,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 155,
                width: double.infinity,
                color: const Color(0xFFE2E8F0),
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: Color(0xFFCBD5E0),
                  size: 36,
                ),
              ),
            ),
          ),

          // ── Course details ──────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    course['title']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D3748),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Expanded(
                    child: Text(
                      course['description']!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF718096),
                        height: 1.55,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Instructor row ──────────────────────────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFFF7FAFC),
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          size: 15,
                          color: Color(0xFF718096),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          course['instructor']!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A5568),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
