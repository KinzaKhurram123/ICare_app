import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/labb_details.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class Laboratory extends StatelessWidget {
  const Laboratory({super.key, this.margin});
  final EdgeInsets? margin;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Utils.windowWidth(context) * 0.85,
      height: Utils.windowHeight(context) * 0.25,
      margin: margin ?? EdgeInsets.zero,
      // padding: EdgeInsets.only(top: ScallingConfig.verticalScale(20)),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage(ImagePaths.lab3) 
        )
      ),
      child: Stack(
        alignment: AlignmentGeometry.bottomCenter,
        children: [
          Container(
            height: Utils.windowHeight(context) * 0.1,
            // width: Utils.windowWidth(context),
            padding: EdgeInsets.symmetric(horizontal:ScallingConfig.scale(10)),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(topRight: Radius.circular(18),topLeft: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  // mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   
                SizedBox(height: ScallingConfig.scale(5),),
                    CustomText(
                      text: "Quantum Spar Lab",
                      fontSize: 14,

                      fontFamily: "Gilroy-Bold",
                      fontWeight: FontWeight.bold,
                      color: AppColors.themeDarkGrey,
                    ),
                    SizedBox(height: ScallingConfig.scale(5),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgWrapper(assetPath: ImagePaths.marker2, width: ScallingConfig.scale(15),height: ScallingConfig.scale(15),),
                        SizedBox(width: ScallingConfig.scale(5),),
                        CustomText(
                          text: "4915 Muller Radial, 84904, USA",
                          fontFamily: "Gilroy-Medium",
                          fontSize: 10,
                          color: AppColors.grayColor,
                        ),
                      ],
                    ),
                    SizedBox(height: ScallingConfig.scale(5),),
                    Row(
                      children: [
                        SvgWrapper(assetPath: ImagePaths.home_edit, width: ScallingConfig.scale(15),height: ScallingConfig.scale(15),),
                        SizedBox(width: ScallingConfig.scale(5),),
                        CustomText(
                          text: "Home Sample Available",
                          fontFamily: "Gilroy-Medium",
                          fontSize: 10,
                          color: AppColors.grayColor,
                        ),
                      ],
                    ),
                
                  ],
                ),
                
                Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(height: ScallingConfig.scale(5),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SvgWrapper(assetPath: ImagePaths.clock),
                          SizedBox(width: ScallingConfig.scale(5),),
                          CustomText(
                            text: "Open at 9:00am",
                            fontFamily: "Gilroy-Regular",
                            fontSize: 10,
                            color: AppColors.themeDarkGrey,
                          ),
                        ],
                      ),
                  
                      SizedBox(height: ScallingConfig.scale(15),),
                  
                      CustomButton(
                        label: "Visit",
                        width: Utils.windowWidth(context) * 0.2,
                        height: ScallingConfig.scale(30),
                        borderRadius: 20,
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => LabDetails()));
                        },
                  
                      )
                    ],
                  ),
                              ],
            ),
          ),
        ],
      ),
    );
  }
}
