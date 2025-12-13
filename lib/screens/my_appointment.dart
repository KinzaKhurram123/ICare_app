import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class MyAppointment extends StatelessWidget {
  const MyAppointment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: CustomBackButton(),
        title: CustomText(
          text: "My Appointment",
          fontSize: 16.78,
          fontFamily: "Gilroy-Bold",
          fontWeight: FontWeight.w400,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileInfoWidget(),
            DetailsInfoWidget(
              title: "Scheduled Appointment",
              data: {
                "Date": "December, 05, 2025",
                "Time": "10:00 AM – 10:30 AM (30 minutes)",
                "Booking for": "Self",
              },
            ),
            DetailsInfoWidget(
              title: "Patient Info",
              data: {
                "Gender": "Female",
                "Age": "32",
                "Patient Guardians": "Guardians",
                "Problem": "N/A",
              },
            ),
            SizedBox(height: ScallingConfig.scale(10)),
            AmountContainer(leadingText: "PKR Rs.", trailingText: "2000"),
            SizedBox(height: ScallingConfig.scale(20)),
            HorizontalText(
              padding: EdgeInsets.symmetric(
                horizontal: ScallingConfig.scale(15),
                vertical: ScallingConfig.scale(10),
              ),
              leadingText: "Service charges",
              trailingText: "Rs. 2000",
            ),

            HorizontalText(
              padding: EdgeInsets.symmetric(
                horizontal: ScallingConfig.scale(15),
                vertical: ScallingConfig.scale(10),
              ),
              leadingText: "App Deduction (20%)",
              trailingText: "-Rs. 200",
            ),

            HorizontalText(
              padding: EdgeInsets.symmetric(
                horizontal: ScallingConfig.scale(15),
                vertical: ScallingConfig.scale(10),
              ),
              leadingText: "Total Balance",
              trailingText: "Rs. 1800",
            ),
            SizedBox(height: ScallingConfig.scale(20),)
          ],
        ),
      ),
    );
  }
}

class ProfileInfoWidget extends StatelessWidget {
  const ProfileInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Utils.windowWidth(context),
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: AppColors.white),
      child: Row(
        children: [
          Container(
            width: Utils.windowWidth(context) * 0.25,
            height: Utils.windowWidth(context) * 0.25,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Image.asset(ImagePaths.user1, fit: BoxFit.cover),
          ),
          SizedBox(width: ScallingConfig.scale(12)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(text: "Emily Jordan", isSemiBold: true),
                    // Spacer(),
                    SizedBox(width: ScallingConfig.scale(50)),
                    CustomText(
                      text: "View Profile",
                      underline: true,
                      onTap: () {},

                      isSemiBold: true,
                    ),
                  ],
                ),
                SizedBox(height: ScallingConfig.scale(10)),
                Row(
                  children: [
                    SvgWrapper(assetPath: ImagePaths.location),
                    SizedBox(width: Utils.windowWidth(context) * 0.025),
                    CustomText(
                      text: "20 Cooper Square, USA",
                      fontSize: 12,
                      color: AppColors.darkGreyColor,
                    ),
                  ],
                ),
                Row(
                  children: [
                    SvgWrapper(assetPath: ImagePaths.scan),
                    SizedBox(width: Utils.windowWidth(context) * 0.025),
                    CustomText(text: "Booking ID: #DR452SA54", fontSize: 12),
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

class DetailsInfoWidget extends StatelessWidget {
  const DetailsInfoWidget({super.key, this.title = '', required this.data});

  final String title;
  final Map<String, String> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      margin: EdgeInsets.only(top: 12),
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(text: title, fontSize: 14, isBold: true),
            ...data.entries.map((item) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: item.key,
                      fontSize: 12,
                      color: AppColors.darkGreyColor,
                    ),
                    CustomText(
                      text: item.value,
                      isBold: true,
                      color: AppColors.darkGreyColor,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class HorizontalText extends StatelessWidget {
  const HorizontalText({
    super.key,
    this.leadingText,
    this.trailingText,
    this.padding,
  });
  final String? leadingText;
  final String? trailingText;
  final EdgeInsets? padding;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: leadingText ?? "",
                fontFamily: "Gilroy-Regular",
                fontSize: 14.78,
                fontWeight: FontWeight.bold,
                color: AppColors.primary500,
              ),
              CustomText(
                text: trailingText ?? "",
                fontFamily: "Gilroy-Bold",
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreyColor,
              ),
            ],
          ),
          SizedBox(height: ScallingConfig.scale(5)),
          Divider(),
        ],
      ),
    );
  }
}

class AmountContainer extends StatelessWidget {
  const AmountContainer({super.key, this.leadingText, this.trailingText});

  final String? leadingText;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Utils.windowWidth(context) * 0.85,
      padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(20), vertical: ScallingConfig.verticalScale(20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(
          color: AppColors.lightGrey200,  
        ),
        borderRadius: BorderRadius.circular(40)

      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: leadingText ?? "",
            fontFamily: "Gilroy-Medium",
            fontSize: 16,
            // fontWeight: FontWeight.bold,
            color: AppColors.primary500,
          ),
          CustomText(
            text: trailingText ?? "",
            fontFamily: "Gilroy-SemiBold",
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGreyColor,
          ),
        ],
      ),
    );
  }
}
