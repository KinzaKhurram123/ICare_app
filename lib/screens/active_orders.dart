import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';

class ActiveOrdersScreen extends StatelessWidget {
  const ActiveOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFA),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
      
       statusBarIconBrightness: Brightness.dark,
       statusBarBrightness: Brightness.light,   
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: CustomBackButton(),
        title: CustomText(
          text: "Active Orders",
          fontSize: 16.78,
          fontFamily: "Gilroy-Bold",
          fontWeight: FontWeight.bold,
          letterSpacing: -0.31,
          lineHeight: 1.0,
          color: AppColors.primary500,
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 2,
        itemBuilder: (context, index) {
          return const CompletedReportCard();
        },
      ),
    );
  }
}

class CompletedReportCard extends StatelessWidget {
  const CompletedReportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 19),
      decoration: BoxDecoration(
        color:AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
              text: "Quantum Spar Lab",
              fontSize: 18, 
          fontFamily: "Gilroy-Bold",
          fontWeight: FontWeight.bold,
          color: AppColors.themeDarkGrey,
            ),
          const SizedBox(height: 12),

          _infoRow('Patient Name', 'Sadia'),
          _infoRow('Address', 'Shahrah-e-faisal near KFC\nStreet 1'),
          _infoRow('Age', '32'),
          _infoRow('Date', '21 June 2025'),
          _infoRow('Time', '12:PM'),
          _infoRow('Phone Number', '03098949375'),

          const SizedBox(height: 12),
          // const Divider(),

          Row(

            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              CustomText(
              text: "Status",
              fontSize: 12, 
          fontFamily: "Gilroy-Medium",
          fontWeight: FontWeight.w400,
          color: AppColors.themeDarkGrey,
            ),
CustomText(
              text: "Sample Ready for test",
              fontSize: 12, 
          fontFamily: "Gilroy-Bold",
          fontWeight: FontWeight.w400,
          color: AppColors.themeDarkGrey,
            )
            ],
          ),
        ],
      ),
    );
  }

  static Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
 CustomText(
              text: label,
              fontSize: 13, 
          fontFamily: "Gilroy-Medium",
          fontWeight: FontWeight.w400,
          color: AppColors.themeDarkGrey,
            ),

CustomText(
              text: value,
              fontSize: 13, 
          fontFamily: "Gilroy-SemiBold",
          fontWeight: FontWeight.w400,
          color: AppColors.themeDarkGrey,
            ) 
        ],
      ),
    );
  }
}
