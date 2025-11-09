import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key, this.margin});
  final double? margin;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
         Navigator.of(context).pop();        
      },
      child: Container(
       margin: EdgeInsets.only(left:21), 
        width: Utils.windowWidth(context) * 0.1, 
        height: Utils.windowWidth(context) * 0.1, 
        // padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
        
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: SvgWrapper(
            assetPath: ImagePaths.back 
        )),
      ),
    );
  }
}