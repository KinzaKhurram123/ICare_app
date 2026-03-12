import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:icare/models/app_enums.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';

// enum Status { upcoming, cancelled, completed }

class BookingCard extends ConsumerWidget {
  const BookingCard({super.key, this.status, this.showActions= true, this.onTap});
  final BookingStatus? status;
  final bool showActions;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = ref.watch(authProvider).userRole;
    final bool isDesktop = MediaQuery.of(context).size.width > 600;
    Widget reminder = Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          text: "Reminds Me",
          color: AppColors.primary500,
          fontSize: 10,
          fontFamily: "Gilroy-SemiBold",
        ),
        SizedBox(width: 20),
        FlutterSwitch(
          width: 50.0,
          height: 20.0,

          toggleSize: 15.0,
          value: true,
          borderRadius: 30.0,
          padding: 2.0,
          toggleColor: Color.fromRGBO(225, 225, 225, 1),
          activeColor: AppColors.themeBlack,
          inactiveColor: AppColors.darkGreyColor,
          onToggle: (val) {
            // setState(() {
            // status2 = val;
            // });
          },
        ),
      ],
    );

    Widget action = status == BookingStatus.upcoming ?  Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: CustomButton(
                  height: isDesktop ? 48 : Utils.windowHeight(context) * 0.055,
                  borderRadius: 30,
                  labelSize: 15,
                  label: "View",
                  onPressed: () {
                    // TODO: Navigate to appointment detail with actual appointment data
                    // Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ProfileOrAppointmentViewScreen(appointment: appointment)));
                  },
                ),
              ),
              SizedBox(width: ScallingConfig.scale(10)),
              Expanded(
                child: CustomButton(
                  borderRadius: 30,
                  labelSize: 15,
                  labelColor: AppColors.primaryColor,
                  height: isDesktop ? 48 : Utils.windowHeight(context) * 0.055,
                  label: "Cancel",
                  outlined: true,
                  onPressed: () {
                    // Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => DeclineAppointments()));
                  },
                ),
              ),
            ],
          ) : status == BookingStatus.cancelled ? 
          CustomButton(
            label: "View Appointment",
            height: Utils.windowHeight(context) * 0.055,
            borderRadius: 30,
            labelSize: 15,
            onPressed: () {
              // TODO: Navigate to appointment detail with actual appointment data
              // Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ProfileOrAppointmentViewScreen(appointment: appointment)));
            },
            ) 
          : CustomButton(
            label: "View Chat",
            height: Utils.windowHeight(context) * 0.055,
            borderRadius: 30,
            labelSize: 15,
            ) ;

    return isDesktop
        ? _WebBookingCard(
            status: status,
            onTap: onTap,
            showActions: showActions,
            selectedRole: selectedRole,
          )
        : GestureDetector(
            onTap: onTap ?? () {},
            child: Container(
              width: Utils.windowWidth(context) * 0.75,
              margin: EdgeInsets.only(top: ScallingConfig.verticalScale(12)),
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: ScallingConfig.verticalScale(12),
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.veryLightGrey.withOpacity(0.5),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: "Dec 05, 2023 - 10:00 AM",
                        color: AppColors.primary500,
                        fontSize: 12,
                        fontFamily: "Gilroy-SemiBold",
                      ),
                      if (status == BookingStatus.upcoming) reminder,
                    ],
                  ),
                  SizedBox(height: ScallingConfig.scale(10)),
                  Row(
                    children: [
                      Container(
                        width: Utils.windowWidth(context) * 0.22,
                        height: Utils.windowWidth(context) * 0.22,
                        decoration: BoxDecoration(
                          color: AppColors.darkGray400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                            selectedRole == "patient"
                                ? ImagePaths.walkthrough1
                                : ImagePaths.user1,
                            fit: selectedRole == "patient"
                                ? BoxFit.contain
                                : BoxFit.cover),
                      ),
                      SizedBox(width: ScallingConfig.scale(12)),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomText(
                              width: double.infinity,
                              text: selectedRole == "patient"
                                  ? "Dr Aron Smith"
                                  : "Emily Jordan",
                              isSemiBold: true,
                              textAlign: TextAlign.start,
                            ),
                            SizedBox(height: ScallingConfig.scale(5)),
                            Row(
                              children: [
                                SvgWrapper(assetPath: ImagePaths.location),
                                SizedBox(
                                    width: Utils.windowWidth(context) * 0.025),
                                CustomText(
                                  text: "20 Cooper Square, USA",
                                  fontSize: 12,
                                  color: AppColors.darkGreyColor,
                                ),
                              ],
                            ),
                            SizedBox(height: ScallingConfig.scale(6)),
                            Row(
                              children: [
                                SvgWrapper(assetPath: ImagePaths.scan),
                                SizedBox(
                                    width: Utils.windowWidth(context) * 0.025),
                                CustomText(
                                  text: "Booking ID: #DR452SA54",
                                  fontSize: 12,
                                  color: AppColors.darkGreyColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ScallingConfig.scale(20)),
                  if (showActions) action
                ],
              ),
            ),
          );
  }
}

class _WebBookingCard extends StatefulWidget {
  final BookingStatus? status;
  final VoidCallback? onTap;
  final bool showActions;
  final String selectedRole;

  const _WebBookingCard({
    required this.status,
    this.onTap,
    required this.showActions,
    required this.selectedRole,
  });

  @override
  State<_WebBookingCard> createState() => _WebBookingCardState();
}

class _WebBookingCardState extends State<_WebBookingCard> {
  bool _isHovered = false;
  bool _remindMe = true;

  @override
  Widget build(BuildContext context) {
    Color statusColor = widget.status == BookingStatus.upcoming
        ? const Color(0xFF3B82F6)
        : widget.status == BookingStatus.cancelled
            ? const Color(0xFFEF4444)
            : const Color(0xFF22C55E);

    String statusLabel = widget.status == BookingStatus.upcoming
        ? "Upcoming"
        : widget.status == BookingStatus.cancelled
            ? "Cancelled"
            : "Completed";

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? statusColor.withOpacity(0.3) : const Color(0xFFF1F4F9),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? const Color(0xFF000000).withOpacity(0.06) : const Color(0xFF000000).withOpacity(0.04),
                blurRadius: _isHovered ? 24 : 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top Bar: Date and Status
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 8),
                          const Text(
                            "Dec 05, 2023",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFCBD5E1), shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          const Text(
                            "10:00 AM",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: statusColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1, color: Color(0xFFF1F5F9), thickness: 1.5),

              // Main Content Info
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // Profile Image
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFFF1F5F9),
                        image: DecorationImage(
                          image: AssetImage(widget.selectedRole == "patient" ? ImagePaths.walkthrough1 : ImagePaths.user1),
                          fit: widget.selectedRole == "patient" ? BoxFit.contain : BoxFit.cover,
                        ),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Doctor Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.selectedRole == "patient" ? "Dr. Aron Smith" : "Emily Jordan",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                              fontFamily: "Gilroy-Bold",
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 6),
                              const Expanded(
                                child: Text(
                                  "20 Cooper Square, New York, USA",
                                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.qr_code_rounded, size: 14, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 6),
                              const Text(
                                "ID: #DR452SA54",
                                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Remind Me Toggle (Only for Upcoming)
                    if (widget.status == BookingStatus.upcoming)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Text("Remind Me", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                            const SizedBox(width: 12),
                            FlutterSwitch(
                              width: 38,
                              height: 20,
                              toggleSize: 14,
                              value: _remindMe,
                              borderRadius: 20,
                              padding: 3,
                              activeColor: AppColors.primaryColor,
                              inactiveColor: const Color(0xFFCBD5E1),
                              onToggle: (val) => setState(() => _remindMe = val),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Bottom Actions
              if (widget.showActions)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      const Spacer(),
                      if (widget.status == BookingStatus.upcoming) ...[
                        _buildWebButton(
                          "Cancel Appointment",
                          onPressed: () {},
                          isOutlined: true,
                        ),
                        const SizedBox(width: 12),
                        _buildWebButton(
                          "View Full Profile",
                          onPressed: () {
                            // TODO: Navigate to appointment detail with actual appointment data
                          },
                        ),
                      ] else if (widget.status == BookingStatus.cancelled) ...[
                        _buildWebButton(
                          "View History",
                          onPressed: () {
                            // TODO: Navigate to appointment detail with actual appointment data
                          },
                        ),
                      ] else ...[
                        _buildWebButton("Send Message", onPressed: () {}, icon: Icons.chat_bubble_rounded),
                        const SizedBox(width: 12),
                        _buildWebButton(
                          "View Summary",
                          onPressed: () {},
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebButton(String label, {required VoidCallback onPressed, bool isOutlined = false, IconData? icon}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: isOutlined ? Colors.white : AppColors.primaryColor,
        foregroundColor: isOutlined ? const Color(0xFF64748B) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isOutlined ? const BorderSide(color: Color(0xFFE2E8F0), width: 1.5) : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 16), const SizedBox(width: 8)],
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: "Gilroy-Bold")),
        ],
      ),
    );
  }
}