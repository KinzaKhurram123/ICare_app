import 'package:flutter/material.dart';
import '../services/laboratory_service.dart';
import '../widgets/back_button.dart';

class LabTestsManagement extends StatefulWidget {
  const LabTestsManagement({super.key});

  @override
  State<LabTestsManagement> createState() => _LabTestsManagementState();
}

class _LabTestsManagementState extends State<LabTestsManagement>
    with TickerProviderStateMixin {
  final LaboratoryService _labService = LaboratoryService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _tests = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Master test list - standardized across all labs
  static const List<Map<String, String>> masterTestList = [
    {'name': 'Complete Blood Count (CBC)', 'shortForm': 'CBC'},
    {'name': 'Lipid Profile', 'shortForm': 'Lipid'},
    {'name': 'Liver Function Test (LFT)', 'shortForm': 'LFT'},
    {'name': 'Kidney Function Test (KFT)', 'shortForm': 'KFT'},
    {'name': 'Thyroid Profile', 'shortForm': 'Thyroid'},
    {'name': 'HbA1c (Glycated Hemoglobin)', 'shortForm': 'HbA1c'},
    {'name': 'Blood Sugar Fasting', 'shortForm': 'BSF'},
    {'name': 'Blood Sugar Random', 'shortForm': 'BSR'},
    {'name': 'Urine Complete Examination', 'shortForm': 'UCE'},
    {'name': 'Stool Complete Examination', 'shortForm': 'SCE'},
    {'name': 'COVID-19 PCR Test', 'shortForm': 'COVID PCR'},
    {'name': 'COVID-19 Rapid Antigen Test', 'shortForm': 'COVID RAT'},
    {'name': 'Vitamin D Test', 'shortForm': 'Vit D'},
    {'name': 'Vitamin B12 Test', 'shortForm': 'Vit B12'},
    {'name': 'Hepatitis B Surface Antigen (HBsAg)', 'shortForm': 'HBsAg'},
    {'name': 'Hepatitis C Antibody (Anti-HCV)', 'shortForm': 'Anti-HCV'},
    {'name': 'HIV Screening Test', 'shortForm': 'HIV'},
    {'name': 'Dengue NS1 Antigen', 'shortForm': 'Dengue NS1'},
    {'name': 'Dengue IgG/IgM Antibodies', 'shortForm': 'Dengue Ab'},
    {'name': 'Malaria Parasite Test', 'shortForm': 'MP'},
    {'name': 'Typhoid Test (Widal)', 'shortForm': 'Widal'},
    {'name': 'Pregnancy Test (Beta hCG)', 'shortForm': 'Beta hCG'},
    {'name': 'Prostate Specific Antigen (PSA)', 'shortForm': 'PSA'},
    {'name': 'Electrocardiogram (ECG)', 'shortForm': 'ECG'},
    {'name': 'X-Ray Chest', 'shortForm': 'CXR'},
    {'name': 'Ultrasound Abdomen', 'shortForm': 'USG Abd'},
  ];

  // Turnaround time options
  static const List<String> turnaroundOptions = [
    '2 Hours',
    '4 Hours',
    '6 Hours',
    '12 Hours',
    '1 Day',
    '2 Days',
    '3 Days',
    '5 Days',
    '7 Days',
  ];

  List<Map<String, dynamic>> get _filteredTests {
    if (_searchQuery.isEmpty) return _tests;
    return _tests.where((t) {
      final name = (t['name'] ?? '').toString().toLowerCase();
      final sample = (t['sampleType'] ?? '').toString().toLowerCase();
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || sample.contains(q);
    }).toList();
  }

  // Premium Theme Colors
  static const Color primaryColor = Color(0xFF0B2D6E);
  static const Color secondaryColor = Color(0xFF1565C0);
  static const Color accentColor = Color(0xFF0EA5E9);
  static const Color backgroundColor = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadTests();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTests() async {
    setState(() => _isLoading = true);

    try {
      final profile = await _labService.getProfile();
      setState(() {
        _tests = List<Map<String, dynamic>>.from(
          profile['availableTests'] ?? [],
        );
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unable to load data. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _addTest(String testName, double price, String turnaroundTime, String collectionType, {bool urgentAvailable = false, String? urgentTurnaround}) async {
    try {
      final newTest = {
        'name': testName,
        'price': price,
        'turnaroundTime': turnaroundTime,
        'collectionType': collectionType,
        'urgentAvailable': urgentAvailable,
        if (urgentTurnaround != null) 'urgentTurnaround': urgentTurnaround,
      };
      final updatedTests = [..._tests, newTest];
      await _labService.updateProfile({'availableTests': updatedTests});
      setState(() => _tests = updatedTests);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test added successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unable to complete action. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteTest(int index) async {
    try {
      final updatedTests = List<Map<String, dynamic>>.from(_tests)
        ..removeAt(index);
      await _labService.updateProfile({'availableTests': updatedTests});
      setState(() => _tests = updatedTests);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test removed successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unable to delete. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAddTestDialog() {
    String? selectedTest;
    String testSearchQuery = '';
    final priceController = TextEditingController();
    String normalTurnaround = '1 Day';
    String urgentTurnaround = '4 Hours';
    String collectionType = 'Home and Lab';
    bool urgentAvailable = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.science_rounded,
                          size: 32,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add New Test',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Select from standardized test catalog',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'TEST NAME',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF64748B),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (v) => setModalState(() => testSearchQuery = v),
                          decoration: InputDecoration(
                            hintText: 'Search test name...',
                            prefixIcon: const Icon(Icons.search_rounded, color: primaryColor),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                        const Divider(height: 1),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView(
                            shrinkWrap: true,
                            children: masterTestList
                                .where((test) => testSearchQuery.isEmpty || test['name']!.toLowerCase().contains(testSearchQuery.toLowerCase()))
                                .map((test) => ListTile(
                                      title: Text(test['name']!),
                                      selected: selectedTest == test['name'],
                                      selectedTileColor: primaryColor.withOpacity(0.1),
                                      onTap: () => setModalState(() => selectedTest = test['name']),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selectedTest != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Selected: $selectedTest',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text('PRICE (PKR)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 1.0)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g., 1500',
                      prefixIcon: const Icon(Icons.attach_money_rounded, color: primaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryColor, width: 2)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('SAMPLE COLLECTION TYPE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 1.0)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCollectionOption('Home Only', 'Home Only', collectionType, (v) => setModalState(() => collectionType = v)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCollectionOption('Lab Only', 'Lab Only', collectionType, (v) => setModalState(() => collectionType = v)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCollectionOption('Both', 'Home and Lab', collectionType, (v) => setModalState(() => collectionType = v)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('NORMAL TURNAROUND TIME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 1.0)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: normalTurnaround,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.schedule_rounded, color: primaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                    items: turnaroundOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setModalState(() => normalTurnaround = v!),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Urgent Test Available?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      Switch(
                        value: urgentAvailable,
                        activeColor: const Color(0xFFFF4D00),
                        onChanged: (v) => setModalState(() => urgentAvailable = v),
                      ),
                    ],
                  ),
                  if (urgentAvailable) ...[
                    const SizedBox(height: 16),
                    const Text('URGENT TURNAROUND TIME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFFF4D00), letterSpacing: 1.0)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: urgentTurnaround,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.priority_high_rounded, color: Color(0xFFFF4D00)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF4D00))),
                        filled: true,
                        fillColor: const Color(0xFFFFF5F0),
                      ),
                      items: turnaroundOptions.where((t) => t.contains('Hour') || t == '1 Day').map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(color: Color(0xFFFF4D00))))).toList(),
                      onChanged: (v) => setModalState(() => urgentTurnaround = v!),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: selectedTest == null
                              ? null
                              : () {
                                  final priceText = priceController.text.trim();
                                  if (priceText.isNotEmpty) {
                                    final price = double.tryParse(priceText) ?? 0.0;
                                    _addTest(
                                      selectedTest!,
                                      price,
                                      normalTurnaround,
                                      collectionType,
                                      urgentAvailable: urgentAvailable,
                                      urgentTurnaround: urgentAvailable ? urgentTurnaround : null,
                                    );
                                    Navigator.pop(ctx);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Add Test', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionOption(String label, String value, String selected, Function(String) onTap) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? primaryColor : const Color(0xFFE2E8F0), width: 2),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: const Text(
          'Test Catalog',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Gilroy-Bold',
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTestDialog,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(isDesktop ? 'Add New Test' : 'Add Test'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _filteredTests.isEmpty
                ? _buildEmptyState()
                : _buildTestsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Laboratory Tests',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage tests offered by your laboratory',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_tests.length} Tests Available',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.biotech_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8ECF5), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Search by test name or sample type...',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.search_rounded, color: primaryColor, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryColor),
          SizedBox(height: 16),
          Text(
            'Loading tests...',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Icon(
              Icons.science_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No tests added yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start by adding the tests your laboratory offers',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddTestDialog,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Your First Test'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestsList() {
    final tests = _filteredTests;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _loadTests,
        color: primaryColor,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          itemCount: tests.length,
          itemBuilder: (context, index) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 200 + (index * 50)),
              child: _buildTestCard(tests[index], _tests.indexOf(tests[index])),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTestCard(Map<String, dynamic> test, int index) {
    final testName = test['name'] ?? 'Unknown Test';
    final price = test['price'] ?? 0.0;
    final turnaround = test['turnaroundTime'] ?? '';
    final sampleType = test['sampleType'] ?? '';
    final testIcon = _getTestIcon(testName);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF5), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Icon(testIcon, color: primaryColor, size: 26)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    testName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildChip('PKR $price', Icons.attach_money_rounded, const Color(0xFF10B981)),
                      if (turnaround.isNotEmpty)
                        _buildChip(turnaround, Icons.schedule_rounded, const Color(0xFFF59E0B)),
                      if (sampleType.isNotEmpty)
                        _buildChip(sampleType, Icons.colorize_rounded, const Color(0xFF8B5CF6)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showDeleteDialog(testName, index),
              icon: const Icon(Icons.delete_outline_rounded),
              color: const Color(0xFFEF4444),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  void _showDeleteDialog(String testName, int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  size: 48,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Delete Test',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to remove "$testName"? This action cannot be undone.',
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _deleteTest(index);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTestIcon(String testName) {
    final name = testName.toLowerCase();
    if (name.contains('blood')) return Icons.bloodtype_rounded;
    if (name.contains('urine')) return Icons.local_hospital_rounded;
    if (name.contains('x-ray') || name.contains('xray'))
      return Icons.medical_services_rounded;
    if (name.contains('mri') || name.contains('scan'))
      return Icons.scanner_rounded;
    if (name.contains('covid') || name.contains('pcr'))
      return Icons.coronavirus_rounded;
    if (name.contains('heart') || name.contains('ecg'))
      return Icons.favorite_rounded;
    if (name.contains('liver') || name.contains('kidney'))
      return Icons.healing_rounded;
    return Icons.science_rounded;
  }
}
