import 'package:flutter/material.dart';
import 'package:icare/screens/my_cart.dart';
import 'package:icare/screens/order_tracking.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/custom_tab_button.dart';
import 'package:icare/models/app_enums.dart';


List<Widget> _doctorTabs(
   BuildContext context,
  int currentIndex,
  Function(int) onSelect,
) {
   return [
        CustomTabButton(
          onPressed: () {
            onSelect(0);
          },
          iconColor: currentIndex == 0
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.home,
          title: "Home",
        ),
        CustomTabButton(
          onPressed: () {
            onSelect(1);
          },
          iconColor: currentIndex == 1
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.bookings,
          title: "Bookings",
        ),
        SizedBox(width: 20),
        CustomTabButton(
          onPressed: () {
            onSelect(2);
          },
          iconColor: currentIndex == 2
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.chat,
          title: "Chat",
        ),
        CustomTabButton(
          onPressed: () {
            onSelect(3);
          },
          iconColor: currentIndex == 3
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.profile2,
          title: "Profile",
        ),
      ];
  
} 

List<Widget> _patientTabs(
   BuildContext context,
  int currentIndex,
  Function(int) onSelect,
) {
   return [
        CustomTabButton(
          onPressed: () {
            onSelect(0);
          },
          iconColor: currentIndex == 0
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.home,
          title: "Home",
        ),
        CustomTabButton(
          onPressed: () {
            onSelect(1);
          },
          iconColor: currentIndex == 1
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.bookings,
          title: "Bookings",
        ),
        SizedBox(width: 20),
        CustomTabButton(
          onPressed: () {
            onSelect(2);
          },
          iconColor: currentIndex == 2
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.chat,
          title: "Chat",
        ),
        CustomTabButton(
          onPressed: () {
            onSelect(3);
          },
          iconColor: currentIndex == 3
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.profile2,
          title: "Profile",
        ),
      ];
  
} 
List<Widget> _labTabs(
   BuildContext context,
  int currentIndex,
  Function(int) onSelect,
) {
   return [
        CustomTabButton(
          onPressed: () {
            onSelect(0);
          },
          iconColor: currentIndex == 0
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.home,
          title: "Home",
        ),
        CustomTabButton(
          onPressed: () {
            onSelect(1);
          },
          iconColor: currentIndex == 1
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.bookings,
          title: "Bookings",
        ),
        SizedBox(width: 20),
        CustomTabButton(
          onPressed: () {
            onSelect(2);
          },
          iconColor: currentIndex == 2
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.chat,
          title: "Chat",
        ),
        CustomTabButton(
          onPressed: () {
            onSelect(3);
          },
          iconColor: currentIndex == 3
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.profile2,
          title: "Profile",
        ),
      ];
  
} 



List<Widget> _instructorTabs(
   BuildContext context,
  int currentIndex,
  Function(int) onSelect,
) {
   return [
        CustomTabButton(
          onPressed: () {
            onSelect(0);
          },
          iconColor: currentIndex == 0
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.home,
          title: "Home",
        ),
        CustomTabButton(
          onPressed: () {
            // _selectPage(1);
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (ctx) => MyCartScreen()));
          },
          iconColor: currentIndex == 1
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.cart2,
          title: "Cart",
        ),
        SizedBox(width: 20),
        CustomTabButton(
          onPressed: () {
            // _selectPage(2);
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (ctx) => OrderTrackingScreen()));
          },
          iconColor: currentIndex == 2
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.track,
          title: "track",
        ),
        CustomTabButton(
          onPressed: () {
            onSelect(3);
          },
          iconColor: currentIndex == 3
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.profile2,
          title: "Profile",
        ),
      ];
  
} 
List<Widget> _pharmacistTabs(
   BuildContext context,
  int currentIndex,
  Function(int) onSelect,
) {
   return [
        CustomTabButton(
          onPressed: () {
            onSelect(0);
          },
          iconColor: currentIndex == 0
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.home,
          title: "Home",
        ),
        CustomTabButton(
          onPressed: () {
            // _selectPage(1);
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (ctx) => MyCartScreen()));
          },
          iconColor: currentIndex == 1
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.cart2,
          title: "Cart",
        ),
        SizedBox(width: 20),
        CustomTabButton(
          onPressed: () {
            // _selectPage(2);
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (ctx) => OrderTrackingScreen()));
          },
          iconColor: currentIndex == 2
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.track,
          title: "track",
        ),
        CustomTabButton(
          onPressed: () {
            onSelect(3);
          },
          iconColor: currentIndex == 3
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.profile2,
          title: "Profile",
        ),
      ];
  
} 

List<Widget> _studentTabs(
   BuildContext context,
  int currentIndex,
  Function(int) onSelect,
) {
   return [
        CustomTabButton(
          onPressed: () {
            onSelect(0);
          },
          iconColor: currentIndex == 0
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.home,
          title: "Home",
        ),
        CustomTabButton(
          onPressed: () {
            // _selectPage(1);
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (ctx) => MyCartScreen()));
          },
          iconColor: currentIndex == 1
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.cart2,
          title: "Cart",
        ),
        SizedBox(width: 20),
        CustomTabButton(
          onPressed: () {
            // _selectPage(2);
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (ctx) => OrderTrackingScreen()));
          },
          iconColor: currentIndex == 2
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.track,
          title: "track",
        ),
        CustomTabButton(
          onPressed: () {
            onSelect(3);
          },
          iconColor: currentIndex == 3
              ? AppColors.primaryColor
              : AppColors.grayColor,
          image: ImagePaths.profile2,
          title: "Profile",
        ),
      ];
  
} 



List<Widget>? buildTabs({
  required String role,
  required BuildContext context,
  required int currentIndex,
  required Function(int) onSelect,
}) {
  switch (role) {
    case "pharmacist":
      return _pharmacistTabs(context, currentIndex, onSelect);

    case "instructor":
      return _instructorTabs(context, currentIndex, onSelect);
    
    case "patient":
      return _patientTabs(context, currentIndex, onSelect);
    
    case "lab_technician":
      return _labTabs(context, currentIndex, onSelect);
    
    case "doctor":
       return _doctorTabs(context, currentIndex, onSelect);
    
    case "student":
      return _studentTabs(context, currentIndex, onSelect);
  default:
      return _doctorTabs(context, currentIndex, onSelect);
  }
}
