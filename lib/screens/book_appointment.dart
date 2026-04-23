import 'package:flutter/material.dart';
import 'package:icare/models/doctor.dart';
import 'package:icare/services/appointment_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/screens/select_payment_method.dart';
import 'package:icare/screens/booking_checkout.dart';
import 'package:icare/screens/login.dart';
import 'package:icare/utils/shared_pref.dart';
import 'package:intl/intl.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key, required this.doctor});

  final Doctor doctor;

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  final ScrollController _scrollController = ScrollController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  bool _isBooking = false;

  late List<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    _dates = List.generate(30, (index) => DateTime.now().add(Duration(days: index)));
    _selectedDate = _dates.firstWhere((d) => _isDayAvailable(d), orElse: () => _dates.first);
  }

  bool _isDayAvailable(DateTime date) {
    if (widget.doctor.availableDays.isEmpty) return true;
    final dayName = DateFormat('EEEE').format(date);
    return widget.doctor.availableDays.contains(dayName);
  }

  List<String> _getAvailableTimeSlots() {
    if (widget.doctor.availableTime != null) {
      final startTime = widget.doctor.availableTime!.start;

      return [
        '$startTime',
        _incrementTime(startTime, 1),
        _incrementTime(startTime, 2),
        _incrementTime(startTime, 3),
        _incrementTime(startTime, 4),
        _incrementTime(startTime, 5),
      ];
    }

    return [
      '09:00 AM',
      '09:15 AM',
      '09:30 AM',
      '09:45 AM',
      '10:00 AM',
      '10:15 AM',
      '10:30 AM',
      '10:45 AM',
      '11:00 AM',
      '11:15 AM',
      '11:30 AM',
      '11:45 AM',
      '12:00 PM',
      '12:15 PM',
      '12:30 PM',
      '12:45 PM',
      '01:00 PM',
      '01:15 PM',
      '01:30 PM',
      '01:45 PM',
    ];
  }

  String _incrementTime(String time, int hours) {
    try {
      if (!time.contains('AM') && !time.contains('PM')) {
        final timeParts = time.split(':');
        int hour = int.parse(timeParts[0]);
        final minute = timeParts.length > 1 ? timeParts[1] : '00';
        hour += hours;
        if (hour >= 24) hour -= 24;
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        return '${displayHour.toString().padLeft(2, '0')}:$minute $period';
      }
      final parts = time.split(' ');
      if (parts.length < 2) return time;
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final minute = timeParts.length > 1 ? timeParts[1] : '00';
      final period = parts[1];
      hour += hours;
      if (hour > 12) hour -= 12;
      return '${hour.toString().padLeft(2, '0')}:$minute $period';
    } catch (e) {
      return time;
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time slot'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if user is logged in
    final token = await SharedPref().getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to book an appointment'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookingCheckoutScreen(
          doctor: widget.doctor,
          selectedDate: _selectedDate,
          selectedTime: _selectedTimeSlot!,
        ),
      ),
    );
  }

  void _scrollDates(bool forward) {
    final offset = _scrollController.offset + (forward ? 200 : -200);
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Utils.windowWidth(context) > 600;
    final allSlots = _getAvailableTimeSlots();
    final morningSlots = allSlots.where((t) => t.contains('AM')).toList();
    final afternoonSlots = allSlots.where((t) => t.contains('PM')).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const CustomBackButton(),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Book Appointment",
          style: TextStyle(
            fontFamily: "Gilroy-Bold",
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Doctor Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                          child: Text(
                            widget.doctor.user.name.isNotEmpty
                                ? widget.doctor.user.name.substring(0, 1).toUpperCase()
                                : 'D',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Dr. ${widget.doctor.user.name}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Online Video Consultation",
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Gilroy-Bold',
                                ),
                                children: [
                                  const TextSpan(text: 'Fee: '),
                                  TextSpan(
                                    text: 'Rs. 1,200',
                                    style: const TextStyle(color: Color(0xFF1F2937)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Scheduler Component
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      // Dates row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left, color: Color(0xFF6B7280)),
                              onPressed: () => _scrollDates(false),
                            ),
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _dates.length,
                                  itemBuilder: (context, index) {
                                    final date = _dates[index];
                                    final isSelected = date.year == _selectedDate.year &&
                                        date.month == _selectedDate.month &&
                                        date.day == _selectedDate.day;
                                    final isAvailable = _isDayAvailable(date);

                                    return GestureDetector(
                                      onTap: isAvailable
                                          ? () {
                                              setState(() {
                                                _selectedDate = date;
                                                _selectedTimeSlot = null; // reset slot on new date
                                              });
                                            }
                                          : null,
                                      child: Container(
                                        width: 80,
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: isSelected ? AppColors.primaryColor : Colors.transparent,
                                              width: 3,
                                            ),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            DateFormat('MMM, dd').format(date),
                                            style: TextStyle(
                                              color: isSelected
                                                  ? AppColors.primaryColor
                                                  : (isAvailable ? const Color(0xFF4B5563) : Colors.grey.shade300),
                                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
                              onPressed: () => _scrollDates(true),
                            ),
                          ],
                        ),
                      ),
                      
                      Divider(height: 1, color: Colors.grey.shade200),

                      // Time slots
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (morningSlots.isNotEmpty) ...[
                              Row(
                                children: [
                                  const Icon(Icons.wb_sunny_outlined, size: 18, color: Color(0xFF9CA3AF)),
                                  const SizedBox(width: 12),
                                  const Text("Morning Slots", style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: morningSlots.map((slot) => _buildSlotCard(slot)).toList(),
                              ),
                              const SizedBox(height: 32),
                            ],
                            
                            if (afternoonSlots.isNotEmpty) ...[
                              Row(
                                children: [
                                  const Icon(Icons.wb_twilight, size: 18, color: Color(0xFF9CA3AF)),
                                  const SizedBox(width: 12),
                                  const Text("Afternoon Slots", style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: afternoonSlots.map((slot) => _buildSlotCard(slot)).toList(),
                              ),
                            ],
                            
                            if (allSlots.isEmpty) ...[
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32),
                                  child: Text("No slots available for this date.", style: TextStyle(color: Colors.grey)),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Bottom badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.security, size: 36, color: Colors.amber.shade700),
                        const Icon(Icons.check, size: 16, color: Colors.white),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "95% patients feel satisfied after booking appointment from oladoc",
                            style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF374151), fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "It takes only 30 sec to book an appointment",
                            style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // 3. Reviews Section
                _buildReviewsSection(),
                
                const SizedBox(height: 40),

                // Continue Button
                if (_selectedTimeSlot != null)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isBooking ? null : _bookAppointment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isBooking 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Continue to Book", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlotCard(String slot) {
    final isSelected = _selectedTimeSlot == slot;
    return InkWell(
      onTap: () => setState(() => _selectedTimeSlot = slot),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          slot,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? AppColors.primaryColor : const Color(0xFF1F2937),
          ),
        ),
      ),
    );
  }
  Widget _buildReviewsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Reviews About Dr. ${widget.doctor.user.name} (355)",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),
          _buildReviewCard(
            " Consultation was good ",
            "Verified Patient F",
            "18 days ago",
          ),
          const SizedBox(height: 16),
          _buildReviewCard(
            " Quickly respond the call and guide properly ",
            "Verified Patient F",
            "19 days ago",
          ),
          const SizedBox(height: 16),
          _buildReviewCard(
            " I was extremely satisfied with my consultation. The doctor was extremely attentive to listening to my issues and had extremely professional and practical advice and instructions on next steps to take regarding treatment to solve my medical concerns. ",
            "Verified Patient U",
            "19 days ago",
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String comment, String user, String date) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.thumb_up_alt_outlined, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              const Text(
                "I recommend the doctor",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"$comment"',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                user,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(" • ", style: TextStyle(color: Colors.grey)),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
