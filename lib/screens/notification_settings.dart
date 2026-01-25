import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';

class NotificationSettings extends StatelessWidget {
  const NotificationSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> _settingsList = [
      {"id": "2", "title": "Booking Updates", "onPress": () {}},
      {"id": "3", "title": "Customer Support Messages", "onPress": () {}},
      {"id": "4", "title": "Patient Messages", "onPress": () {}},
      {"id": "5", "title": "Admin Announcements", "onPress": () {}},
    ];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: CustomBackButton(),
        title: CustomText(
          text: "Notifications Settings",
          fontSize: 16.78,
          fontFamily: "Gilroy-Bold",
          color: AppColors.primary500,
          letterSpacing: -0.31,
          lineHeight: 1.0,
          fontWeight: FontWeight.bold,
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
            SizedBox(height: Utils.windowHeight(context) * 0.5),
            CustomButton(
              borderRadius: 30,
              onPressed: () {},
              label: "Delete Account",
            ),
          ],
        ),
      ),
    );
  }
}
