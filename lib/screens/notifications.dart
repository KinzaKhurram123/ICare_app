import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        "id": 1,
        "title": "Event Request Is Accepted",
        "description": "Pay For Reservation",
        "time": "5:45 PM",
        "unread": true,
        "numOfNotifications": 1,
      },
      {
        "id": 2,
        "title": "Your request has been approved",
        "description": "Pay For Reservation",
        "time": "5:45 PM",
        "unread": true,
        "numOfNotifications": 1,
      },
      {
        "id": 3,
        "title": "Event Request Is Accepted",
        "description": "Pay For Reservation",
        "time": "5:45 PM",
        "unread": true,
        "numOfNotifications": 0,
      },
      {
        "id": 4,
        "title": "Event Request Is Accepted",
        "description": "Pay For Reservation",
        "time": "5:45 PM",
        "unread": true,
        "numOfNotifications": 1,
      },
      {
        "id": 5,
        "title": "Event Request Is Accepted",
        "description": "Pay For Reservation",
        "time": "5:45 PM",
        "unread": true,
        "numOfNotifications": 0,
      },
      {
        "id": 6,
        "title": "Event Request Is Accepted",
        "description": "Pay For Reservation",
        "time": "5:45 PM",
        "unread": true,
        "numOfNotifications": 1,
      },
      {
        "id": 7,
        "title": "Event Request Is Accepted",
        "description": "Pay For Reservation",
        "time": "5:45 PM",
        "unread": true,
        "numOfNotifications": 0,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        
        title: CustomText(text: "Notifications")),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryColor,
                  child: SvgWrapper(assetPath: ImagePaths.profile),
                ),
                title: CustomText(
                  text: notif["title"],
                  color: AppColors.darkGreyColor,
                  fontWeight: FontWeight.bold,
                  width: Utils.windowWidth(context) * 0.8,
                  fontSize: ScallingConfig.moderateScale(13),
                  fontFamily: "Gilroy-Bold",
                ),
                subtitle: CustomText(
                  text: notif["description"],
                  fontSize: 11,
                  color: AppColors.darkGreyColor,
                  fontFamily: "Gilroy-Regular",
                  fontWeight: FontWeight.w400,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (notif["unread"])
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        width: ScallingConfig.scale(15),
                        height: ScallingConfig.scale(15),
                        // height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: CustomText(
                          textAlign: TextAlign.center,
                          // padding: EdgeInsets.all(7),
                          color: AppColors.white,
                          text: notif["numOfNotifications"].toString(),
                        ),
                      ),
                    SizedBox(height: 12),
                    Text(notif["time"]),
                  ],
                ),
              ),

              SizedBox(
                width: Utils.windowWidth(context) * 0.8,
                child: Divider(color: AppColors.grayColor),
              ),
              SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}
