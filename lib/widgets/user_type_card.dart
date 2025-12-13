import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_text.dart';

class UserTypeCard extends StatelessWidget {
  const UserTypeCard({super.key, required this.title, required this.description, 
  required this.onPressed,
  required this.image, this.isSelected = false});
  final String title;
  final GestureTapCallback onPressed;
  final String description;
  final String image;
  final bool isSelected;
  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: onPressed,
      child: Container(
              margin: EdgeInsets.only(top:ScallingConfig.verticalScale(10)),
                  // padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(42)),
                  width: Utils.windowWidth(context) * 0.85,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                   color: AppColors.grayColor.withAlpha(20),
                   border: isSelected ? Border.all(
                    width: 2,
                    color: AppColors.primaryColor
                   ) : null, 
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    SizedBox(width: Utils.windowWidth(context) * 0.08),  
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      CustomText(
      
                        text: title ,
                        isBold: true,
                      ),
                      CustomText(
                        text: description ,
                        width: Utils.windowWidth(context) * 0.4,
                        maxLines: 4,
                      ),
      
                      ],
                    ),
                  SizedBox(width: Utils.windowWidth(context) * 0.1,),
                      Flexible(
                        child: SizedBox(
                          width: Utils.windowWidth(context) * 0.25,
                          height: Utils.windowWidth(context) * 0.4,
                          child: Image.asset(
                            image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: Utils.windowWidth(context) * 0.025,)
                    ],
                  )
                  ,
                  ),
    );
  }
}