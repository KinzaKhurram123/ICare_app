import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/booking_categories.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key, this.tabs = false});
  final bool tabs;

  @override
  Widget build(BuildContext context) {

 List<Map<String, dynamic>> bookingMenu = [
  {
    "id": 1,
    "title": "In Progress Bookings",
    "image": ImagePaths.inProgress,
    "onPressed": () {
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => BookingCategories()));
    },
  },
  {
    "id": 2,
    "title": "Upcoming Bookings",
    "image" : ImagePaths.upcoming,
    "onPressed": () {
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => BookingCategories()));
      // print("Upcoming Bookings tapped");
    },
  },
  {
    "id": 3,
    "title": "Cancelled Bookings",
    "image" : ImagePaths.cancelled,
    "onPressed": () {
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => BookingCategories()));
      // print("Cancelled Bookings tapped");
    },
  },
  {
    "id": 4,
    "title": "Completed Bookings",
    "image":ImagePaths.completed,
    "onPressed": () {
      // print("Completed Bookings tapped");
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => BookingCategories()));
    },
  },
  {
    "id": 5,
    "title": "Pending Bookings",
    "image" : ImagePaths.pending, 
    "onPressed": () {
      // print("Pending Bookings tapped");
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => BookingCategories()));
    },
  },
];
    return Material(
      child: Container(
          width: Utils.windowWidth(context),
          height: Utils.windowHeight(context),
          // margin: EdgeInsets.only(top: ),
          // padding: EdgeInsets.only(top:ScallingConfig.verticalScale(40), left:ScallingConfig.scale(10) , right: ScallingConfig.scale(10)),
          
          decoration: BoxDecoration(
          
          image: DecorationImage(image: AssetImage("assets/images/bgImage.jpeg", ),
           fit: BoxFit.cover
          )
          ),
          child: Padding(
            padding:  EdgeInsets.only(top:ScallingConfig.verticalScale(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(height: ScallingConfig.scale(20),),
                if(!tabs) ...[
                CustomBackButton()],
                SizedBox(height: ScallingConfig.scale(20),),
                Center(
                  child: CustomText(text: "Bookings Hsitory",
                  fontSize:25.27,
                  
                  
                  padding: EdgeInsets.only(left: ScallingConfig.moderateScale(12)),
                  color: AppColors.themeBlue,
                  // width: Utils.windowWidth(context) * 0.5 ,
                  fontWeight: FontWeight.w700,
                  isBold: true,
                  ),
                ),

                Center(
                  child: CustomText(text: "Stay on top of your schedule with real-time updates on patient bookings.",
                  padding: EdgeInsets.only(top: ScallingConfig.verticalScale(10), left: ScallingConfig.moderateScale(12)),
                        
                  width: Utils.windowWidth(context) * 0.8 ,
                  textAlign: TextAlign.center,
                  fontSize: 12.60,
                  maxLines: 2,
                  isSemiBold: true,
                        ),
                ),
                SizedBox(height: ScallingConfig.scale(20),),
                Expanded(child: Stack(
                  children: [
                    Container(
                      clipBehavior: Clip.hardEdge,
                     width: Utils.windowWidth(context),
                     padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(10), vertical: ScallingConfig.verticalScale(20)), 
                      decoration: BoxDecoration(
      
                          color: AppColors.bgColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                          
                        ),
                        child: Center(
                          child: ListView.builder(
                            padding: EdgeInsets.only(
                              // bottom: ScallingConfig.verticalScale(60),
                              left: ScallingConfig.scale(10),
                              right: ScallingConfig.scale(10),
                              ),                          
                            itemCount: bookingMenu.length,
                            itemBuilder: (ctx,i) {
                            final item = bookingMenu[i];
      
                            return BookingCategoryCard(
                              title: item["title"], 
                              onPressed: item["onPressed"],
                              image: item["image"],
                              );
                          }
                          ),
                        ),
                    ),
                // SizedBox(height: ScallingConfig.scale(20),)         
                  ],
                )),
              ],
            ),
          ) 
      ),
    );
  }
}
class BookingCategoryCard extends StatelessWidget {
  const BookingCategoryCard({super.key, this.title, 
  this.image,
  this.onPressed});
  final String? title;
  final Function()? onPressed;
   final String? image;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.only(top: ScallingConfig.scale(5)),
        padding: EdgeInsets.only(
          top: ScallingConfig.scale(10),
          left: ScallingConfig.scale(20)),
        width: Utils.windowWidth(context) * 0.9,
        height: Utils.windowHeight(context) * 0.1,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(image!),  
            ),
            
        ),
        child: Row(
          children: [
            CustomText(
            text:title, 
            color: AppColors.white, 
            fontSize: ScallingConfig.moderateScale(18.88), 
            fontFamily: "",
            ),
            Icon(Icons.keyboard_arrow_right, color: AppColors.white,),
      
          ],
        ),),
    );
  }
}
