import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key, this.margin});
  final EdgeInsets? margin;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
         Navigator.of(context).pop();        
      },
      child: Container(
       margin: margin ?? EdgeInsets.only(left:21), 
        // width: ScallingConfig.scale(30), 
        // height: ScallingConfig.scale(10), 
        // padding: EdgeInsets.all(12),
        // decoration: BoxDecoration(
        //   border: Border.all(
        //     // color: Colors.black
        //   ),
          // color: AppColors.themeRed,
          // borderRadius: BorderRadius.circular((Utils.windowWidth(context) * 0.2 / 2)),
        // ),
        child: Center(
          child: SvgWrapper(
            assetPath: ImagePaths.back 
        )),
      ),
    );
  }
}