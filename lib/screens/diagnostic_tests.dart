import 'package:flutter/material.dart';
import 'package:icare/screens/book_lab.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/models/lab_test.dart';

class DiagnosticTestsScreen extends StatefulWidget {
  const DiagnosticTestsScreen({super.key});

  @override
  State<DiagnosticTestsScreen> createState() => _DiagnosticTestsScreenState();
}

class _DiagnosticTestsScreenState extends State<DiagnosticTestsScreen> {
  final List<Map<String, dynamic>> _categories = [
    {"name": "Popular", "icon": Icons.star_rounded},
    {"name": "Blood Tests", "icon": Icons.bloodtype_rounded},
    {"name": "Heart Health", "icon": Icons.favorite_rounded},
    {"name": "Diabetes", "icon": Icons.water_drop_rounded},
    {"name": "Full Body", "icon": Icons.person_search_rounded},
  ];
  
  String _selectedCategory = "Popular";

  final List<LabTest> _tests = [
    LabTest(id: "1", name: "Complete Blood Count (CBC)", price: 1200),
    LabTest(id: "2", name: "Lipid Profile (Cholesterol)", price: 2500),
    LabTest(id: "3", name: "Liver Function Test (LFT)", price: 3200),
    LabTest(id: "4", name: "HbA1c (Diabetes)", price: 1800),
    LabTest(id: "5", name: "Kidney Function Test (KFT)", price: 2800),
    LabTest(id: "6", name: "Vitamin D Deficiency", price: 4500),
    LabTest(id: "7", name: "Thyroid Profile (T3, T4, TSH)", price: 2200),
    LabTest(id: "8", name: "Cardiac Risk Markers", price: 5500),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Utils.windowWidth(context) > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const CustomBackButton(),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Diagnostic Tests",
          style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            padding: EdgeInsets.all(isDesktop ? 40 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Header
                _buildSearchHeader(isDesktop),
                const SizedBox(height: 32),
                
                // Categories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) => _buildCategoryChip(cat)).toList(),
                  ),
                ),
                const SizedBox(height: 32),

                // Grid of Tests
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _tests.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 3 : 1,
                    mainAxisExtent: 180,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemBuilder: (context, index) => _buildTestCard(_tests[index]),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0036BC), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Find the right test for you",
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            "Book home sample collection or visit our verified labs",
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "Search for tests (e.g. Blood, X-Ray, MRI)",
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(Map<String, dynamic> cat) {
    final bool isSelected = _selectedCategory == cat['name'];
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = cat['name']),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
            ],
            border: Border.all(color: isSelected ? AppColors.primaryColor : Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(cat['icon'], size: 18, color: isSelected ? Colors.white : Colors.grey),
              const SizedBox(width: 8),
              Text(
                cat['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestCard(LabTest test) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.biotech_rounded, color: Color(0xFF0EA5E9), size: 18),
              ),
              const Spacer(),
              const Icon(Icons.bolt, color: Colors.orange, size: 16),
              const Text(" Instant Report", style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Text(
              test.name,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF111827), height: 1.2),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Rs. ${test.price.toInt()}",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primaryColor),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const BookLabScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text("Book Now", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
