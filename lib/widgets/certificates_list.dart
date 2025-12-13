import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/view_certificate.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class CertificatesList extends StatelessWidget {
  const CertificatesList({super.key});

  @override
  Widget build(BuildContext context) {
List<Map<String, dynamic>> certificatesData = [
  {
    'title': 'Child Therapist',
    'completedCourses': 7,
    'totalCourses': 7,
    'completionPercentage': 100,
    'isComplete': true,
    'actions': ['View Certificate', 'Download Certificate'],
  },
  {
    'title': 'Behavioral Therapist',
    'completedCourses': 7,
    'totalCourses': 7,
    'completionPercentage': 100,
    'isComplete': true,
    'actions': ['View Certificate', 'Download Certificate'],
  },
  {
    'title': 'Child Therapist',
    'completedCourses': 7,
    'totalCourses': 7,
    'completionPercentage': 100,
    'isComplete': true,
    'actions': ['View Certificate', 'Download Certificate'],
  },
];
    return ConstrainedBox(constraints: BoxConstraints(maxHeight: Utils.windowHeight(context) * 0.6),
    child: ListView.builder(
      shrinkWrap: false,
      padding: EdgeInsets.symmetric(horizontal: 15),
      itemCount: certificatesData.length,
      itemBuilder: (ctx,i) {
        final item = certificatesData[i];
      return CertifcateCard(
        courseTitle: item['title'],
        completedSections: item['completedCourses'].toString(),
        totalSections: item['totalCourses'].toString(),
        completionPercentage: item['completionPercentage'].toString(),
      );
    }),
    );
  }
}



class CertifcateCard extends StatelessWidget {
  const CertifcateCard({super.key, 
  this.courseTitle,
  this.totalSections,
  this.completedSections,
  this.completionPercentage
  });
  final String? courseTitle;
  final String? totalSections;
  final String? completedSections;
  final String? completionPercentage;

  @override
  Widget build(BuildContext context) {
    return Container(
           width: Utils.windowWidth(context) * 0.8,
           padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(20), vertical: ScallingConfig.verticalScale(10)),
      margin: EdgeInsets.only(top: ScallingConfig.verticalScale(12)),
      clipBehavior: Clip.hardEdge,

      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.lightGrey300
        ),
        boxShadow: [
          BoxShadow(
            blurStyle: BlurStyle.inner,
            spreadRadius: 5,
            blurRadius: 7,
            color: AppColors.lightGrey200.withAlpha(90),
            offset: Offset(1, 2),
          ),
        ],
        color: AppColors.white50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             SvgWrapper(assetPath: ImagePaths.success, width: ScallingConfig.scale(35),),
             SizedBox(width: ScallingConfig.scale(10),),
             Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              CustomText(text:courseTitle ?? "", fontSize: 14, color: AppColors.themeDarkGrey, fontFamily: "Gilroy-Bold", fontWeight: FontWeight.bold,),
                Row(
                  children: [
                    CustomText(text: '${completedSections ?? " "} / ${totalSections ?? " "} ', fontSize: 12, color: AppColors.grayColor, fontFamily: "Gilroy-SemiBold",),
                    CustomText(text: '${completionPercentage ?? " "}% Completed', fontSize: 12, color: AppColors.grayColor, fontFamily: "Gilroy-SemiBold",),
                  ],
                )
              ],
             )
            ],
          ),
          SizedBox(height: ScallingConfig.scale(10),),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: ScallingConfig.scale(5) ,),
              CustomText(
                text: "View Certicate",
                underline: true,
                fontSize: 12.99,
                color: AppColors.primary500,
                fontFamily: "Gilroy-Bold",
                fontWeight: FontWeight.bold,
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ViewCertificate() ));
                },
              ),
              SizedBox(width: ScallingConfig.scale(10) ,),
              CustomText(
                text: "Download Certicate",
                underline: true,
                fontSize: 12.99,
                color: AppColors.primary500,
                fontFamily: "Gilroy-Bold",
                fontWeight: FontWeight.bold,
                onTap: (){
                  // Navigator.of(context).push
                  //(MaterialPageRoute(builder: (ctx) => ))
                },

              ),
            ],
          )
        ],
      ),
    );
  }
}