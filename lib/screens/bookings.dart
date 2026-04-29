import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/models/appointment_detail.dart';
import 'package:icare/screens/booking_categories.dart';
import 'package:icare/services/appointment_service.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key, this.tabs = false});
  final bool tabs;

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  List<AppointmentDetail> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    final result = await _appointmentService.getMyAppointmentsDetailed();
    if (result['success']) {
      setState(() {
        _appointments = result['appointments'] as List<AppointmentDetail>;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  int _getCount(String status) {
    if (status == 'Upcoming') {
      return _appointments
          .where(
            (a) =>
                a.status.toLowerCase() == 'pending' ||
                a.status.toLowerCase() == 'confirmed',
          )
          .length;
    }
    if (status == 'In Progress') {
      return _appointments
          .where((a) => a.status.toLowerCase() == 'in_progress')
          .length;
    }
    return _appointments
        .where((a) => a.status.toLowerCase() == status.toLowerCase())
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Utils.windowWidth(context) > 600;
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Map<String, dynamic>> bookingMenu = [
      {
        "id": 1,
        "title": "In Progress Bookings",
        "subtitle": "Currently active appointments",
        "icon": Icons.play_circle_outline_rounded,
        "color": const Color(0xFF3B82F6),
        "bgColor": const Color(0xFF3B82F6).withOpacity(0.08),
        "count": _getCount('In Progress').toString(),
        "image": ImagePaths.inProgress,
        "onPressed": () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => BookingCategories(
                appointments: _appointments,
                initialTabIndex: 0,
              ),
            ),
          );
        },
      },
      {
        "id": 2,
        "title": "Upcoming Bookings",
        "subtitle": "Scheduled for later",
        "icon": Icons.schedule_rounded,
        "color": const Color(0xFF14B1FF),
        "bgColor": const Color(0xFF14B1FF).withOpacity(0.08),
        "count": _getCount('Upcoming').toString(),
        "image": ImagePaths.upcoming,
        "onPressed": () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => BookingCategories(
                appointments: _appointments,
                initialTabIndex: 1,
              ),
            ),
          );
        },
      },
      {
        "id": 3,
        "title": "Cancelled Bookings",
        "subtitle": "Appointments you cancelled",
        "icon": Icons.cancel_outlined,
        "color": const Color(0xFFEF4444),
        "bgColor": const Color(0xFFEF4444).withOpacity(0.08),
        "count": _getCount('Cancelled').toString(),
        "image": ImagePaths.cancelled,
        "onPressed": () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => BookingCategories(
                appointments: _appointments,
                initialTabIndex: 2,
              ),
            ),
          );
        },
      },
      {
        "id": 4,
        "title": "Completed Bookings",
        "subtitle": "Past successful visits",
        "icon": Icons.check_circle_outline_rounded,
        "color": const Color(0xFF22C55E),
        "bgColor": const Color(0xFF22C55E).withOpacity(0.08),
        "count": _getCount('Completed').toString(),
        "image": ImagePaths.completed,
        "onPressed": () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => BookingCategories(
                appointments: _appointments,
                initialTabIndex: 3,
              ),
            ),
          );
        },
      },
      {
        "id": 5,
        "title": "Pending Bookings",
        "subtitle": "Awaiting confirmation",
        "icon": Icons.hourglass_empty_rounded,
        "color": const Color(0xFFF59E0B),
        "bgColor": const Color(0xFFF59E0B).withOpacity(0.08),
        "count": _getCount('Pending').toString(),
        "image": ImagePaths.pending,
        "onPressed": () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => BookingCategories(
                appointments: _appointments,
                initialTabIndex: 1,
              ),
            ),
          );
        },
      },
    ];

    // ─── MOBILE: original design ────────────────────────────────────────────
    if (!isDesktop) {
      return Material(
        child: Container(
          width: Utils.windowWidth(context),
          height: Utils.windowHeight(context),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bgImage.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(top: ScallingConfig.verticalScale(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(height: ScallingConfig.scale(20)),
                if (!widget.tabs)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [CustomBackButton()],
                  ),
                SizedBox(height: ScallingConfig.scale(20)),
                Center(
                  child: CustomText(
                    text: "Bookings Hsitory",
                    fontSize: 25.27,
                    padding: EdgeInsets.only(
                      left: ScallingConfig.moderateScale(12),
                    ),
                    color: AppColors.themeBlue,
                    fontWeight: FontWeight.w700,
                    isBold: true,
                  ),
                ),
                Center(
                  child: CustomText(
                    text:
                        "Stay on top of your schedule with real-time updates on patient bookings.",
                    padding: EdgeInsets.only(
                      top: ScallingConfig.verticalScale(10),
                      left: ScallingConfig.moderateScale(12),
                    ),
                    width: Utils.windowWidth(context) * 0.8,
                    textAlign: TextAlign.center,
                    fontSize: 12.60,
                    maxLines: 2,
                    isSemiBold: true,
                  ),
                ),
                SizedBox(height: ScallingConfig.scale(20)),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        clipBehavior: Clip.hardEdge,
                        width: Utils.windowWidth(context),
                        padding: EdgeInsets.symmetric(
                          horizontal: ScallingConfig.scale(10),
                          vertical: ScallingConfig.verticalScale(20),
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.bgColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                        ),
                        child: Center(
                          child: ListView.builder(
                            padding: EdgeInsets.only(
                              left: ScallingConfig.scale(10),
                              right: ScallingConfig.scale(10),
                            ),
                            itemCount: bookingMenu.length,
                            itemBuilder: (ctx, i) {
                              final item = bookingMenu[i];
                              return BookingCategoryCard(
                                title: item["title"],
                                onPressed: item["onPressed"],
                                image: item["image"],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ─── DESKTOP: premium design ────────────────────────────────────────────
    return Material(
      child: Container(
        width: Utils.windowWidth(context),
        height: Utils.windowHeight(context),
        color: const Color(0xFFF8FAFC),
        child: Column(
          children: [
            // Premium dark header
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 32,
                left: 48,
                right: 48,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F172A), Color(0xFF1E3A5F)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    children: [
                      if (!widget.tabs)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomText(
                        text: "Bookings History",
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                      const SizedBox(height: 8),
                      CustomText(
                        text:
                            "Stay on top of your schedule with real-time updates",
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w400,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatChip(
                            _appointments.length.toString(),
                            "Total",
                            Colors.white,
                          ),
                          const SizedBox(width: 12),
                          _buildStatChip(
                            _getCount('In Progress').toString(),
                            "Active",
                            const Color(0xFF3B82F6),
                          ),
                          const SizedBox(width: 12),
                          _buildStatChip(
                            _getCount('Completed').toString(),
                            "Done",
                            const Color(0xFF22C55E),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Cards list
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    itemCount: bookingMenu.length,
                    itemBuilder: (ctx, i) {
                      final item = bookingMenu[i];
                      return _PremiumBookingCard(
                        title: item["title"],
                        subtitle: item["subtitle"],
                        icon: item["icon"],
                        color: item["color"],
                        bgColor: item["bgColor"],
                        count: item["count"],
                        onPressed: item["onPressed"],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: "Gilroy",
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: "Gilroy",
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Original mobile card ────────────────────────────────────────────────────
class BookingCategoryCard extends StatelessWidget {
  const BookingCategoryCard({
    super.key,
    this.title,
    this.image,
    this.onPressed,
  });
  final String? title;
  final Function()? onPressed;
  final String? image;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.only(top: ScallingConfig.scale(5)),
        padding: EdgeInsets.only(
          top: ScallingConfig.scale(10),
          left: ScallingConfig.scale(20),
        ),
        width: Utils.windowWidth(context) * 0.9,
        height: Utils.windowHeight(context) * 0.1,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          image: DecorationImage(fit: BoxFit.cover, image: AssetImage(image!)),
        ),
        child: Row(
          children: [
            CustomText(
              text: title,
              color: AppColors.white,
              fontSize: ScallingConfig.moderateScale(18.88),
              fontFamily: "",
            ),
            const Icon(Icons.keyboard_arrow_right, color: AppColors.white),
          ],
        ),
      ),
    );
  }
}

// ─── Desktop premium card ────────────────────────────────────────────────────
class _PremiumBookingCard extends StatefulWidget {
  const _PremiumBookingCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.count,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String count;
  final VoidCallback onPressed;

  @override
  State<_PremiumBookingCard> createState() => _PremiumBookingCardState();
}

class _PremiumBookingCardState extends State<_PremiumBookingCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
          decoration: BoxDecoration(
            color: _isHovered ? widget.bgColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? widget.color.withOpacity(0.25)
                  : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.color.withOpacity(0.08)
                    : const Color(0xFF0F172A).withOpacity(0.03),
                blurRadius: _isHovered ? 24 : 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _isHovered ? widget.color : widget.bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  widget.icon,
                  color: _isHovered ? Colors.white : widget.color,
                  size: 26,
                ),
              ),
              const SizedBox(width: 24),
              // Title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: "Gilroy",
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontFamily: "Gilroy",
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              // Count badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.bgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.count,
                  style: TextStyle(
                    fontFamily: "Gilroy",
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: widget.color,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Arrow
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? widget.color.withOpacity(0.1)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: _isHovered ? widget.color : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
