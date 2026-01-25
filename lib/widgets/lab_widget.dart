import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/models/lab.dart';
import 'package:icare/screens/book_lab.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class LabWidget extends StatelessWidget {
  const LabWidget({super.key, required this.lab, this.actionText='', this.onActionBtnPressed});
  final Lab lab;
  final String actionText;
  final VoidCallback? onActionBtnPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Utils.windowWidth(context) * 0.9,
      padding: EdgeInsets.symmetric(vertical: ScallingConfig.verticalScale(15), horizontal: ScallingConfig.scale(10)),
      margin: EdgeInsets.only(top: ScallingConfig.verticalScale(10)),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.lightGrey100,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
        
        borderRadius: BorderRadius.circular(10),
        color: AppColors.white,
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(18),
                clipBehavior: Clip.hardEdge,
                // clipper: CustomClipper<>(reclip: ),
                child: Image.asset(
                  lab.photo!,
                  fit: BoxFit.cover,
                  width: ScallingConfig.scale(80),
                  height: ScallingConfig.scale(80),
                ),
              ),
              SizedBox(width: ScallingConfig.scale(10)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: lab.title!,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Gilroy-Bold",
                        color: AppColors.themeDarkGrey,
                      ),
                      SizedBox(width: ScallingConfig.scale(100)),
                      Icon( lab.appointmentFee.toString().isNotEmpty ? Icons.attach_money : Icons.star, color: Colors.amber),
                      CustomText(
                        text: lab.appointmentFee  ?? lab.rating,
                        fontFamily: "Gilroy-Bold",
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                  SizedBox(height: ScallingConfig.verticalScale(5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgWrapper(assetPath: ImagePaths.location),
                      SizedBox(width: ScallingConfig.scale(6)),
                      CustomText(
                        text: lab.address,
                        color: AppColors.darkGreyColor,
                        fontSize: 12,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgWrapper(assetPath: ImagePaths.delievry),
                      SizedBox(width: ScallingConfig.scale(6)),
                      CustomText(
                        text: lab.delivery,
                        color: AppColors.darkGreyColor,
                        fontSize: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        if(lab.tests!.isNotEmpty) ...[SizedBox(height: ScallingConfig.scale(10)),
          SizedBox(width: Utils.windowWidth(context) * 0.85,
            child: Row(
              children: [
                ...lab.tests!.map((labTest)=> CustomText(text: labTest ,
                bgColor: AppColors.veryLightGrey,
                color: AppColors.darkGreyColor,
                padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(5), vertical: ScallingConfig.verticalScale(2)),
                margin: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(8)),
                fontSize: 10,
                fontFamily: "Gilroy-Bold",
                fontWeight: FontWeight.w400,
                )),
              ],
            ),
          ),],
          SizedBox(height: ScallingConfig.scale(10)),
          CustomButton(
            label: actionText ,
            width: Utils.windowWidth(context) * 0.84,
            height: ScallingConfig.scale(50),
            borderRadius: 35,
            onPressed: onActionBtnPressed ?? (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => BookLabScreen() ));
       
            },
          ),
        ],
      ),
    );
  }
}
