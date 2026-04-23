import 'package:flutter/material.dart';
import 'package:icare/models/doctor.dart';
import 'package:icare/models/user.dart';
import 'package:icare/screens/book_appointment.dart';
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
  String? _selectedCondition;
  Set<String> _specializations = {};

  // Common conditions mapped to specializations
  static const Map<String, String> _conditionToSpec = {
    'Heart Disease': 'Cardiologist',
    'Diabetes': 'Endocrinologist',
    'Skin Problems': 'Dermatologist',
    'Mental Health': 'Psychiatrist',
    'Bone & Joint': 'Orthopedic',
    'Eye Problems': 'Ophthalmologist',
    'Child Health': 'Pediatrician',
    'Pregnancy': 'Gynecologist',
    'Kidney Disease': 'Nephrologist',
    'Digestive Issues': 'Gastroenterologist',
    'Neurological': 'Neurologist',
    'General': 'General Practitioner',
  };

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

      final specs = doctorsList
          .where((d) => d.specialization != null && d.specialization!.isNotEmpty)
          .map((d) => d.specialization!)
          .toSet();

      setState(() {
        _doctors = doctorsList;
        _filteredDoctors = doctorsList;
        _specializations = {"General Practitioner", ...(specs.toList()..sort())};
        _isLoading = false;
      });
    } else {
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
    setState(() {
      _filteredDoctors = _doctors.where((doctor) {
        final matchesSearch =
            _searchQuery.isEmpty ||
            doctor.user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (doctor.specialization?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        final conditionSpec = _selectedCondition != null
            ? _conditionToSpec[_selectedCondition!]?.toLowerCase()
            : null;

        final matchesSpecialization =
            _selectedSpecialization == null ||
            doctor.specialization == _selectedSpecialization;

        final matchesCondition = conditionSpec == null ||
            (doctor.specialization?.toLowerCase().contains(conditionSpec) ?? false);

        return matchesSearch && matchesSpecialization && matchesCondition;
      }).toList();
    });
  }

  Widget _conditionChip(String? value, String label) {
    final isSelected = _selectedCondition == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCondition = value;
          _selectedSpecialization = null;
          _filterDoctors();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
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
                // Online count badge
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${_doctors.length + 5} doctors online right now",
                            style: const TextStyle(
                              color: Color(0xFF166534),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
                          hintText: 'Search by Doctor Name or Condition...',
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                        ),
                      ),
                      if (_specializations.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedSpecialization,
                          decoration: InputDecoration(
                            hintText: 'Filter by Speciality',
                            prefixIcon: const Icon(Icons.medical_services_outlined, color: Color(0xFF94A3B8)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: const Color(0xFFF1F5F9),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Specialities')),
                            ..._specializations.map((spec) => DropdownMenuItem(value: spec, child: Text(spec))),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedSpecialization = value;
                              _selectedCondition = null; // clear condition when spec changes
                              _filterDoctors();
                            });
                          },
                        ),
                      ],
                      const SizedBox(height: 12),
                      // Condition filter — horizontal scrollable chips
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _conditionChip(null, 'All'),
                            ..._conditionToSpec.keys.map((c) => _conditionChip(c, c)),
                          ],
                        ),
                      ),
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
                      : ListView.builder(
                          itemCount: _filteredDoctors.length,
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 40 : 20,
                            vertical: 24,
                          ),
                          itemBuilder: (ctx, i) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: DoctorProfileCard(
                                doctor: _filteredDoctors[i],
                              ),
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

    final double averageRating = 4.8; 
    final int reviewCount = 355; 
    final String experienceYears = displayDoctor.experience ?? "11+ Years";
    final int consultationFee = 1200; 

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => BookAppointmentScreen(doctor: displayDoctor),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    _buildAvatar(displayDoctor),
                    const SizedBox(width: 20),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  displayDoctor.user.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1E293B),
                                    fontFamily: "Gilroy-Bold",
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _platinumBadge(),
                            ],
                          ),
                          const SizedBox(height: 6),
                          _verifiedBadge(),
                          if ((displayDoctor.pmdcNumber ?? '').isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.badge_outlined, size: 13, color: Color(0xFF3B82F6)),
                                const SizedBox(width: 4),
                                Text(
                                  'PMDC: ${displayDoctor.pmdcNumber}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            displayDoctor.specialization ?? "General Physician, Consultant",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayDoctor.degrees.join(', ').isNotEmpty 
                                ? displayDoctor.degrees.join(', ')
                                : "MBBS, MCPS (Family Medicine)",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _infoBlock(experienceYears, "Experience"),
                              const SizedBox(width: 24),
                              _infoBlock("⭐ $averageRating", "$reviewCount Reviews"),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Actions
                    Column(
                      children: [
                        _actionButton(
                          "Video Consultation",
                          const Color(0xFF1E293B),
                          Colors.white,
                          Icons.videocam_rounded,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => BookAppointmentScreen(doctor: displayDoctor),
                              ),
                            );
                          },
                          isOutline: true,
                        ),
                        const SizedBox(height: 12),
                        _actionButton(
                          "Book Appointment",
                          Colors.white,
                          AppColors.primaryColor, // Use primary blue
                          null,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => BookAppointmentScreen(doctor: displayDoctor),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Bottom Consultation Section
                _consultationBanner(consultationFee),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Doctor displayDoctor) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF1F5F9), width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: ClipOval(
        child: displayDoctor.user.profilePicture != null &&
                displayDoctor.user.profilePicture!.isNotEmpty
            ? Image.network(
                displayDoctor.user.profilePicture!,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) =>
                    _buildPlaceholderAvatar(displayDoctor),
              )
            : _buildPlaceholderAvatar(displayDoctor),
      ),
    );
  }

  Widget _platinumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 12),
          SizedBox(width: 4),
          Text(
            "PLATINUM DOCTOR",
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(width: 4),
          Icon(Icons.info_outline, color: Colors.white70, size: 10),
        ],
      ),
    );
  }

  Widget _verifiedBadge() {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 16),
        const SizedBox(width: 4),
        const Text(
          "PMDC Verified",
          style: TextStyle(
            color: Color(0xFF166534),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _infoBlock(String top, String bottom) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          top,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          bottom,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _actionButton(String label, Color textColor, Color bgColor, IconData? icon, {bool isOutline = false, VoidCallback? onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 160,
        height: 44,
        decoration: BoxDecoration(
          color: isOutline ? Colors.transparent : bgColor,
          borderRadius: BorderRadius.circular(10),
          border: isOutline ? Border.all(color: textColor.withValues(alpha: 0.5)) : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: textColor, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _consultationBanner(int fee) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.videocam_rounded, color: Color(0xFF1E293B), size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Online Video Consultation",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.circle, color: Color(0xFF22C55E), size: 8),
                  const SizedBox(width: 6),
                  Text(
                    "Available tomorrow",
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF166534).withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(
            "Rs. $fee",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderAvatar(Doctor displayDoctor) {
    return Container(
      width: 100,
      height: 100,
      color: AppColors.primaryColor.withValues(alpha: 0.1),
      child: Center(
        child: Text(
          displayDoctor.user.name.isNotEmpty
              ? displayDoctor.user.name.substring(0, 1).toUpperCase()
              : 'D',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}
