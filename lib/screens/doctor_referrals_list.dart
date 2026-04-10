import 'package:flutter/material.dart';
import 'package:icare/models/user.dart';
import 'package:icare/models/referral.dart';
import 'package:icare/services/referral_service.dart';
import 'package:icare/services/patient_service.dart'; 
import 'package:icare/screens/create_referral_screen.dart';
import 'package:icare/screens/referral_detail_screen.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:intl/intl.dart';

class DoctorReferralsListScreen extends StatefulWidget {
  const DoctorReferralsListScreen({super.key});

  @override
  State<DoctorReferralsListScreen> createState() =>
      _DoctorReferralsListScreenState();
}

class _DoctorReferralsListScreenState extends State<DoctorReferralsListScreen>
    with SingleTickerProviderStateMixin {
  final ReferralService _referralService = ReferralService();
  final PatientService _patientService = PatientService();
  late TabController _tabController;

  List<Referral> _sentReferrals = [];
  List<Referral> _receivedReferrals = [];
  bool _isLoadingSent = true;
  bool _isLoadingReceived = true;
  List<User> _patients = [];
  bool _isLoadingPatients = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReferrals();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoadingPatients = true);
    try {
      // Fetch patients list - adjust based on your API
      final result = await _patientService.getMyPatients();
      if (result['success']) {
        setState(() {
          _patients = result['patients'];
        });
      }
    } catch (e) {
      print('Error loading patients: $e');
    }
    setState(() => _isLoadingPatients = false);
  }

  Future<void> _loadReferrals() async {
    setState(() {
      _isLoadingSent = true;
      _isLoadingReceived = true;
    });

    // Load sent referrals
    final sentResult = await _referralService.getMyReferrals();
    if (sentResult['success']) {
      setState(() {
        _sentReferrals = sentResult['referrals'];
        _isLoadingSent = false;
      });
    } else {
      setState(() => _isLoadingSent = false);
    }

    // Load received referrals
    final receivedResult = await _referralService.getReceivedReferrals();
    if (receivedResult['success']) {
      setState(() {
        _receivedReferrals = receivedResult['referrals'];
        _isLoadingReceived = false;
      });
    } else {
      setState(() => _isLoadingReceived = false);
    }
  }

  Future<void> _showPatientSelectionDialog() async {
    if (_patients.isEmpty) {
      // Show message if no patients
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No patients found. Please add patients first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Patient',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _patients.length,
                  itemBuilder: (context, index) {
                    final patient = _patients[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                        child: Text(
                          patient.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      title: Text(
                        patient.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(patient.email),
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToCreateReferral(patient);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _navigateToCreateReferral(User patient) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateReferralScreen(
          patient: patient,
          appointmentId: null, // Optional, can be null
        ),
      ),
    );
    if (result == true) {
      _loadReferrals();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const CustomBackButton(),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Referrals',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Gilroy-Bold',
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryColor,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sent'),
                  if (_sentReferrals.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_sentReferrals.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Received'),
                  if (_receivedReferrals.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_receivedReferrals.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSentReferralsTab(), _buildReceivedReferralsTab()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoadingPatients ? null : _showPatientSelectionDialog,
        backgroundColor: AppColors.primaryColor,
        icon: _isLoadingPatients
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.add),
        label: const Text('New Referral'),
      ),
    );
  }

  Widget _buildSentReferralsTab() {
    if (_isLoadingSent) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_sentReferrals.isEmpty) {
      return _buildEmptyState(
        icon: Icons.send_outlined,
        title: 'No Sent Referrals',
        message: 'You haven\'t sent any referrals yet',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReferrals,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sentReferrals.length,
        itemBuilder: (context, index) {
          return _buildReferralCard(_sentReferrals[index], isSent: true);
        },
      ),
    );
  }

  Widget _buildReceivedReferralsTab() {
    if (_isLoadingReceived) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_receivedReferrals.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox_outlined,
        title: 'No Received Referrals',
        message: 'You haven\'t received any referrals yet',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReferrals,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _receivedReferrals.length,
        itemBuilder: (context, index) {
          return _buildReferralCard(_receivedReferrals[index], isSent: false);
        },
      ),
    );
  }

  Widget _buildReferralCard(Referral referral, {required bool isSent}) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (referral.status) {
      case 'pending':
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.schedule;
        statusText = 'Pending';
        break;
      case 'accepted':
        statusColor = const Color(0xFF3B82F6);
        statusIcon = Icons.check_circle_outline;
        statusText = 'Accepted';
        break;
      case 'completed':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        break;
      case 'declined':
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.cancel_outlined;
        statusText = 'Declined';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusText = 'Unknown';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ReferralDetailScreen(referral: referral, isSent: isSent),
              ),
            );
            if (result == true) {
              _loadReferrals();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          referral.patient.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            referral.patient.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isSent
                                ? 'To: ${referral.referredToDoctor?.name ?? "Specialist"}'
                                : 'From: ${referral.referringDoctor.name}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reason',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        referral.reason,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(referral.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    if (referral.status == 'pending' && !isSent)
                      const Text(
                        'Action Required',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}