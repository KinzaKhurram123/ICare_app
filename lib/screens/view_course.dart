import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/select_payment_method.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';

class ViewCourse extends ConsumerWidget {
  const ViewCourse({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role =ref.read(authProvider).userRole;
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(text: "Course",
                      fontFamily: "Gilroy-Bold",
              fontSize: 16.78,
              fontWeight: FontWeight.bold,
              color: AppColors.primary500,
              letterSpacing: -0.31,
              lineHeight: 1.0,

        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
               if(role == "student") ...[ CustomText(
                maxLines: 4,
                width: Utils.windowWidth(context) * 0.9,
                padding: EdgeInsets.symmetric(vertical: ScallingConfig.verticalScale(10)  ),
                              fontFamily: "Gilroy-SemiBold",
              fontSize: 14,
              color: AppColors.themeRed,
              letterSpacing: -0.31,
              lineHeight: 1.0,
                text: "You just have 10 sec trial to gain idea, what this course about.  You have to purchase this course to see full video.",
               ),],
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
            if(role != "instructor") ...[Positioned(
              left: ScallingConfig.scale(30),
              bottom: ScallingConfig.verticalScale(80),
              child: CustomButton(
                label: "Buy Full Course",
                 borderRadius: 30,
                 onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => SelectPaymentMethod()));
                 },
              ) 
            ),]
          ],
        ),
      ),
    );
  }
}
