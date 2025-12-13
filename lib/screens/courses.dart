import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/filters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/certificates_list.dart';
import 'package:icare/widgets/course_card.dart';
import 'package:icare/widgets/courses_list.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/custom_text_input.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class Courses extends StatefulWidget {
  const Courses({super.key});

  @override
  State<Courses> createState() => _CoursesState();
}

class _CoursesState extends State<Courses> with SingleTickerProviderStateMixin {
  
   late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
  }

  
  
  @override


  Widget build(BuildContext context) {
 
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: CustomBackButton(),
        title: CustomText(text: "Courses",),

      ),
      body: Center(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
          children: [
                       CustomInputField(
              width: Utils.windowWidth(context) * 0.9,
              
             hintText: "Search", 
             trailingIcon: SvgWrapper(assetPath: ImagePaths.filters,onPress: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> FiltersScreen()));
             },),
             leadingIcon: SvgWrapper(assetPath: ImagePaths.search),
             ),

          SizedBox(
            width: Utils.windowWidth(context),

            // height: Utils.windowHeight(context) * 0.06,
            child: TabBar(
            controller: controller,
            indicatorWeight: 6,
            indicatorColor: AppColors.themeBlack,
            tabs: [
              CustomText(
                text: "All Courses",
                
                padding: EdgeInsets.only(bottom:5),
                width: Utils.windowWidth(context) * 0.33,
                textAlign: TextAlign.center,
              ),
              CustomText(
                text: "My Purchase",
                padding: EdgeInsets.only(bottom:5),
                width: Utils.windowWidth(context) * 0.33,
                textAlign: TextAlign.center,
              ),
              CustomText(
                padding: EdgeInsets.only(bottom:5),
                width: Utils.windowWidth(context) * 0.33,
                textAlign: TextAlign.center,
                text: "Certificates",
              ),
            ],
                    ),
          ),   
          Expanded(child: TabBarView(
        controller: controller,
        children: [
          CoursesList(),
         CoursesList(mypurchased: true),
          CertificatesList(),
          
          
        ],
      ),),

            
          ],
        ),
      )
    );
  }
}