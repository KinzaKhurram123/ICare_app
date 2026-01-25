import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/decline_appointments.dart';
import 'package:icare/screens/doctor_profile.dart';
import 'package:icare/screens/intake_notes.dart';
import 'package:icare/screens/soap_notes.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class ProfileOrAppointmentViewScreen extends ConsumerWidget {
  const ProfileOrAppointmentViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = ref.watch(authProvider).userRole;
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
            ProfileInfoWidget(),
            DetailsInfoWidget(
              title: "Scheduled Appointment",
              data: {
                "Date": "December, 05, 2025",
                "Time": "10:00 AM – 10:30 AM (30 minutes)",
                "Booking for": "Self",
              },
            ),
            DetailsInfoWidget(
              title: "Patient Info",
              data: {
                "Gender": "Female",
                "Age": "32",
                "Patient Guardians": "Guardians",
                "Problem": "N/A",
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
                          MaterialPageRoute(builder: (ctx) => SoapNotes()),
                        );
                      },
                    ),
                    CustomText(
                      text: "Intake Notes",
                      underline: true,
                      isBold: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx) => IntakeNotes()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: ScallingConfig.scale(15)),

            if (selectedRole == "doctor") ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    width: Utils.windowWidth(context) * 0.35,
                    borderRadius: 30,
                    label: "Accept",
                    onPressed: () {
                      Navigator.of(context).pop(2);
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
                          builder: (ctx) => DeclineAppointments(),
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

class ProfileInfoWidget extends ConsumerWidget {
  const ProfileInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = ref.watch(authProvider).userRole;

    var profile_name = selectedRole == "patient"
        ? "Dr. Aron Smith"
        : selectedRole == "lab_technician"
        ? "Alyana"
        : "Emily Jordan";
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
              color: AppColors.darkGray400,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              selectedRole == "patient"
                  ? ImagePaths.walkthrough1
                  : selectedRole == "lab_technician"
                  ? ImagePaths.user13
                  : ImagePaths.user1,
              fit: selectedRole == "patient" ? BoxFit.contain : BoxFit.cover,
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
                    CustomText(text: profile_name, isSemiBold: true),
                    // Spacer(),
                    SizedBox(width: ScallingConfig.scale(50)),
                    CustomText(
                      text: "View Profile",
                      underline: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) =>
                                DoctorProfile(fromViewProfile: true),
                          ),
                        );
                      },
                      isSemiBold: true,
                    ),
                  ],
                ),
                SizedBox(height: ScallingConfig.scale(10)),
                Row(
                  children: [
                    SvgWrapper(assetPath: ImagePaths.location),
                    SizedBox(width: Utils.windowWidth(context) * 0.025),
                    CustomText(
                      text: "20 Cooper Square, USA",
                      fontSize: 12,
                      color: AppColors.darkGreyColor,
                    ),
                  ],
                ),
                Row(
                  children: [
                    SvgWrapper(assetPath: ImagePaths.scan),
                    SizedBox(width: Utils.windowWidth(context) * 0.025),
                    CustomText(text: "Booking ID: #DR452SA54", fontSize: 12),
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
