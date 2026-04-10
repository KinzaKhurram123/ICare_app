import 'package:flutter/material.dart';
import 'package:icare/services/clinical_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:intl/intl.dart';

class HealthJourneyScreen extends StatefulWidget {
  const HealthJourneyScreen({super.key});

  @override
  State<HealthJourneyScreen> createState() => _HealthJourneyScreenState();
}

class _HealthJourneyScreenState extends State<HealthJourneyScreen> {
  final ClinicalService _clinicalService = ClinicalService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _timelineItems = [];

  @override
  void initState() {
    super.initState();
    _loadJourney();
  }

  Future<void> _loadJourney() async {
    setState(() => _isLoading = true);

    try {
      final timeline = await _clinicalService.getHealthJourney();

      if (mounted) {
        setState(() {
          _timelineItems = timeline.map((item) {
            final type = item['type'] ?? 'appointment';
            return {
              'type': type,
              'title': item['title'] ?? 'Health Event',
              'date': DateTime.parse(
                item['date'] ?? DateTime.now().toIso8601String(),
              ),
              'description': item['description'] ?? '',
              'icon': _getIconForType(type),
              'color': _getColorForType(type),
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Unable to load data. Please try again.')),
        );
      }
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'appointment':
        return Icons.video_call_rounded;
      case 'prescription':
        return Icons.medication_rounded;
      case 'lab':
        return Icons.biotech_rounded;
      case 'course':
        return Icons.health_and_safety_rounded;
      case 'medical_record':
        return Icons.assignment_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'appointment':
        return Colors.blue;
      case 'prescription':
        return Colors.purple;
      case 'lab':
        return Colors.orange;
      case 'course':
        return Colors.green;
      case 'medical_record':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: const Text(
          'My Health Journey',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _timelineItems.isEmpty
          ? _buildEmptyState()
          : _buildTimeline(),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('No health events recorded yet.'));
  }

  Widget _buildTimeline() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _timelineItems.length,
      itemBuilder: (context, index) {
        final item = _timelineItems[index];
        final isLast = index == _timelineItems.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: item['color'].withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(item['icon'], color: item['color'], size: 24),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 80,
                    color: const Color(0xFFE2E8F0),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMMM dd, yyyy • hh:mm a').format(item['date']),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['description'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildActionLink(item['type']),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionLink(String type) {
    String label = 'View Details';
    if (type == 'prescription') label = 'View Prescription';
    if (type == 'lab') label = 'View Lab Request';
    if (type == 'course') label = 'Start Program';

    return InkWell(
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.arrow_forward_rounded,
            color: AppColors.primaryColor,
            size: 14,
          ),
        ],
      ),
    );
  }
}
