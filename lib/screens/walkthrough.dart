import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/login.dart';
import 'package:icare/screens/select_user_type.dart';
import 'package:icare/utils/shared_pref.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:intro_slider/intro_slider.dart';

class Walkthrough extends ConsumerStatefulWidget {
  const Walkthrough({super.key});

  @override
  ConsumerState<Walkthrough> createState() => _WalkthroughState();
}

class _WalkthroughState extends ConsumerState<Walkthrough> {
      final List<ContentConfig> listContentConfig = [
        ContentConfig(
          title: "More Comfortable Chat With the Doctor",
          description: "Book an appointment with doctor. Chat with doctor via appointment letter and get consultation.",
          pathImage: "assets/images/walkthrough1.png", 
        ),
        ContentConfig(
          title: "More Comfortable Chat With the Doctor",
          description: "Book an appointment with doctor. Chat with doctor via appointment letter and get consultation.",
          pathImage: "assets/images/walkthrough2.png", 
        ),
        ContentConfig(
          title: "More Comfortable Chat With the Doctor",
          description: "Book an appointment with doctor. Chat with doctor via appointment letter and get consultation.",
          pathImage: "assets/images/walkthrough3.png", 
        ),
      ];
 int currentIndex = 0;
  late Function goToTab;

  void onDonePress() {
    debugPrint("🎯 Onboarding Complete!");
    // Navigate to home screen here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroSlider(
        refFuncGoToTab: (refFunc) {
          goToTab = refFunc;
        },
        onTabChangeCompleted: (index) {
          setState(() => currentIndex = index);
        },
        
        navigationBarConfig: NavigationBarConfig(
        navPosition: NavPosition.top,

        ),
        isShowDoneBtn: false,
        isShowNextBtn: false,
        isShowSkipBtn: false,
        isShowPrevBtn: false,
        indicatorConfig: IndicatorConfig(isShowIndicator: false),
        listCustomTabs: listContentConfig.asMap().entries.map((entry) {
          final int index = entry.key;
          final ContentConfig item = entry.value; 
          return Stack(
            children: 
              [Container(
                // clipBehavior: Clip.hardEdge,
                    width: Utils.windowWidth(context),
                    height: Utils.windowHeight(context),
                    decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage("assets/images/bgImage.jpeg", ),
                     fit: BoxFit.cover
                    )
                    ),
                    child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Row(
                // mainAxisAlignment: MainAxisAlignment.end,
                // children: [
                 
            
              SizedBox(
                width: Utils.windowWidth(context) * 0.7,
                height: Utils.windowHeight(context) * 0.55,
                child: Image.asset(item.pathImage!,
             
                fit: BoxFit.cover,   
                ),
              ),
              Container(
                clipBehavior: Clip.hardEdge,
                padding: EdgeInsets.symmetric(
                horizontal: ScallingConfig.moderateScale(20), 
                vertical: ScallingConfig.moderateScale(25)),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(ScallingConfig.moderateScale(22.6)),
                    topLeft: Radius.circular(ScallingConfig.moderateScale(22.6)))
                ),
            
                child: Column(
                  spacing: 25,
                  children: [
                              
            
                    Text(item.title!,
                    style:  TextStyle(
                      fontSize: ScallingConfig.moderateScale(23.7),
                      color:AppColors.primary500,
            
                    ) ,
                    textAlign:  TextAlign.center),
                    Text(item.description!,
                    style: TextStyle(
                      color: AppColors.grayColor,
                      fontSize: ScallingConfig.moderateScale(12.5)
                    ),
                    ),
                  
              Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          listContentConfig.length,
                          (dotIndex) => AnimatedContainer(
                            duration: const Duration(milliseconds: 10),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            height: 8,
                            width: currentIndex == dotIndex ? 20 : 8,
                            decoration: BoxDecoration(
                              color: currentIndex == dotIndex
                                  ? Colors.red
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
            
                    CustomButton(label:  index != 2 ? "Next" : "Done", 
                    onPressed: (){
                   print('${currentIndex < index}');
                  if(index != 2) {
                   goToTab(currentIndex + 1);
                  }else{
                    Navigator.of(context).push(MaterialPageRoute(builder: (ctx){
                      return SelectUserType();
                    }));
                    // ref.watch(authProvider.notifier).setUserWalkthrough(true);
                    // SharedPref().setUserWalkthrough(true);
                  }
                    },
                    borderRadius: 40, 
                    
                    ),
            
                  ])
              )
            ]
                    )
                  ),
                  Positioned(
                    top: Utils.windowHeight(context) * 0.09,
                    right: Utils.windowWidth(context) * 0.08,
                    child: CustomButton(
                      width: Utils.windowWidth(context) * 0.25,
                      height: Utils.windowHeight(context) * 0.046,
                      borderRadius: 20,
                      gradient: LinearGradient(
                        begin: AlignmentGeometry.topRight
                        ,
                        end: AlignmentGeometry.bottomLeft,
                        colors: 
                      
                     [
                       AppColors.white.withValues(alpha: 0.56),
                       AppColors.white.withValues(alpha: 0.015),
                     ]),
                     onPressed: () {
                      //  log("Pressed");
                      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => LoginScreen()));
                     },
                     labelColor: AppColors.primaryColor,
                      label: "Skip"))
            ]);
          
        }).toList() ,
      )
    );
  }
}
