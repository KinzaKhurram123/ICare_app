import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_text.dart';

class SelectUserType extends ConsumerStatefulWidget {
  const SelectUserType({super.key});

  @override
  ConsumerState<SelectUserType> createState() => _SelectUserTypeState();
}

class _SelectUserTypeState extends ConsumerState<SelectUserType> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: Utils.windowWidth(context),
        height: Utils.windowHeight(context),
        padding: EdgeInsets.only(top:ScallingConfig.verticalScale(40), left:ScallingConfig.scale(10) , right: ScallingConfig.scale(10)),
        decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/images/bgImage.jpeg", ),
         fit: BoxFit.cover
        )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomText(text: "Select Type Of Your Account",
            fontSize:25.27,
            maxLines: 2,
            color: AppColors.themeBlue,
            width: Utils.windowWidth(context) * 0.5 ,
            fontWeight: FontWeight.w700,
            isBold: true,
            ),
            CustomText(text: "Choose the type of your account, Note: Account type cannot be changed later",
            padding: EdgeInsets.only(top: ScallingConfig.verticalScale(10)),
            width: Utils.windowWidth(context) * 0.8 ,
            textAlign: TextAlign.start,
            fontSize: 12.60,
            maxLines: 2,
            isSemiBold: true,
                  ),
            Card(
              
              color: AppColors.white, 
              child: Container(
                
                width: Utils.windowWidth(context) * 0.85,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Column(
                    children: [
                    CustomText(
                      textAlign: TextAlign.start,
                      text: "I'm a doctor" ,
                      isBold: true,
                      width: Utils.windowWidth(context) * 0.45,
                    ),
                    CustomText(
                      text: "The easy way to reach your Doctor face-to-face." ,
                      width: Utils.windowWidth(context) * 0.6,
                      maxLines: 4,
                    ),

                    ],
                  ),
                    SizedBox(
                      width: Utils.windowWidth(context) * 0.24,
                      height: Utils.windowWidth(context) * 0.3,
                      child: Image.asset(

                        ImagePaths.userType1,
                        fit: BoxFit.cover,
                      ),
                    )
                  ],
                )
                ,
                ),
            
              ),
              
            

          ],
        ) 
    );
  }
}