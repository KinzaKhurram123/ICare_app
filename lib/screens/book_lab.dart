import 'package:flutter/material.dart';
import 'package:icare/models/lab_test.dart';
import 'package:icare/screens/confirm_booking.dart';
import 'package:icare/services/laboratory_service.dart';
import 'package:icare/services/medical_record_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:intl/intl.dart';

class BookLabScreen extends StatefulWidget {
  final String? labId;
  final String? labTitle;
  /// Pre-prescribed test names from doctor (auto-selected in Step 2)
  final List<String> prescribedTests;

  const BookLabScreen({
    super.key,
    this.labId,
    this.labTitle,
    this.prescribedTests = const [],
  });

  @override
  State<BookLabScreen> createState() => _BookLabScreenState();
}

class _BookLabScreenState extends State<BookLabScreen> {
  final LaboratoryService _labService = LaboratoryService();
  int _currentStep = 1;

  // Step 1 Data
  bool _homeSample = false;
  bool _sampleSelectionDone = false;

  // Step 2 Data
  final List<LabTest> _selectedTests = [];
  List<LabTest> _allTests = [];
  List<LabTest> _filteredTests = [];
  bool _isTestsLoading = false;
  String _testSearchQuery = "";

  // Step 3 Data
  List<dynamic> _labs = [];
  List<dynamic> _filteredLabs = [];
  bool _isLabsLoading = false;
  String? _selectedLabId;
  Map<String, dynamic>? _selectedLab;
  double _radiusFilter = 5.0; // 5, 10, 15

  // Schedule Info (part of final step)
  String _selectedDate = '';
  String _selectedTime = "";
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isTestsLoading = true);
    try {
      final labs = await _labService.getAllLaboratories();
      setState(() => _labs = labs);

      if (labs.isNotEmpty) {
        final firstLab = await _labService.getLabById(labs[0]['_id']);
        final List<dynamic> testsData = firstLab['availableTests'] ?? [];
        _allTests = testsData.map((t) => LabTest(
          id: t['_id'] ?? t['name'] ?? '',
          name: t['name'] ?? 'Unnamed Test',
          price: (t['price'] ?? 0).toDouble(),
        )).toList();
        _filteredTests = _allTests;
      }

      // Fetch doctor-prescribed tests and add any not in the lab's list
      final prescribed = widget.prescribedTests.isNotEmpty
          ? widget.prescribedTests
          : await MedicalRecordService().getPrescribedLabTests();

      if (prescribed.isNotEmpty) {
        // Add prescribed tests that aren't already in the list
        for (final name in prescribed) {
          if (!_allTests.any((t) => t.name.toLowerCase() == name.toLowerCase())) {
            _allTests.add(LabTest(id: name, name: name, price: 0));
          }
        }
        _filteredTests = _allTests;

        // Auto-select prescribed tests
        setState(() {
          for (final name in prescribed) {
            final match = _allTests.firstWhere(
              (t) => t.name.toLowerCase() == name.toLowerCase(),
              orElse: () => LabTest(id: name, name: name, price: 0),
            );
            if (!_selectedTests.any((t) => t.id == match.id)) {
              _selectedTests.add(match);
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching lab data: $e");
    } finally {
      setState(() => _isTestsLoading = false);
    }
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (!_sampleSelectionDone) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a sample collection type")),
        );
        return;
      }
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      if (_selectedTests.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select at least one test")),
        );
        return;
      }
      _filterLabsByRadius();
      setState(() => _currentStep = 3);
    } else if (_currentStep == 3) {
      if (_selectedLabId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a laboratory")),
        );
        return;
      }
      if (_selectedDate.isEmpty || _selectedTime.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select date and time")),
        );
        return;
      }
      if (_homeSample && (_cityController.text.isEmpty || _addressController.text.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please provide collection address")),
        );
        return;
      }
      
      // Proceed to Confirmation
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => ConfirmBookingScreen(
            bookingData: {
              'labId': _selectedLabId,
              'labTitle': _selectedLab?['labName'] ?? _selectedLab?['name'] ?? 'Laboratory',
              'date': _selectedDate,
              'time': _selectedTime,
              'city': _cityController.text,
              'address': _addressController.text,
              'homeSample': _homeSample,
            },
            selectedTests: _selectedTests,
          ),
        ),
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  void _filterLabsByRadius() {
    // In a real app, this would use geolocator to calc distance
    // Mocking for now: showing all results
    setState(() {
      _filteredLabs = _labs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        leading: CustomBackButton(onPressed: _prevStep),
        title: CustomText(
          text: _getStepTitle(),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _getCurrentStepWidget(),
            ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 1: return "Sample Type";
      case 2: return "Select Tests";
      case 3: return "Nearby Labs";
      default: return "Book Lab Test";
    }
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      color: Colors.white,
      child: Row(
        children: [
          _indicatorItem(1, "Type"),
          _indicatorLine(1),
          _indicatorItem(2, "Tests"),
          _indicatorLine(2),
          _indicatorItem(3, "Lab"),
        ],
      ),
    );
  }

  Widget _indicatorItem(int step, String label) {
    bool isDone = _currentStep > step;
    bool isActive = _currentStep == step;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDone || isActive ? AppColors.primaryColor : const Color(0xFFE2E8F0),
            shape: BoxShape.circle,
            boxShadow: isActive ? [BoxShadow(color: AppColors.primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
          ),
          child: Center(
            child: isDone 
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : Text("$step", style: TextStyle(color: isDone || isActive ? Colors.white : const Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? AppColors.primaryColor : const Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _indicatorLine(int step) {
    bool isDone = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 14),
        color: isDone ? AppColors.primaryColor : const Color(0xFFE2E8F0),
      ),
    );
  }

  Widget _getCurrentStepWidget() {
    switch (_currentStep) {
      case 1: return _buildStep1();
      case 2: return _buildStep2();
      case 3: return _buildStep3();
      default: return const SizedBox();
    }
  }

  // --- STEP 1: SAMPLE TYPE ---
  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "How would you like to provide your sample?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          const Text(
            "Select whether you want a technician at home or visit the lab yourself.",
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _sampleTypeCard(
                true, 
                "Home Sample", 
                "Technician visits your address", 
                Icons.home_work_rounded,
                const Color(0xFF3B82F6),
              )),
              const SizedBox(width: 16),
              Expanded(child: _sampleTypeCard(
                false, 
                "At Laboratory", 
                "You visit the lab location", 
                Icons.local_hospital_rounded,
                const Color(0xFF10B981),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sampleTypeCard(bool isHome, String title, String sub, IconData icon, Color color) {
    bool isSelected = _sampleSelectionDone && _homeSample == isHome;
    return InkWell(
      onTap: () {
        setState(() {
          _homeSample = isHome;
          _sampleSelectionDone = true;
        });
      },
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? color : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1),
          boxShadow: [
            BoxShadow(
              color: isSelected ? color.withOpacity(0.1) : Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 36),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.3)),
            const SizedBox(height: 8),
            Text(sub, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4)),
            if (isSelected) 
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Icon(Icons.check_circle, color: color, size: 24),
              ),
          ],
        ),
      ),
    );
  }

  // --- STEP 2: SELECT TESTS ---
  Widget _buildStep2() {
    final hasPrescribed = _selectedTests.isNotEmpty &&
        widget.prescribedTests.isNotEmpty;
    return Column(
      children: [
        if (hasPrescribed)
          Container(
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.medical_services_rounded, color: Color(0xFF3B82F6), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${_selectedTests.length} test(s) pre-selected from your doctor\'s prescription',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF1D4ED8), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _testSearchQuery = val;
                  _filteredTests = _allTests.where((t) => t.name.toLowerCase().contains(val.toLowerCase())).toList();
                });
              },
              decoration: const InputDecoration(
                hintText: "Search for lab tests...",
                prefixIcon: Icon(Icons.search, color: AppColors.primaryColor),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        Expanded(
          child: _isTestsLoading 
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filteredTests.length,
                itemBuilder: (ctx, i) {
                  final test = _filteredTests[i];
                  final isSelected = _selectedTests.any((t) => t.id == test.id);
                  return _testListItem(test, isSelected);
                },
              ),
        ),
        if (_selectedTests.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: const Color(0xFFF1F5F9)))),
            child: Row(
              children: [
                Text("${_selectedTests.length} tests selected", style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text("Total: Rs. ${_selectedTests.fold(0.0, (sum, t) => sum + t.price).toInt()}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryColor)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _testListItem(LabTest test, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedTests.removeWhere((t) => t.id == test.id);
            } else {
              _selectedTests.add(test);
            }
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.04) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(color: AppColors.primaryColor.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5))
            ] : null,
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? AppColors.primaryColor : const Color(0xFFCBD5E1), width: 2),
                  color: isSelected ? AppColors.primaryColor : Colors.transparent,
                ),
                child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: isSelected ? AppColors.primaryColor : const Color(0xFF111827),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text("Results in 12-24 hours", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              Text(
                "Rs. ${test.price.toInt()}",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: isSelected ? AppColors.primaryColor : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- STEP 3: NEARBY LABS ---
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Select a Laboratory", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [5, 10, 15].map((d) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text("${d}km"),
                selected: _radiusFilter == d.toDouble(),
                onSelected: (val) {
                  if (val) setState(() => _radiusFilter = d.toDouble());
                },
              ),
            )).toList(),
          ),
          const SizedBox(height: 24),
          ..._filteredLabs.map((lab) {
            bool isSelected = _selectedLabId == lab['_id'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => setState(() {
                  _selectedLabId = lab['_id'];
                  _selectedLab = lab;
                }),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryColor.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? AppColors.primaryColor : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.science, color: AppColors.primaryColor),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lab['labName'] ?? lab['name'] ?? 'Lab', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text("${lab['address'] ?? 'Location'}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      if (isSelected) const Icon(Icons.check_circle, color: AppColors.primaryColor),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          const Text("Schedule Appointment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSelector("DATE", _selectedDate.isEmpty ? "Select Date" : _selectedDate, Icons.calendar_today, _pickDate)),
              const SizedBox(width: 12),
              Expanded(child: _buildSelector("TIME", _selectedTime.isEmpty ? "Select Time" : _selectedTime, Icons.access_time, _pickTime)),
            ],
          ),
          if (_homeSample) ...[
            const SizedBox(height: 24),
            _buildInputLabel("CITY"),
            const SizedBox(height: 8),
            _buildSmallField(_cityController, "e.g. Karachi"),
            const SizedBox(height: 16),
            _buildInputLabel("COLLECTION ADDRESS"),
            const SizedBox(height: 8),
            _buildSmallField(_addressController, "Street, Apartment..."),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSelector(String label, String value, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primaryColor),
            const SizedBox(width: 8),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey));
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFF1F5F9)))),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            _currentStep == 3 ? "Review Booking" : "Continue",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) setState(() => _selectedDate = DateFormat("yyyy-MM-dd").format(date));
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) setState(() => _selectedTime = time.format(context));
  }
}
