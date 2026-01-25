import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';

class DoctorsList extends StatelessWidget {
  const DoctorsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(
          text: "Doctors",
          fontFamily: "Gilroy-Bold",
          fontSize: 16.78,
          letterSpacing: -0.31,
          lineHeight: 1.0,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGray500,
        ),
      ),
      body: GridView.builder(
        itemCount: 8,
        padding: EdgeInsets.all(20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: Utils.windowHeight(context) * 0.28,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemBuilder: (ctx, i) {
          return (DoctorProfileCard());
        },
      ),
    );
  }
}

class DoctorProfileCard extends StatelessWidget {
  const DoctorProfileCard({super.key, this.width, this.padding});
  final double? width;
  final EdgeInsets? padding;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,

      padding: padding ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightGrey100,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: ScallingConfig.scale(-5),
            right: ScallingConfig.scale(-5),
            child: IconButton(onPressed: () {}, icon: Icon(Icons.favorite)),
          ),

          Column(
            children: [
              SizedBox(height: ScallingConfig.verticalScale(15)),

              CircleAvatar(
                backgroundColor: AppColors.darkGray400,
                radius: ScallingConfig.scale(40),
                child: Image.asset(ImagePaths.walkthrough1, fit: BoxFit.cover),
              ),
              SizedBox(height: ScallingConfig.scale(20)),
              CustomText(
                text: "Dr Aaron Smith",
                color: AppColors.themeDarkGrey,
                fontFamily: "Gilroy-Bold",
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              SizedBox(height: ScallingConfig.scale(10)),
              CustomText(
                text: "Therapist",
                color: AppColors.themeDarkGrey,
                fontFamily: "Gilroy-Regular",
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
              SizedBox(height: ScallingConfig.scale(10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    size: ScallingConfig.moderateScale(18),
                    color: AppColors.themeDarkGrey,
                  ),
                  SizedBox(width: ScallingConfig.scale(5)),
                  CustomText(
                    text: "4.5 (135 reviews)",
                    color: AppColors.themeDarkGrey,
                    fontFamily: "Gilroy-Regular",
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
