import 'package:flutter/material.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 600) {
      return const _WebTermsAndConditions();
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: CustomBackButton(),
        title: CustomText(
          text: "Terms & COnditions",
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
                    "Inceptos phasellus magnis netus at primis sodales torquent cras, LAKE potenti habitant lobortis aliquam turpis risus enim, cubilia natoque ligula aenean gravida nascetur curae.bibendum ullamcorper fames facilisis urna, ac tempor arcu ridiculus proin etiam diam taciti vivamus id pulvinar. Inceptos phasellus magnis netus at primis sodales torquent cras, lacus potenti habitant.",

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

class _WebTermsAndConditions extends StatelessWidget {
  const _WebTermsAndConditions();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: CustomBackButton(),
        title: CustomText(
          text: "Terms & Conditions",
          fontFamily: "Gilroy-Bold",
          fontSize: 20,
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.31,
          lineHeight: 1.0,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF1F4F9), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    offset: Offset(0, 4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Terms & Conditions",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      fontFamily: "Gilroy-Bold",
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Please read these terms carefully before using the ICare application.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                      fontFamily: "Gilroy-Medium",
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
                  const SizedBox(height: 32),
                  _buildSection(
                    "1. Acceptance of Terms",
                    "Lorem ipsum dolor sit amet consectetur adipiscing, elit congue nisi rutrum platea lacinia sapien, sed vel cras torquent scelerisque. Tempus pharetra quam congue natoque aptent sollicitudin et bibendum ullamcorper fames facilisis urna, ac tempor arcu ridiculus proin etiam diam taciti vivamus id pulvinar.",
                  ),
                  _buildSection(
                    "2. User Obligations",
                    "Inceptos phasellus magnis netus at primis sodales torquent cras, LAKE potenti habitant lobortis aliquam turpis risus enim, cubilia natoque ligula aenean gravida nascetur curae.bibendum ullamcorper fames facilisis urna, ac tempor arcu ridiculus proin etiam diam taciti vivamus id pulvinar. Inceptos phasellus magnis netus at primis sodales torquent cras, lacus potenti habitant.",
                  ),
                  _buildSection(
                    "3. Privacy Policy",
                    "Lobortis aliquam turpis risus enim, cubilia natoque ligula aenean gravida nascetur curae.bibendum ullamcorper fames facilisis urna, ac tempor arcu ridiculus proin etiam diam taciti vivamus id pulvinar. Inceptos phasellus magnis.",
                  ),
                  _buildSection(
                    "4. Limitation of Liability",
                    "Inceptos phasellus magnis netus at primis sodales torquent cras, lacus potenti habitant lobortis aliquam turpis risus enim, cubilia natoque ligula aenean gravida nascetur curae.bibendum ullamcorper fames facilisis urna, ac tempor arcu ridiculus proin etiam diam taciti vivamus id pulvinar.",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              fontFamily: "Gilroy-Bold",
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF64748B),
              height: 1.6,
              fontFamily: "Gilroy-Regular",
            ),
          ),
        ],
      ),
    );
  }
}
