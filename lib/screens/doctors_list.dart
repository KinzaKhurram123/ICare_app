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
      '🔍 Filtering doctors: query="$_searchQuery", spec=$_selectedSpecialization',
    );
    setState(() {
      _filteredDoctors = _doctors.where((doctor) {
        final matchesSearch =
            _searchQuery.isEmpty ||
            doctor.user.name.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            (doctor.specialization?.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ??
                false);

        final matchesSpecialization =
            _selectedSpecialization == null ||
            doctor.specialization == _selectedSpecialization;

        return matchesSearch && matchesSpecialization;
      }).toList();
      debugPrint('✅ Filtered to ${_filteredDoctors.length} doctors');
    });
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
                    children: [
                      // Search Bar
                      TextField(
                        onChanged: (value) {
                          _searchQuery = value;
                          _filterDoctors();
                        },
                        decoration: InputDecoration(
                          hintText: 'Search doctors by name or specialization',
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
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                      ),
                      if (_specializations.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        // Specialization Filter
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                label: const Text('All'),
                                selected: _selectedSpecialization == null,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedSpecialization = null;
                                    _filterDoctors();
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              ..._specializations.map(
                                (spec) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(spec),
                                    selected: _selectedSpecialization == spec,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedSpecialization = selected
                                            ? spec
                                            : null;
                                        _filterDoctors();
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
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
