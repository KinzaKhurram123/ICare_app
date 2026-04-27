import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:flutter_steps/flutter_steps.dart';
import 'package:icare/models/app_enums.dart';
import 'package:icare/screens/cancellation_reason.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_circle_icon_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/order_card.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class ManageOrders extends StatelessWidget {
  const ManageOrders({super.key});

  @override
  Widget build(BuildContext context) {
    List<Steps> basicSteps = [
      Steps(
        leading: SvgWrapper(assetPath: ImagePaths.success),
        title: 'Confirmed Order',
        subtitle: '22/9/2025',
        isActive: true,
      ),
      Steps(
        leading: SvgWrapper(assetPath: ImagePaths.success),
        title: 'Pharmacy is preparing your order',
        subtitle: '',

        isActive: true,
      ),
      Steps(
        leading: SvgWrapper(assetPath: ImagePaths.success),
        title: 'In Transit',
        // subtitle: 'Subtitle',
        isActive: false,
      ),
      Steps(
        leading: SvgWrapper(assetPath: ImagePaths.success),
        title: 'Out for Delievery',
        // subtitle: 'Subtitle',
        isActive: false,
      ),
      Steps(
        leading: SvgWrapper(assetPath: ImagePaths.success),
        title: 'Delievered',
        // subtitle: 'Subtitle',
        isActive: false,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(
          text: 'Manage Orders',
          fontFamily: "Gilroy-Bold",
          fontSize: 16.78,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.31,
          lineHeight: 1.0,
          color: AppColors.primary500,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: ScallingConfig.scale(20)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScallingConfig.scale(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: "Estimated Time",
                        fontFamily: "Gilroy-Regular",
                        fontSize: 14.79,
                        color: AppColors.primary500,
                        fontWeight: FontWeight.w400,
                      ),
                      CustomText(
                        text: "1 hour",
                        fontFamily: "Gilroy-Bold",
                        fontSize: 14.79,
                        color: AppColors.primary500,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      CustomText(
                        text: "Tracking ID",
                        fontFamily: "Gilroy-Regular",
                        fontSize: 14.79,
                        color: AppColors.primary500,
                        fontWeight: FontWeight.w400,
                      ),
                      CustomText(
                        text: "28194",
                        fontFamily: "Gilroy-Bold",
                        fontSize: 14.79,
                        color: AppColors.primary500,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: ScallingConfig.scale(50)),
            SizedBox(
              height: Utils.windowHeight(context) * 0.4,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScallingConfig.scale(15),
                ),
                child: FlutterSteps(
                  steps: basicSteps,
                  titleFontSize: 12,
                  showStepLine: true,

                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Gilroy-SemiBold",
                    color: AppColors.primary500,
                  ),
                  inactiveStepLineColor: AppColors.grayColor.withAlpha(60),
                  leadingSizeFactor: ScallingConfig.scale(1.5),
                  hideInactiveLeading: true,
                  showSubtitle: true,

                  activeStepLineColor: AppColors.themeGreen,
                  titleActiveColor: AppColors.primary500,
                  subtitleStyle: TextStyle(
                    fontSize: 12,
                    fontFamily: "Gilroy-Medium",
                    color: AppColors.primary500,
                  ),
                  direction: Axis.vertical,
                  inactiveColor: AppColors.grayColor.withAlpha(60),
                ),
              ),
            ),
            SizedBox(height: ScallingConfig.scale(50)),
            CustomButton(label: "Update Status", borderRadius: 40),
            CustomText(
              text: "Cancel order",
              margin: EdgeInsets.only(top: ScallingConfig.scale(10)),
              color: AppColors.themeRed,
              fontSize: 14,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => CancellationReason()),
                );
              },
              fontFamily: "Gilroy-Bold",
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }
}
