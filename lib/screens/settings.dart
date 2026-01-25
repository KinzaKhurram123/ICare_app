import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/about_us.dart';
import 'package:icare/screens/change_password.dart';
import 'package:icare/screens/login.dart';
import 'package:icare/screens/notification_settings.dart';
import 'package:icare/screens/privacy_policy.dart';
import 'package:icare/screens/reset_password.dart';
import 'package:icare/screens/terms_and_conditions.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/app_modals.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> _settingsList = [
      {
        "id": "1",
        "title": "Notifications",
        "onPress": () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => NotificationSettings()));
        },
      },
      {
        "id": "2",
        "title": "Change Passwords",
        "onPress": () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => ChangePassword()));
        },
      },
      {
        "id": "3",
        "title": "Privacy Policy",
        "onPress": () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => PrivacyPolicy()));
        },
      },
      {
        "id": "4",
        "title": "About Us",
        "onPress": () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => AboutUs()));
        },
      },
      {
        "id": "5",
        "title": "Terms & Conditions",
        "onPress": () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => TermsAndConditions()));
        },
      },
    ];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: CustomBackButton(),
        title: CustomText(
          text: "Settings",
          fontWeight: FontWeight.bold,
          letterSpacing: -0.31,
          lineHeight: 1.0,
          fontSize: 16.78,
          fontFamily: "Gilroy-Bold",
          color: AppColors.primary500,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: Utils.windowWidth(context) * 0.85,

              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: _settingsList.map((item) {
                  return GestureDetector(
                    onTap: item["onPress"],
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            // vertical: 12.0,
                            horizontal: 18.0,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                text: item["title"],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.primary500,
                                fontFamily: "Gilroy-SemiBold",
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: AppColors.primaryColor,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                        if (item['id'] != "5")
                          const Divider(
                            color: AppColors.darkGreyColor,
                            thickness: 0.2,
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: Utils.windowHeight(context) * 0.4),
            CustomButton(
              borderRadius: 30,
              onPressed: () {
                AppDialogs.showWarningDialog(
                  context,
                  "Are you sure do you want to delete your account",
                  null,
                  [
                    "I don’t need it anymore",
                    "I don’t find it useful",
                    "Other",
                  ],
                  numOfActions: 2,
                  onPrimaryButtonPressed: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (ctx) => LoginScreen()));
                  },
                );
              },
              label: "Delete Account",
            ),
            // SizedBox(height: ScallingConfig.scale(100),)
          ],
        ),
      ),
    );
  }
}
