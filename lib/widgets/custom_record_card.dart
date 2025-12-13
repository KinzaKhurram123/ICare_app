import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';

import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_text.dart';


class CustomRecordCard extends StatelessWidget {
  const CustomRecordCard({super.key, this.icon, this.label, this.number, this.color= AppColors.secondaryColor  });
  
  final String? label;
  final Widget? icon;
  final String? number;
  final Color color; 

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      width: Utils.windowWidth(context) * 0.42,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          if(icon !=null) ...[icon!],
          SizedBox(height: ScallingConfig.scale(4)),
          CustomText(text: number ?? "", 
          fontSize: 27,
          fontFamily: "Gilroy-Bold",
          fontWeight: FontWeight.bold,
          color: AppColors.white,
          ),
          CustomText(text: label ?? "",
            fontSize: 12,
          fontFamily: "Gilroy-Medium",
          fontWeight: FontWeight.w400,
          color: AppColors.white,
          ),
        ],
      ),
    );
  }
}