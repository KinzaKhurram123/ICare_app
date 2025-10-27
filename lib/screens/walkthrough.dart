import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:intro_slider/intro_slider.dart';

class Walkthrough extends StatefulWidget {
  const Walkthrough({super.key});

  @override
  State<Walkthrough> createState() => _WalkthroughState();
}

class _WalkthroughState extends State<Walkthrough> {
  final List<ContentConfig> listContentConfig = [
    ContentConfig(
      title: "More Comfortable Chat With the Doctor",
      description:
          "Book an appointment with doctor. Chat with doctor via appointment letter and get consultation.",
      pathImage: "assets/images/walkthrough1.png",
    ),
    ContentConfig(
      title: "More Comfortable Chat With the Doctor",
      description:
          "Book an appointment with doctor. Chat with doctor via appointment letter and get consultation.",
      pathImage: "assets/images/walkthrough2.png",
    ),
    ContentConfig(
      title: "More Comfortable Chat With the Doctor",
      description:
          "Book an appointment with doctor. Chat with doctor via appointment letter and get consultation.",
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
        listCustomTabs: listContentConfig.asMap().entries.map((entry) {
          final int index = entry.key;
          final ContentConfig item = entry.value;
          return (Container(
            width: Utils.windowWidth(context),
            height: Utils.windowHeight(context),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bgImage.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsetsGeometry.only(
                        right: ScallingConfig.moderateScale(12),
                        bottom: ScallingConfig.moderateScale(22),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        onPressed: () {},
                        child: Text("Skip"),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: Utils.windowWidth(context) * 0.7,
                  height: Utils.windowHeight(context) * 0.5,
                  child: Image.asset(item.pathImage!, fit: BoxFit.contain),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScallingConfig.moderateScale(20),
                    vertical: ScallingConfig.moderateScale(30),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(
                        ScallingConfig.moderateScale(22.6),
                      ),
                      topLeft: Radius.circular(
                        ScallingConfig.moderateScale(22.6),
                      ),
                    ),
                  ),

                  child: Column(
                    spacing: 20,
                    children: [
                      Text(
                        item.title!,

                        style: TextStyle(
                          fontSize: ScallingConfig.moderateScale(23.7),
                          color: AppColors.primary500,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        item.description!,
                        style: TextStyle(
                          color: AppColors.grayColor,
                          fontSize: ScallingConfig.moderateScale(12.5),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          listContentConfig.length,
                          (dotIndex) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 2),
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

                      SizedBox(
                        width: Utils.windowWidth(context) * 0.8,
                        height: Utils.windowHeight(context) * 0.06,
                        child: ElevatedButton(
                          onPressed: () {
                            if (currentIndex < listContentConfig.length - 1) {
                              print(currentIndex);

                              goToTab(currentIndex + 1);
                            } else {
                              print("index=======> " + currentIndex.toString());
                            }
                          },
                          child: Text(
                            "Next",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: ScallingConfig.moderateScale(18),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ));
        }).toList(),
      ),
    );
  }
}
