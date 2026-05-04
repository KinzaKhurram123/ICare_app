import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:icare/models/app_enums.dart';
import 'package:icare/models/appointment_detail.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/chat_screen.dart';
import 'package:icare/screens/consultation_workflow.dart';
import 'package:icare/screens/profile_or_appointement_view.dart';
import 'package:icare/screens/video_call.dart';
import 'package:intl/intl.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';

// enum Status { upcoming, cancelled, completed }

class BookingCard extends ConsumerWidget {
  const BookingCard({
    super.key,
    required this.appointment,
    this.showActions = true,
    this.onTap,
  });
  final AppointmentDetail appointment;
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

    Widget action =
        appointment.status.toLowerCase() == 'in_progress'
        ? Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.4)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fiber_manual_record, color: Color(0xFF8B5CF6), size: 10),
                    SizedBox(width: 8),
                    Text(
                      'Consultation in Progress',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: ScallingConfig.scale(8)),
              CustomButton(
                label: "Rejoin Consultation",
                height: isDesktop ? 48 : Utils.windowHeight(context) * 0.055,
                borderRadius: 30,
                labelSize: 15,
                onPressed: () {
                  // Use stored channelName, fallback to appointment id
                  final channelName = appointment.channelName?.isNotEmpty == true
                      ? appointment.channelName!
                      : appointment.id;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VideoCall(
                        channelName: channelName,
                        remoteUserName: selectedRole == 'Doctor'
                            ? appointment.patientName
                            : appointment.doctorName,
                        appointmentId: appointment.id,
                      ),
                    ),
                  );
                },
              ),
            ],
          )
        : (appointment.status.toLowerCase() == 'pending' ||
            appointment.status.toLowerCase() == 'confirmed')
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: CustomButton(
                  height: isDesktop ? 48 : Utils.windowHeight(context) * 0.055,
                  borderRadius: 30,
                  labelSize: 15,
                  label: "View",
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => ProfileOrAppointmentViewScreen(
                          appointment: appointment,
                        ),
                      ),
                    );
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
                    // TODO: Implement cancel logic
                  },
                ),
              ),
            ],
          )
        : appointment.status.toLowerCase() == 'cancelled'
        ? CustomButton(
            label: "View Appointment",
            height: Utils.windowHeight(context) * 0.055,
            borderRadius: 30,
            labelSize: 15,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) =>
                      ProfileOrAppointmentViewScreen(appointment: appointment),
                ),
              );
            },
          )
        : Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: "Message",
                  height: Utils.windowHeight(context) * 0.055,
                  borderRadius: 30,
                  labelSize: 15,
                  outlined: true,
                  onPressed: () {
                    final targetUser = selectedRole == "Doctor"
                        ? appointment.patient
                        : appointment.doctor;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => ChatScreen(
                          userId: targetUser?.id ?? "",
                          userName: selectedRole == "Doctor"
                              ? appointment.patientName
                              : appointment.doctorName,
                          userImage: targetUser?.profilePicture,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomButton(
                  label: "View Details",
                  height: Utils.windowHeight(context) * 0.1,
                  borderRadius: 30,
                  labelSize: 15,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => ProfileOrAppointmentViewScreen(
                          appointment: appointment,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );

    final currentUser = ref.watch(authProvider).user;
    return isDesktop
        ? _WebBookingCard(
            appointment: appointment,
            onTap: onTap,
            showActions: showActions,
            selectedRole: selectedRole,
            currentUserName: currentUser?.name ?? '',
            currentUserId: currentUser?.id ?? '',
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
                        text:
                            "${DateFormat('MMM dd, yyyy').format(appointment.date)} - ${appointment.timeSlot}",
                        color: AppColors.primary500,
                        fontSize: 12,
                        fontFamily: "Gilroy-SemiBold",
                      ),
                      if (appointment.status.toLowerCase() == 'pending' ||
                          appointment.status.toLowerCase() == 'confirmed')
                        reminder,
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
                          selectedRole == "Patient"
                              ? ImagePaths.walkthrough1
                              : ImagePaths.user1,
                          fit: selectedRole == "Patient"
                              ? BoxFit.contain
                              : BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: ScallingConfig.scale(12)),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomText(
                              width: double.infinity,
                              text: selectedRole == "Patient"
                                  ? appointment.doctorName
                                  : (appointment.patient?.name ?? "Patient"),
                              isSemiBold: true,
                              textAlign: TextAlign.start,
                            ),
                            SizedBox(height: ScallingConfig.scale(5)),
                            Row(
                              children: [
                                SvgWrapper(assetPath: ImagePaths.location),
                                SizedBox(
                                  width: Utils.windowWidth(context) * 0.025,
                                ),
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
                                  width: Utils.windowWidth(context) * 0.025,
                                ),
                                CustomText(
                                  text:
                                      "Booking ID: #${appointment.id.length > 8 ? appointment.id.substring(appointment.id.length - 8).toUpperCase() : appointment.id.toUpperCase()}",
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
                  if (showActions) action,
                ],
              ),
            ),
          );
  }
}

class _WebBookingCard extends StatefulWidget {
  final AppointmentDetail appointment;
  final VoidCallback? onTap;
  final bool showActions;
  final String selectedRole;
  final String currentUserName;
  final String currentUserId;

  const _WebBookingCard({
    required this.appointment,
    this.onTap,
    required this.showActions,
    required this.selectedRole,
    this.currentUserName = '',
    this.currentUserId = '',
  });

  @override
  State<_WebBookingCard> createState() => _WebBookingCardState();
}

class _WebBookingCardState extends State<_WebBookingCard> {
  bool _isHovered = false;
  bool _remindMe = true;

  @override
  Widget build(BuildContext context) {
    Color statusColor =
        widget.appointment.status.toLowerCase() == 'confirmed' ||
            widget.appointment.status.toLowerCase() == 'pending'
        ? const Color(0xFF3B82F6)
        : widget.appointment.status.toLowerCase() == 'cancelled'
        ? const Color(0xFFEF4444)
        : widget.appointment.status.toLowerCase() == 'in_progress'
        ? const Color(0xFF8B5CF6)
        : const Color(0xFF22C55E);

    String statusLabel = widget.appointment.status.toLowerCase() == 'in_progress'
        ? 'CONSULTATION IN PROGRESS'
        : widget.appointment.status.toUpperCase();

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
              color: _isHovered
                  ? statusColor.withOpacity(0.3)
                  : const Color(0xFFF1F4F9),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? const Color(0xFF000000).withOpacity(0.06)
                    : const Color(0xFF000000).withOpacity(0.04),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat(
                              'MMM dd, yyyy',
                            ).format(widget.appointment.date),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFFCBD5E1),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.appointment.timeSlot,
                            style: const TextStyle(
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
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
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
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

              const Divider(
                height: 1,
                color: Color(0xFFF1F5F9),
                thickness: 1.5,
              ),

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
                          image: AssetImage(
                            widget.selectedRole == "Patient"
                                ? ImagePaths.walkthrough1
                                : ImagePaths.user1,
                          ),
                          fit: widget.selectedRole == "Patient"
                              ? BoxFit.contain
                              : BoxFit.cover,
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
                            widget.selectedRole == "Doctor"
                                ? widget.appointment.patientName
                                : (widget.appointment.doctor?.name ?? "Doctor"),
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
                              const Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 6),
                              const Expanded(
                                child: Text(
                                  "20 Cooper Square, New York, USA",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.qr_code_rounded,
                                size: 14,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "ID: #${widget.appointment.id.length > 8 ? widget.appointment.id.substring(widget.appointment.id.length - 8).toUpperCase() : widget.appointment.id.toUpperCase()}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Remind Me Toggle (Only for Upcoming)
                    if (widget.appointment.status.toLowerCase() == 'pending' ||
                        widget.appointment.status.toLowerCase() == 'confirmed')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              "Remind Me",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
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
                              onToggle: (val) =>
                                  setState(() => _remindMe = val),
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
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Spacer(),
                      if (widget.appointment.status.toLowerCase() ==
                              'pending' ||
                          widget.appointment.status.toLowerCase() ==
                              'confirmed') ...[
                        _buildWebButton(
                          "Cancel Appointment",
                          onPressed: () {},
                          isOutlined: true,
                        ),
                        const SizedBox(width: 12),
                        // Doctor sees "Start Consultation"; Patient sees "View Details"
                        if (widget.selectedRole == 'Doctor' &&
                            widget.appointment.status.toLowerCase() == 'confirmed') ...[
                          _buildWebButton(
                            "Start Consultation",
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => ConsultationWorkflowScreen(
                                    appointment: widget.appointment,
                                  ),
                                ),
                              );
                            },
                          ),
                        ] else ...[
                          _buildWebButton(
                            "View Full Details",
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) =>
                                      ProfileOrAppointmentViewScreen(
                                        appointment: widget.appointment,
                                      ),
                                ),
                              );
                            },
                          ),
                        ],
                      ] else if (widget.appointment.status.toLowerCase() ==
                          'in_progress') ...[
                        // Consultation in Progress — Rejoin button
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8, height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF8B5CF6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Consultation in Progress',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF8B5CF6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Use stored channelName, fallback to appointment id
                            final channelName = widget.appointment.channelName?.isNotEmpty == true
                                ? widget.appointment.channelName!
                                : widget.appointment.id;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => VideoCall(
                                  channelName: channelName,
                                  remoteUserName: widget.selectedRole == 'Doctor'
                                      ? widget.appointment.patientName
                                      : widget.appointment.doctorName,
                                  appointmentId: widget.appointment.id,
                                  currentUserName: widget.currentUserName,
                                  currentUserId: widget.currentUserId,
                                  patientId: widget.appointment.patient?.id,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.video_call_rounded, size: 18),
                          label: const Text('Rejoin Consultation',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ] else if (widget.appointment.status.toLowerCase() ==
                          'cancelled') ...[
                        _buildWebButton(
                          "View Details",
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) =>
                                    ProfileOrAppointmentViewScreen(
                                      appointment: widget.appointment,
                                    ),
                              ),
                            );
                          },
                        ),
                      ] else ...[
                        _buildWebButton(
                          "Send Message",
                          onPressed: () {
                            final targetUser = widget.selectedRole == "Doctor"
                                ? widget.appointment.patient
                                : widget.appointment.doctor;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => ChatScreen(
                                  userId: targetUser?.id ?? "",
                                  userName: widget.selectedRole == "Doctor"
                                      ? widget.appointment.patientName
                                      : widget.appointment.doctorName,
                                  userImage: targetUser?.profilePicture,
                                ),
                              ),
                            );
                          },
                          icon: Icons.chat_bubble_rounded,
                        ),
                        const SizedBox(width: 12),
                        _buildWebButton(
                          "View Details",
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) =>
                                    ProfileOrAppointmentViewScreen(
                                      appointment: widget.appointment,
                                    ),
                              ),
                            );
                          },
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

  Widget _buildWebButton(
    String label, {
    required VoidCallback onPressed,
    bool isOutlined = false,
    IconData? icon,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: isOutlined ? Colors.white : AppColors.primaryColor,
        foregroundColor: isOutlined ? const Color(0xFF64748B) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isOutlined
              ? const BorderSide(color: Color(0xFFE2E8F0), width: 1.5)
              : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 16), const SizedBox(width: 8)],
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: "Gilroy-Bold",
            ),
          ),
        ],
      ),
    );
  }
}
