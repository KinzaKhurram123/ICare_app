import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/app.dart';
import 'package:icare/models/app_enums.dart';
import 'package:icare/navigators/bottom_tab_bar.dart';
import 'package:icare/navigators/bottom_tabs.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/bookings.dart';
import 'package:icare/screens/chatlist.dart';
import 'package:icare/screens/home.dart';
import 'package:icare/screens/my_cart.dart';
import 'package:icare/screens/notifications.dart';
import 'package:icare/screens/order_tracking.dart';
import 'package:icare/screens/profile.dart';
import 'package:icare/screens/upload_prescription.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/available_badge.dart';
import 'package:icare/widgets/custom_tab_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/navigators/drawer.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});
  @override
  ConsumerState<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  var currentIndex = 0;
  void _selectPage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(authProvider).userRole;
    Widget activePage = HomeScreen();
    if (role == "instructor") {
      if (currentIndex == 1) {
        // activePage= ;
      } else if (currentIndex == 2) {
        activePage = ChatlistScreen();
      } else if (currentIndex == 3) {
        activePage = ProfileScreen();
      } else {
        activePage = HomeScreen();
      }
    } else {
      if (currentIndex == 1) {
        activePage = BookingsScreen(tabs: true);
      } else if (currentIndex == 2) {
        activePage = ChatlistScreen();
      } else if (currentIndex == 3) {
        activePage = ProfileScreen();
      } else {
        activePage = HomeScreen();
      }
    }

    final tabs = buildTabs(
      role: role,
      context: context,
      currentIndex: currentIndex,
      onSelect: _selectPage,
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) {
            return Padding(
              padding: EdgeInsets.only(left: ScallingConfig.scale(28.0)),
              child: GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: CircleAvatar(
                  backgroundColor: AppColors.white,
                  child: SvgWrapper(assetPath: ImagePaths.menu),
                ),
              ),
            );
          },
        ),
        centerTitle: false,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: "Hello,",
              fontSize: 14,
              color: AppColors.darkGreyColor,
              fontWeight: FontWeight.w400,
              fontFamily: "Gilroy-Bold",
            ),
            AvailableBadge(),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: ScallingConfig.scale(10)),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => NotificationScreen()),
                );
              },
              child: CircleAvatar(
                backgroundColor: AppColors.white,
                child: SvgWrapper(assetPath: ImagePaths.notification),
              ),
            ),
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: activePage,

      bottomNavigationBar: BottomTabBar(
        tabs: buildTabs(
          role: role,
          context: context,
          currentIndex: currentIndex,
          onSelect: _selectPage,
        ),
        onSelect: (value) {},
      ),
    );
  }
}
