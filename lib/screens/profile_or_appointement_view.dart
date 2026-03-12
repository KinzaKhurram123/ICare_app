import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/models/appointment_detail.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/create_medical_record.dart';
import 'package:icare/screens/decline_appointment_redesign.dart';
import 'package:icare/screens/intake_notes_redesign.dart';
import 'package:icare/screens/patient_profile_view.dart';
import 'package:icare/screens/soap_notes_redesign.dart';
import 'package:icare/services/appointment_service.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';
import 'package:intl/intl.dart';

class ProfileOrAppointmentViewScreen extends ConsumerWidget {
  final AppointmentDetail appointment;

  const ProfileOrAppointmentViewScreen({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = ref.watch(authProvider).userRole;
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    if (isDesktop) {
      return _WebPatientProfileView(
        selectedRole: selectedRole,
        appointment: appointment,
      );
    }

    // Get the other person's info based on role
    final otherPerson = selectedRole == 'doctor' ? appointment.patient : appointment.doctor;
    final formattedDate = DateFormat('MMMM dd, yyyy').format(appointment.date);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: CustomBackButton(),
        title: CustomText(
          text: "View Profile",
          letterSpacing: -0.31,
          lineHeight: 1.0,
          fontSize: 16.78,
          fontFamily: "Gilroy-Bold",
          fontWeight: FontWeight.bold,
          color: AppColors.primary500,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileInfoWidget(
              name: otherPerson?.name ?? 'User',
              email: otherPerson?.email ?? 'N/A',
              appointmentId: appointment.id,
              patient: appointment.patient,
            ),
            DetailsInfoWidget(
              title: "Scheduled Appointment",
              data: {
                "Date": formattedDate,
                "Time": appointment.timeSlot,
                "Booking for": "Self",
                "Status": appointment.status.toUpperCase(),
              },
            ),
            DetailsInfoWidget(
              title: selectedRole == 'doctor' ? "Patient Info" : "Doctor Info",
              data: {
                "Name": otherPerson?.name ?? 'N/A',
                "Email": otherPerson?.email ?? 'N/A',
                "Phone": otherPerson?.phoneNumber ?? 'N/A',
                "Reason": appointment.reason ?? 'N/A',
              },
            ),
            if (selectedRole == "lab_technician") ...[Tests()],

            ConsultationTypeCard(
              chat: true,
              title: "Messaging",
              description: "Chat With Doctor",
              duration: "30 Minutes",
            ),
            SizedBox(height: ScallingConfig.scale(10)),
            ConsultationTypeCard(
              call: true,
              title: "Voice Call",
              description: "Voice call With Doctor",
              duration: "30 Minutes",
            ),

            if (selectedRole == "patient" || selectedRole == "doctor") ...[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScallingConfig.scale(20),
                  vertical: ScallingConfig.scale(13),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: "Soap Notes",
                      underline: true,
                      isBold: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx) => SoapNotesScreen(appointment: appointment)),
                        );
                      },
                    ),
                    CustomText(
                      text: "Intake Notes",
                      underline: true,
                      isBold: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx) => IntakeNotesScreen(appointment: appointment)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: ScallingConfig.scale(15)),

            if (selectedRole == "doctor") ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => CreateMedicalRecordScreen(appointment: appointment),
                      ),
                    );
                  },
                  icon: const Icon(Icons.medical_services_rounded, size: 20),
                  label: const Text("Create Medical Record"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    width: Utils.windowWidth(context) * 0.35,
                    borderRadius: 30,
                    label: "Accept",
                    onPressed: () async {
                      final result = await AppointmentService().updateAppointmentStatus(
                        appointmentId: appointment.id,
                        status: 'confirmed',
                      );
                      if (result['success'] && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Appointment accepted')),
                        );
                        Navigator.of(context).pop(true);
                      }
                    },
                  ),
                  SizedBox(width: ScallingConfig.scale(20)),
                  CustomButton(
                    borderRadius: 30,
                    labelColor: AppColors.primaryColor,
                    width: Utils.windowWidth(context) * 0.35,
                    label: "Decline",
                    outlined: true,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => DeclineAppointmentScreen(appointment: appointment),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ProfileInfoWidget extends StatelessWidget {
  final String name;
  final String email;
  final String appointmentId;
  final dynamic patient;

  const ProfileInfoWidget({
    super.key,
    required this.name,
    required this.email,
    required this.appointmentId,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: Utils.windowWidth(context),
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: AppColors.white),
      child: Row(
        children: [
          Container(
            width: Utils.windowWidth(context) * 0.25,
            height: Utils.windowWidth(context) * 0.25,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(width: ScallingConfig.scale(12)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomText(
                        text: name,
                        isSemiBold: true,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: ScallingConfig.scale(10)),
                    CustomText(
                      text: "View Profile",
                      underline: true,
                      onTap: () {
                        if (patient != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) =>
                                  PatientProfileView(patient: patient),
                            ),
                          );
                        }
                      },
                      isSemiBold: true,
                    ),
                  ],
                ),
                SizedBox(height: ScallingConfig.scale(10)),
                Row(
                  children: [
                    Icon(Icons.email_outlined, size: 16, color: AppColors.darkGreyColor),
                    SizedBox(width: Utils.windowWidth(context) * 0.025),
                    Expanded(
                      child: CustomText(
                        text: email,
                        fontSize: 12,
                        color: AppColors.darkGreyColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SvgWrapper(assetPath: ImagePaths.scan),
                    SizedBox(width: Utils.windowWidth(context) * 0.025),
                    CustomText(
                      text: "Booking ID: #${appointmentId.substring(appointmentId.length - 8)}",
                      fontSize: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailsInfoWidget extends StatelessWidget {
  const DetailsInfoWidget({super.key, this.title = '', required this.data});

  final String title;
  final Map<String, String> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      margin: EdgeInsets.only(top: 12),
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(text: title, fontSize: 14, isBold: true),
            ...data.entries.map((item) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: item.key,
                      fontSize: 12,
                      color: AppColors.darkGreyColor,
                    ),
                    CustomText(
                      text: item.value,
                      isBold: true,
                      color: AppColors.darkGreyColor,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class ConsultationTypeCard extends StatelessWidget {
  const ConsultationTypeCard({
    super.key,
    this.chat = false,
    this.call = true,
    required this.duration,
    required this.title,
    required this.description,
  });

  final bool chat;
  final bool call;
  final String duration;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Utils.windowWidth(context) * 0.9,
      padding: EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkGreyColor.withAlpha(50)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.darkGreyColor.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.darkGreyColor.withAlpha(40)),
            ),
            child: SvgWrapper(
              assetPath: chat
                  ? ImagePaths.message
                  : call
                  ? ImagePaths.calll
                  : '',
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: title,
                fontFamily: "Gilroy-Medium",
                isBold: true,

                color: AppColors.themeDarkGrey,
                fontSize: 12,
              ),
              CustomText(
                text: description,
                fontSize: 12,
                fontFamily: "Gilroy-Regular",
                color: AppColors.themeDarkGrey,
              ),
            ],
          ),
          CustomText(text: duration),
          Icon(
            Icons.radio_button_checked,
            size: ScallingConfig.scale(20),
            color: AppColors.darkGreyColor.withAlpha(90),
          ),
        ],
      ),
    );
  }
}

class Tests extends StatelessWidget {
  const Tests({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            // width: Utils.windowWidth(context) * 0.9,
            text: "Test Names",
            fontSize: 14,
            isBold: true,
          ),
          SizedBox(height: ScallingConfig.scale(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: "NO. 1",
                fontSize: 12,
                color: AppColors.darkGreyColor,
              ),
              CustomText(
                text: "Complete Blood Count",
                isBold: true,
                color: AppColors.darkGreyColor,
              ),
            ],
          ),
          SizedBox(height: ScallingConfig.scale(10)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: "NO. 2",
                fontSize: 12,
                color: AppColors.darkGreyColor,
              ),
              CustomText(
                text: "Blood Sugar",
                isBold: true,
                color: AppColors.darkGreyColor,
              ),
            ],
          ),
          SizedBox(height: ScallingConfig.scale(10)),
        ],
      ),
    );
  }
}


class _WebPatientProfileView extends StatelessWidget {
  final String selectedRole;
  final AppointmentDetail appointment;

  const _WebPatientProfileView({
    required this.selectedRole,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    final otherPerson = selectedRole == 'doctor' ? appointment.patient : appointment.doctor;
    final profileName = otherPerson?.name ?? 'User';
    final formattedDate = DateFormat('MMMM dd, yyyy').format(appointment.date);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: const Text(
          "View Profile",
          style: TextStyle(
            fontSize: 18,
            fontFamily: "Gilroy-Bold",
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column - Patient Info Card
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Patient Avatar
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primaryColor, width: 3),
                            color: AppColors.primaryColor.withValues(alpha: 0.1),
                          ),
                          child: Center(
                            child: Text(
                              profileName.isNotEmpty ? profileName[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          profileName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            fontFamily: "Gilroy-Bold",
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(Icons.email_outlined, otherPerson?.email ?? 'N/A'),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.phone_outlined, otherPerson?.phoneNumber ?? 'N/A'),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.qr_code_rounded, "Booking ID: #${appointment.id.substring(appointment.id.length - 8)}"),
                        const SizedBox(height: 32),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => PatientProfileView(patient: appointment.patient!),
                              ),
                            );
                          },
                          child: const Text(
                            "View Full Profile →",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                // Right Column - Details
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // Scheduled Appointment
                      _buildWebDetailsCard(
                        "Scheduled Appointment",
                        Icons.calendar_today_rounded,
                        const Color(0xFF6366F1),
                        {
                          "Date": formattedDate,
                          "Time": appointment.timeSlot,
                          "Status": appointment.status.toUpperCase(),
                          "Booking for": "Self",
                        },
                      ),
                      const SizedBox(height: 24),
                      // Patient/Doctor Info
                      _buildWebDetailsCard(
                        selectedRole == 'doctor' ? "Patient Info" : "Doctor Info",
                        Icons.person_outline_rounded,
                        const Color(0xFF3B82F6),
                        {
                          "Name": otherPerson?.name ?? 'N/A',
                          "Email": otherPerson?.email ?? 'N/A',
                          "Phone": otherPerson?.phoneNumber ?? 'N/A',
                          "Reason": appointment.reason ?? 'N/A',
                        },
                      ),
                      if (selectedRole == "lab_technician") ...[
                        const SizedBox(height: 24),
                        _buildWebDetailsCard(
                          "Test Names",
                          Icons.biotech_rounded,
                          const Color(0xFF8B5CF6),
                          {
                            "NO. 1": "Complete Blood Count",
                            "NO. 2": "Blood Sugar",
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Consultation Options
                      Row(
                        children: [
                          Expanded(
                            child: _buildConsultationCard(
                              "Messaging",
                              "Chat With Doctor",
                              "30 Minutes",
                              Icons.chat_bubble_outline_rounded,
                              const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildConsultationCard(
                              "Voice Call",
                              "Voice call With Doctor",
                              "30 Minutes",
                              Icons.phone_outlined,
                              const Color(0xFF0EA5E9),
                            ),
                          ),
                        ],
                      ),
                      if (selectedRole == "patient" || selectedRole == "doctor") ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (ctx) => SoapNotesScreen(appointment: appointment)),
                                  );
                                },
                                icon: const Icon(Icons.note_outlined, size: 20),
                                label: const Text("Soap Notes"),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  side: const BorderSide(color: AppColors.primaryColor, width: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (ctx) => IntakeNotesScreen(appointment: appointment)),
                                  );
                                },
                                icon: const Icon(Icons.description_outlined, size: 20),
                                label: const Text("Intake Notes"),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  side: const BorderSide(color: AppColors.primaryColor, width: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (selectedRole == "doctor") ...[
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => CreateMedicalRecordScreen(appointment: appointment),
                                ),
                              );
                            },
                            icon: const Icon(Icons.medical_services_rounded, size: 22),
                            label: const Text("Create Medical Record"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        if (appointment.status.toLowerCase() == 'pending') ...[
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final result = await AppointmentService().updateAppointmentStatus(
                                      appointmentId: appointment.id,
                                      status: 'confirmed',
                                    );
                                    if (result['success'] && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Appointment accepted')),
                                      );
                                      Navigator.of(context).pop(true);
                                    }
                                  },
                                  icon: const Icon(Icons.check_circle_outline_rounded, size: 22),
                                  label: const Text("Accept Appointment"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (ctx) => DeclineAppointmentScreen(appointment: appointment)),
                                    );
                                  },
                                  icon: const Icon(Icons.cancel_outlined, size: 22),
                                  label: const Text("Decline"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFEF4444),
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    side: const BorderSide(color: Color(0xFFEF4444), width: 2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildWebDetailsCard(
    String title,
    IconData icon,
    Color color,
    Map<String, String> data,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  fontFamily: "Gilroy-Bold",
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...data.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildConsultationCard(
    String title,
    String description,
    String duration,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                duration,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
