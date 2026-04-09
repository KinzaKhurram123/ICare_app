import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icare/services/medical_record_service.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:intl/intl.dart';

class PatientPrescriptions extends ConsumerStatefulWidget {
  const PatientPrescriptions({super.key});

  @override
  ConsumerState<PatientPrescriptions> createState() =>
      _PatientPrescriptionsState();
}

class _PatientPrescriptionsState extends ConsumerState<PatientPrescriptions> {
  final MedicalRecordService _medicalRecordService = MedicalRecordService();
  List<dynamic> _prescriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    setState(() => _isLoading = true);
    try {
      final result = await _medicalRecordService.getMyRecords();

      if (result['success'] && mounted) {
        final records = result['records'] as List<dynamic>;
        final prescriptions = records.where((r) {
          final prescriptionObj = r['prescription'];
          if (prescriptionObj is Map) {
            final meds = prescriptionObj['medicines'] as List?;
            return meds != null && meds.isNotEmpty;
          }
          return false;
        }).toList();

        setState(() {
          _prescriptions = prescriptions;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading prescriptions: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: const Text(
          'My Prescriptions',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Gilroy-Bold',
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _prescriptions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medication_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No prescriptions yet',
                    style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPrescriptions,
              child: ListView.builder(
                padding: EdgeInsets.all(isDesktop ? 40 : 20),
                itemCount: _prescriptions.length,
                itemBuilder: (context, index) {
                  return _buildPrescriptionCard(_prescriptions[index]);
                },
              ),
            ),
    );
  }

  Widget _buildPrescriptionCard(dynamic record) {
    final date = DateTime.parse(record['createdAt']);
    final diagnosis = record['diagnosis'] ?? 'General Prescription';
    final doctorName = record['doctor']?['name'] ?? 'Unknown Doctor';
    final medicines = record['prescription']?['medicines'] as List? ?? [];
    final pharmacyOrder = record['pharmacyOrder'];
    final orderStatus = pharmacyOrder?['status'] ?? 'not_ordered';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFEAB308)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.medication_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        diagnosis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dr. $doctorName',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Medications',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                ...medicines.map((med) => _buildMedicineItem(med)),
                if (pharmacyOrder != null) ...[
                  const SizedBox(height: 16),
                  _buildStatusTimeline(orderStatus),
                  const SizedBox(height: 12),
                  if (pharmacyOrder['pharmacy'] != null)
                    _buildPharmacyInfo(pharmacyOrder['pharmacy']),
                ],
                const SizedBox(height: 16),
                if (orderStatus == 'not_ordered')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Prescription sent to pharmacy for fulfillment!',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.shopping_cart_checkout_rounded,
                        size: 20,
                      ),
                      label: const Text(
                        'Fulfill via Pharmacy',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEAB308),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(String currentStatus) {
    final statuses = ['pending', 'preparing', 'dispatched', 'delivered'];
    final currentIndex = statuses.indexOf(currentStatus);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Status',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(statuses.length, (index) {
              final isActive = index <= currentIndex;
              final isCurrent = index == currentIndex;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFEAB308)
                                  : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getStatusIcon(statuses[index]),
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getStatusLabel(statuses[index]),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isCurrent
                                  ? FontWeight.w900
                                  : FontWeight.w600,
                              color: isActive
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF94A3B8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    if (index < statuses.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isActive
                              ? const Color(0xFFEAB308)
                              : Colors.grey.shade300,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyInfo(dynamic pharmacy) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_pharmacy_rounded,
            color: Colors.blue.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pharmacy['name'] ?? 'Pharmacy',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade900,
                  ),
                ),
                if (pharmacy['phone'] != null)
                  Text(
                    pharmacy['phone'],
                    style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'preparing':
        return Icons.science_rounded;
      case 'dispatched':
        return Icons.local_shipping_rounded;
      case 'delivered':
        return Icons.check_circle_rounded;
      default:
        return Icons.circle;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'preparing':
        return 'Preparing';
      case 'dispatched':
        return 'Dispatched';
      case 'delivered':
        return 'Delivered';
      default:
        return status;
    }
  }

  Widget _buildMedicineItem(dynamic medicine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  medicine['name'] ?? 'Medicine',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMedicineDetail('Dosage', medicine['dosage'] ?? 'N/A'),
                _buildMedicineDetail(
                  'Frequency',
                  medicine['frequency'] ?? 'N/A',
                ),
                _buildMedicineDetail('Duration', medicine['duration'] ?? 'N/A'),
                if (medicine['instructions'] != null)
                  _buildMedicineDetail(
                    'Instructions',
                    medicine['instructions'],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
