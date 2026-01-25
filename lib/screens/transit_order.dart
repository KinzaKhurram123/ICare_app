import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:flutter_steps/flutter_steps.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/app_modals.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class TransitOrderScreen extends StatelessWidget {
  const TransitOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Steps> basicSteps = [
      Steps(
        leading: SvgWrapper(assetPath: ImagePaths.success),
        title: 'Order Received',
        subtitle: '22/9/2025',
        isActive: true,
      ),
      Steps(
        leading: SvgWrapper(assetPath: ImagePaths.success),
        title: 'Processing',
        subtitle: '',
        isActive: true,
      ),
      Steps(
        leading: SvgWrapper(assetPath: ImagePaths.success),
        title: 'Shipped',
        subtitle: '',
        isActive: false,
      ),
      Steps(
        leading: SvgWrapper(assetPath: ImagePaths.success),
        title: 'In Transit',
        subtitle: '',
        isActive: false,
      ),
      Steps(
        leading: SvgWrapper(assetPath: ImagePaths.success),
        title: 'Delievered',
        subtitle: '',
        isActive: false,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(
          text: 'Transit Order',
          fontFamily: "Gilroy-Bold",
          fontSize: 16.78,
          fontWeight: FontWeight.bold,
          color: AppColors.primary500,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ScallingConfig.scale(26),
          vertical: ScallingConfig.scale(16),
          ),
        child: Column(
          spacing: ScallingConfig.scale(6),
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'Update Order',
              fontSize: 14.78,
              fontFamily: "Gilroy-Regular",
              fontWeight: FontWeight.w400,
            ),
            SizedBox(
              height: Utils.windowHeight(context) * 0.37,
              child: FlutterSteps(
                steps: basicSteps,
                titleFontSize: 12,
                showStepLine: true,
                crossAxisAlignment: CrossAxisAlignment.center,
               
                titleStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Gilroy-SemiBold",
                  color: AppColors.primary500,
                ),
                inactiveStepLineColor: AppColors.lightGrey10,
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
                inactiveColor:  AppColors.lightGrey10,
              ),
            ),
            TextButton(onPressed: (){
              AppDialogs.showWarningDialog(context, "Warning!", "Are You SUre", null);
                  // AppModals.showSuccessModal(context, null, null);
            }, child:  Text("Track Order",))
          ],
        ),
      ),
    );
  }
}
