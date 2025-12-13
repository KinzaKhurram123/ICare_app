import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/select_payment_method.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';

class ViewCourse extends StatelessWidget {
  const ViewCourse({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(text: "Course"),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      // clipBehavior: Clip.none,
                      borderRadius: BorderRadiusGeometry.circular(20),
                      child: Image.asset(
                        ImagePaths.course1,
                        width: Utils.windowWidth(context) * 0.9,
            
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: Utils.windowWidth(context) * 0.4,
                      top: Utils.windowHeight(context) * 0.12,
                      child: CircleAvatar(
                        backgroundColor: AppColors.primaryColor,
            
                        child: Icon(Icons.pause, color: AppColors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Utils.windowHeight(context) * 0.032),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: Utils.windowHeight(context) * 0.08,
                      maxWidth: Utils.windowWidth(context) * 0.9,
                    ),
                    child: ListView.builder(
                      itemCount: 3,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (ctx, i) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.0),
                          child: (ClipRRect(
                            // clipBehavior: Clip.none,
                            borderRadius: BorderRadiusGeometry.circular(5),
                            child: Image.asset(
                              ImagePaths.course1,
                              width: Utils.windowWidth(context) * 0.28,
            
                              fit: BoxFit.cover,
                            ),
                          )),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: ScallingConfig.scale(6)),
                CustomText(
                  text: "Behavioral Therapist",
                  color: AppColors.primary500,
                  fontFamily: "Gilroy-Bold",
                  textAlign: TextAlign.left,
            
                  width: Utils.windowWidth(context) * 0.85,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                SizedBox(height: ScallingConfig.scale(7)),
                CustomText(
                  width: Utils.windowWidth(context) * 0.85,
                  text:
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea lokj jkh commodo consequat. Duis aute irure dolor abore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in jolki fokmj reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                  maxLines: 100,
                  textAlign: TextAlign.justify,
                  color: AppColors.grayColor,
                  fontSize: 12,
                  fontFamily: "Gilroy-Regular",
                ),
                SizedBox(height: ScallingConfig.scale(7)),
                CustomText(
                  width: Utils.windowWidth(context) * 0.85,
                  text:
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea lokj jkh commodo consequat. Duis aute irure dolor abore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in jolki fokmj reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                  maxLines: 100,
                  textAlign: TextAlign.justify,
                  color: AppColors.grayColor,
                  fontSize: 12,
                  fontFamily: "Gilroy-Regular",
                ),
                SizedBox(height: Utils.windowHeight(context) * 0.05),
              ],
            ),
            Positioned(
              left: ScallingConfig.scale(30),
              bottom: ScallingConfig.verticalScale(110),
              child: CustomButton(
                label: "Buy Full Course",
                 borderRadius: 30,
                 onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => SelectPaymentMethod()));
                 },
              ) 
            ),
          ],
        ),
      ),
    );
  }
}
