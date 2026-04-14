import 'package:flutter/material.dart';
import 'package:icare/models/doctor.dart';
import 'package:icare/models/user.dart';
import 'package:icare/screens/doctor_detail.dart';
import 'package:icare/services/doctor_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';

class DoctorsList extends StatefulWidget {
  const DoctorsList({super.key});

  @override
  State<DoctorsList> createState() => _DoctorsListState();
}

class _DoctorsListState extends State<DoctorsList> {
  final DoctorService _doctorService = DoctorService();
  List<Doctor> _doctors = [];
  List<Doctor> _filteredDoctors = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _searchMode = 'name'; // name, specialty, condition
  String? _selectedSpecialization;
  Set<String> _specializations = {};

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);

    final result = await _doctorService.getAllDoctors();

    debugPrint('📋 Doctors API Result: $result');

    if (result['success']) {
      final doctorsList = (result['doctors'] as List)
          .map((json) => Doctor.fromJson(json))
          .toList();

      debugPrint('✅ Loaded ${doctorsList.length} doctors');
      doctorsList.forEach((doc) {
        debugPrint('  - ${doc.user.name}: ${doc.specialization ?? "NO SPEC"}');
      });

      final specs = doctorsList
          .where(
            (d) => d.specialization != null && d.specialization!.isNotEmpty,
          )
          .map((d) => d.specialization!)
          .toSet();

      setState(() {
        _doctors = doctorsList;
        _filteredDoctors = doctorsList;
        _specializations = specs;
        // Set General Practitioner as default
        if (specs.contains('General Practitioner')) {
          _selectedSpecialization = 'General Practitioner';
          _filterDoctors();
        }
        _isLoading = false;
      });
    } else {
      debugPrint('❌ Failed to load doctors: ${result['message']}');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to load doctors'),
          ),
        );
      }
    }
  }

  void _filterDoctors() {
    debugPrint(
      '🔍 Filtering doctors: query="$_searchQuery", mode=$_searchMode, spec=$_selectedSpecialization',
    );
    setState(() {
      _filteredDoctors = _doctors.where((doctor) {
        bool matchesSearch = false;
        
        if (_searchMode == 'name') {
          matchesSearch = _searchQuery.isEmpty ||
              doctor.user.name.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
        } else if (_searchMode == 'specialty') {
          matchesSearch = _searchQuery.isEmpty ||
              (doctor.specialization?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ?? false);
        } else if (_searchMode == 'condition') {
          // Search by condition - would need backend support for this
          // For now, search in specialization
          matchesSearch = _searchQuery.isEmpty ||
              (doctor.specialization?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ?? false);
        }

        final matchesSpecialization =
            _selectedSpecialization == null ||
            doctor.specialization == _selectedSpecialization;

        return matchesSearch && matchesSpecialization;
      }).toList();
      debugPrint('✅ Filtered to ${_filteredDoctors.length} doctors');
    });
  }

  int get _onlineDoctorsCount {
    return _doctors.where((d) => d.isOnline).length;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Utils.windowWidth(context) > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: CustomText(
          text: "Find Doctors",
          fontFamily: "Gilroy-Bold",
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF0F172A),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and Filter Section
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(isDesktop ? 24 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Online doctors count
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_onlineDoctorsCount} doctors online right now',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Search Mode Tabs
                      Row(
                        children: [
                          _buildSearchModeTab('name', 'By Name'),
                          const SizedBox(width: 8),
                          _buildSearchModeTab('specialty', 'By Speciality'),
                          const SizedBox(width: 8),
                          _buildSearchModeTab('condition', 'By Condition'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Search Bar
                      TextField(
                        onChanged: (value) {
                          _searchQuery = value;
                          _filterDoctors();
                        },
                        decoration: InputDecoration(
                          hintText: _searchMode == 'name' 
                            ? 'Search doctors by name' 
                            : _searchMode == 'specialty'
                            ? 'Search by specialization'
                            : 'Search by condition (e.g., diabetes)',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                      ),
                      if (_specializations.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        // Specialization Filter (dropdown instead of chips)
                        DropdownButtonFormField<String>(
                          value: _selectedSpecialization,
                          decoration: InputDecoration(
                            labelText: 'Filter by Specialization',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Specializations'),
                            ),
                            ..._specializations.map((spec) => DropdownMenuItem(
                              value: spec,
                              child: Text(spec),
                            )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedSpecialization = value;
                              _filterDoctors();
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                // Doctors Grid
                Expanded(
                  child: _filteredDoctors.isEmpty
                      ? Center(
                          child: CustomText(
                            text: 'No doctors found',
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount = 2;
                            if (constraints.maxWidth > 1200) {
                              crossAxisCount = 4;
                            } else if (constraints.maxWidth > 800) {
                              crossAxisCount = 3;
                            }

                            return GridView.builder(
                              itemCount: _filteredDoctors.length,
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 40 : 20,
                                vertical: 24,
                              ),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    mainAxisExtent: isDesktop ? 340 : 280,
                                    crossAxisSpacing: 24,
                                    mainAxisSpacing: 24,
                                  ),
                              itemBuilder: (ctx, i) {
                                return DoctorProfileCard(
                                  doctor: _filteredDoctors[i],
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchModeTab(String mode, String label) {
    final isSelected = _searchMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _searchMode = mode;
          _filterDoctors();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class DoctorProfileCard extends StatelessWidget {
  const DoctorProfileCard({super.key, this.doctor, this.width, this.padding});

  final Doctor? doctor;
  final double? width;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    // Use dummy data if no doctor provided (for home screen preview)
    final displayDoctor =
        doctor ??
        Doctor(
          id: 'dummy',
          user: User(
            id: 'dummy',
            name: 'Dr. John Doe',
            email: 'doctor@example.com',
            phoneNumber: '0300000000',
            role: 'Doctor',
          ),
          specialization: 'General Practitioner',
          ratings: [4.5],
        );

    final averageRating = displayDoctor.averageRating;
    final reviewCount = displayDoctor.reviewCount;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor.withOpacity(0.03),
                ),
              ),
            ),

            // Interaction overlay
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (doctor != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) =>
                              DoctorDetailScreen(doctor: displayDoctor),
                        ),
                      );
                    }
                  },
                  child: const SizedBox.expand(),
                ),
              ),
            ),

            Padding(
              padding: padding ?? const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar Ring
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                      child: Text(
                        displayDoctor.user.name.isNotEmpty
                            ? displayDoctor.user.name
                                  .substring(0, 1)
                                  .toUpperCase()
                            : 'D',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Text Info
                  CustomText(
                    text: displayDoctor.user.name,
                    color: const Color(0xFF0F172A),
                    fontFamily: "Gilroy-Bold",
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  CustomText(
                    text:
                        displayDoctor.specialization ?? 'General Practitioner',
                    color: const Color(0xFF64748B),
                    fontFamily: "Gilroy-Medium",
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // PMDC Number (if available)
                  if (displayDoctor.pmdcNumber != null && displayDoctor.pmdcNumber!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'PMDC: ${displayDoctor.pmdcNumber}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0369A1),
                        ),
                      ),
                    ),
                  
                  // Years of Experience (if available)
                  if (displayDoctor.experience != null && displayDoctor.experience!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.work_outline_rounded,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          displayDoctor.experience!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  // Online indicator
                  if (displayDoctor.isOnline) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Online',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 16),

                  // Rating Badge
                  if (averageRating > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 4),
                          CustomText(
                            text: averageRating.toStringAsFixed(1),
                            color: const Color(0xFF92400E),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                          const SizedBox(width: 4),
                          CustomText(
                            text: "($reviewCount)",
                            color: const Color(0xFFD97706).withOpacity(0.6),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomText(
                        text: "No reviews yet",
                        color: Colors.grey.shade600,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),

            // Favorite Button
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  color: Color(0xFFEF4444),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
