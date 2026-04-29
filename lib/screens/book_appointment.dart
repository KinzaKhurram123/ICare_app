import 'package:flutter/material.dart';
import 'package:icare/models/doctor.dart';
import 'package:icare/services/appointment_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:intl/intl.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key, required this.doctor});
  final Doctor doctor;

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  final PageController _datePageController = PageController();

  // Date selection
  late List<DateTime> _dateRange;
  int _selectedDateIndex = 0;

  // Time slot selection
  String? _selectedSlot;

  // Step: 0 = slot selection, 1 = reviews, 2 = checkout
  int _step = 0;

  bool _isBooking = false;
  bool _appointmentForMyself = true; // toggle between Myself / Someone else
  final _nameController = TextEditingController();
  final _reasonController = TextEditingController();

  // Morning slots 9:00 AM - 11:45 AM (15 min intervals)
  final List<String> _morningSlots = [
    '09:00 AM', '09:15 AM', '09:30 AM', '09:45 AM',
    '10:00 AM', '10:15 AM', '10:30 AM', '10:45 AM',
    '11:00 AM', '11:15 AM', '11:30 AM', '11:45 AM',
  ];

  // Afternoon slots 12:00 PM - 01:45 PM
  final List<String> _afternoonSlots = [
    '12:00 PM', '12:15 PM', '12:30 PM', '12:45 PM',
    '01:00 PM', '01:15 PM', '01:30 PM', '01:45 PM',
  ];

  // Dummy reviews
  final List<Map<String, String>> _reviews = [
    {'text': 'Consultation was good', 'patient': 'Verified Patient F', 'ago': '18 days ago'},
    {'text': 'Quickly respond the call and guide properly', 'patient': 'Verified Patient F', 'ago': '19 days ago'},
    {'text': 'I was extremely satisfied with my consultation. The doctor was extremely attentive to listening to my issues and had extremely professional and practical advice.', 'patient': 'Verified Patient U', 'ago': '19 days ago'},
  ];

  @override
  void initState() {
    super.initState();
    // Generate next 8 days
    final today = DateTime.now();
    _dateRange = List.generate(8, (i) => today.add(Duration(days: i)));
  }

  @override
  void dispose() {
    _datePageController.dispose();
    _nameController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  DateTime get _selectedDate => _dateRange[_selectedDateIndex];

  Future<void> _confirmBooking() async {
    if (_selectedSlot == null) return;
    setState(() => _isBooking = true);

    final result = await _appointmentService.bookAppointment(
      doctorId: widget.doctor.id,
      date: _selectedDate,
      timeSlot: _selectedSlot!,
      reason: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
    );

    setState(() => _isBooking = false);
    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('Appointment booked successfully!'),
          ]),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Booking failed'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.primaryColor),
                onPressed: () => setState(() => _step--),
              )
            : const CustomBackButton(),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _step == 2 ? 'Checkout' : 'Book Appointment',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
        ),
      ),
      body: _step == 0
          ? _buildSlotSelection()
          : _step == 1
              ? _buildReviews()
              : _buildCheckout(),
    );
  }

  // ── STEP 0: Date + Slot Selection ─────────────────────────────────────────
  Widget _buildSlotSelection() {
    final fee = widget.doctor.consultationFee;
    return SingleChildScrollView(
      child: Column(
        children: [
          // Doctor info card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  child: Text(
                    widget.doctor.user.name.isNotEmpty
                        ? widget.doctor.user.name.substring(0, 1).toUpperCase()
                        : 'D',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dr. ${widget.doctor.user.name}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      Text(widget.doctor.specialization ?? 'General Physician',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      if (fee != null && fee > 0)
                        Text('Fee: Rs. ${fee.toInt()}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Date strip
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: _selectedDateIndex > 0
                      ? () => setState(() => _selectedDateIndex--)
                      : null,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_dateRange.length, (i) {
                        final d = _dateRange[i];
                        final isSelected = i == _selectedDateIndex;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedDateIndex = i;
                            _selectedSlot = null;
                          }),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryColor : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  DateFormat('MMM').format(d),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected ? Colors.white70 : const Color(0xFF94A3B8),
                                  ),
                                ),
                                Text(
                                  DateFormat('dd').format(d),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  DateFormat('EEE').format(d),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected ? Colors.white70 : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: _selectedDateIndex < _dateRange.length - 1
                      ? () => setState(() => _selectedDateIndex++)
                      : null,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Morning Slots
          _buildSlotSection('Morning Slots', Icons.wb_sunny_outlined, _morningSlots),
          const SizedBox(height: 8),

          // Afternoon Slots
          _buildSlotSection('Afternoon Slots', Icons.wb_twilight_outlined, _afternoonSlots),

          const SizedBox(height: 24),

          // Continue to Book button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _selectedSlot != null ? () => setState(() => _step = 1) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Continue to Book', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSlotSection(String title, IconData icon, List<String> slots) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: slots.map((slot) {
              final isSelected = _selectedSlot == slot;
              return GestureDetector(
                onTap: () => setState(() => _selectedSlot = slot),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryColor : const Color(0xFFE2E8F0),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    slot,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── STEP 1: Reviews ────────────────────────────────────────────────────────
  Widget _buildReviews() {
    final averageRating = widget.doctor.averageRating;
    final reviewCount = widget.doctor.reviewCount;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Trust badge
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_rounded, color: Color(0xFFF59E0B), size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('95% patients feel satisfied after booking',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF92400E))),
                      Text('It takes only 30 sec to book an appointment',
                          style: TextStyle(fontSize: 12, color: Color(0xFFB45309))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Reviews header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Reviews About Dr. ${widget.doctor.user.name} ($reviewCount)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Review cards
          ..._reviews.map((r) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.thumb_up_outlined, size: 16, color: Color(0xFF3B82F6)),
                    SizedBox(width: 6),
                    Text('I recommend the doctor',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  ],
                ),
                const SizedBox(height: 8),
                Text('" ${r['text']} "',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
                const SizedBox(height: 8),
                Text('${r['patient']} • ${r['ago']}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          )),

          const SizedBox(height: 24),

          // Continue to Book button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => setState(() => _step = 2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Continue to Book', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── STEP 2: Checkout ───────────────────────────────────────────────────────
  Widget _buildCheckout() {
    final fee = widget.doctor.consultationFee ?? 0;
    final dateStr = DateFormat('MMM dd').format(_selectedDate);
    final bool isDesktop = Utils.windowWidth(context) > 700;

    final summaryCard = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor mini card
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                child: Text(
                  widget.doctor.user.name.isNotEmpty
                      ? widget.doctor.user.name.substring(0, 1).toUpperCase()
                      : 'D',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dr. ${widget.doctor.user.name}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    Text(widget.doctor.specialization ?? 'General Physician',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),

          // Date + time
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text('$dateStr, $_selectedSlot',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 8),

          // Consultation type + fee
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Consultation Fee', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              Text(
                fee > 0 ? 'Rs. ${fee.toInt()}' : 'To be confirmed',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: fee > 0 ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Confirm button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isBooking ? null : _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: _isBooking
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Confirm Booking', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );

    final formCard = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Appointment For
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Appointment For',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              const SizedBox(height: 12),
              Row(
                children: [
                  _forChip('Myself', _appointmentForMyself, () => setState(() => _appointmentForMyself = true)),
                  const SizedBox(width: 10),
                  _forChip('+ Someone else', !_appointmentForMyself, () => setState(() => _appointmentForMyself = false)),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Patient Name',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF94A3B8)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.primaryColor)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Reason (optional)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Describe your symptoms...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.primaryColor)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Payment method
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Payment Method',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              const SizedBox(height: 12),
              // Online Payment option
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.radio_button_checked_rounded, color: AppColors.primaryColor, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(child: Text('Online Payment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
                    if (fee > 0)
                      Text('Rs. ${fee.toInt()}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Pay at Clinic option
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.radio_button_unchecked_rounded, color: Color(0xFF94A3B8), size: 20),
                    const SizedBox(width: 10),
                    const Expanded(child: Text('Pay at Clinic', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B)))),
                    if (fee > 0)
                      Text('Rs. ${fee.toInt()}',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              if (fee == 0) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B), size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Consultation fee will be confirmed by the doctor.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    if (isDesktop) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: formCard),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: summaryCard),
          ],
        ),
      );
    }

    // Mobile: stacked layout
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          summaryCard,
          const SizedBox(height: 16),
          formCard,
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _forChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(Icons.check_rounded, size: 14, color: AppColors.primaryColor),
            if (isSelected) const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primaryColor : const Color(0xFF64748B),
                )),
          ],
        ),
      ),
    );
  }
}
