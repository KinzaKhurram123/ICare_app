import 'package:flutter/material.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: CustomBackButton(),
        title: CustomText(
          text: "About Us",
          fontWeight: FontWeight.bold,
          letterSpacing: -0.31,
          lineHeight: 1.0,
          fontSize: 16.78,
          fontFamily: "Gilroy-Bold",
          color: AppColors.primary500,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              CustomText(
                fontFamily: "Gilroy-Regular",
                width: Utils.windowWidth(context) * 0.85,
                textAlign: TextAlign.left,
                maxLines: 7,
                text:
                    "Lorem ipsum dolor sit amet consectetur adipiscing, elit congue nisi rutrum platea lacinia sapien, sed vel cras torquent scelerisque. Tempus pharetra quam congue natoque aptent sollicitudin et bibendum ullamcorper fames facilisis urna, ac tempor arcu ridiculus proin etiam diam taciti vivamus id pulvinar.",
                color: AppColors.themeDarkGrey,
                fontSize: 12,
              ),
              SizedBox(height: Utils.windowHeight(context) * 0.023),
              CustomText(
                fontFamily: "Gilroy-Regular",
                width: Utils.windowWidth(context) * 0.85,
                textAlign: TextAlign.left,
                maxLines: 10,
                text:
                    "Inceptos phasellus magnis netus at primis sodales torquent cras, lacus potenti habitant lobortis aliquam turpis risus enim, cubilia natoque ligula aenean gravida nascetur curae.bibendum ullamcorper fames facilisis urna, ac tempor arcu ridiculus proin etiam diam taciti vivamus id pulvinar. Inceptos phasellus magnis netus at primis sodales torquent cras, lacus potenti habitant.",

                color: AppColors.themeDarkGrey,
                fontSize: 12,
              ),
              SizedBox(height: Utils.windowHeight(context) * 0.023),
              CustomText(
                fontFamily: "Gilroy-Regular",
                width: Utils.windowWidth(context) * 0.85,
                textAlign: TextAlign.left,
                maxLines: 7,
                text:
                    "Lobortis aliquam turpis risus enim, cubilia natoque ligula aenean gravida nascetur curae.bibendum ullamcorper fames facilisis urna, ac tempor arcu ridiculus proin etiam diam taciti vivamus id pulvinar. Inceptos phasellus magnis.",
                color: AppColors.themeDarkGrey,
                fontSize: 12,
              ),
              SizedBox(height: Utils.windowHeight(context) * 0.023),
              CustomText(
                fontFamily: "Gilroy-Regular",
                width: Utils.windowWidth(context) * 0.85,
                textAlign: TextAlign.left,
                maxLines: 7,
                text:
                    "Inceptos phasellus magnis netus at primis sodales torquent cras, lacus potenti habitant lobortis aliquam turpis risus enim, cubilia natoque ligula aenean gravida nascetur curae.bibendum ullamcorper fames facilisis urna, ac tempor arcu ridiculus proin etiam diam taciti vivamus id pulvinar.",
                color: AppColors.themeDarkGrey,
                fontSize: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
