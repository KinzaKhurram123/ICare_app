import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/booking_categories.dart';
import 'package:icare/screens/bookings.dart';
import 'package:icare/screens/courses.dart';
import 'package:icare/screens/doctor_profile.dart';
import 'package:icare/screens/help_and_support.dart';
import 'package:icare/screens/login.dart';
import 'package:icare/screens/reminder_list.dart';
import 'package:icare/screens/settings.dart';
import 'package:icare/screens/tabs.dart';
import 'package:icare/screens/wallet.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(40),
      ),
      child: Drawer(
        width: MediaQuery.of(context).size.width * 0.75,
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Close button (top-right)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Profile section with border and edit icon
              Stack(
                clipBehavior: Clip.none,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => DoctorProfile()));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage(ImagePaths.user7),
                      ),
                    ),
                  ),
                  Positioned(
                    // bottom: 4,
                    top: ScallingConfig.verticalScale(5),
                    right: ScallingConfig.scale(5),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Text(
                'Aaron Smith',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black),
              ),
              const Text(
                'aaron@gmail.com',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 25),

              // Menu list (exact items)
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _drawerItem('Home', () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => TabsScreen()));
                    }),
                    // _drawerItem('Reports/Lab Results', () {}),
                    _drawerItem('Booking History', () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => BookingsScreen()));
                    }),
                    // _drawerItem('Become a Instructor', () {}),
                    _drawerItem('Reminders', () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ReminderList()));
                    }),
                    _drawerItem('Help & Support', () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => HelpAndSupport()));

                    }),
                    _drawerItem('Wallet', () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => WalletScreen()));
                    }),
                    _drawerItem('Courses', () {
                                            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => Courses()));

                    }),
                    _drawerItem('Settings', () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => SettingsScreen()));

                    }),
                  ],
                ),
              ),

              // Logout button
              Padding(
                padding:EdgeInsets.only(bottom: 30),
                child: CustomButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => LoginScreen()));
                  },
                  width: Utils.windowWidth(context) * 0.6,
                  borderRadius: 30,
                  label: "Logout")
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          dense: true,
          title: CustomText(
            text: title,
            fontFamily: "Gilroy-SemiBold",
            fontSize: 14.78,
            color: AppColors.primary500,
          ),
          // trailing: const Icon(
          //   Icons.arrow_forward_ios,
          //   size: 14,
          //   color: Colors.grey,
          // ),
          onTap: onTap,
        ),
        // Divider(height: 1, thickness: 0.3, color: Colors.grey.shade300),
      ],
    );
  }
}
