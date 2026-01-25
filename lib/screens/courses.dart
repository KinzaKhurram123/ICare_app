import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:icare/providers/auth_provider.dart';
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

class Courses extends ConsumerStatefulWidget {
  const Courses({super.key});

  @override
  ConsumerState<Courses> createState() => _CoursesState();
}

class _CoursesState extends ConsumerState<Courses> with SingleTickerProviderStateMixin {
  
   late TabController controller;
int? _currentTabLength;

// @override
// void didChangeDependencies() {
//   super.didChangeDependencies();

//   final role = ref.read(authProvider).userRole;
//   final newLength = role == "instructor" ? 1 : 3;

//   if (_currentTabLength != newLength) {
//     controller?.dispose();
//     controller = TabController(length: newLength, vsync: this);
//     _currentTabLength = newLength;
//   }
// }
  @override
  void initState() {
    super.initState();
   final role = ref.read(authProvider).userRole;
    controller = TabController(length: role == "instructor" ? 1 : 3, vsync: this);
  }

  
  
  @override
  Widget build(BuildContext context) {
   final role = ref.read(authProvider).userRole;
    log(role);
    log(controller.length.toString()); 
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: CustomBackButton(),
        title: CustomText(text: "Courses",
        fontFamily: "Gilroy-Bold",
            fontSize: 16.78,
            color: AppColors.primary500,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.31,
            lineHeight: 1.0,
        ),

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
           if(role == "instructor") ...[
             SizedBox(width: Utils.windowWidth(context) * 0.33,),
             SizedBox(width: Utils.windowWidth(context) * 0.33,),],
            if(role != "instructor") ...[CustomText(
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
              ),]
            ],
                    ),
          ),   
          Expanded(child: TabBarView(
        controller: controller,
        children: [
          CoursesList(),
          if(role != "instructor")...[

         CoursesList(mypurchased: true),
          CertificatesList(),
          ]
          
          
        ],
      ),),

            
          ],
        ),
      )
    );
  }
}