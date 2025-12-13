import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
class AppModals {
  void showSuccessModal(
    BuildContext ctx, 
    String? title, 
    String? description, 

  {bool isShowActions=true} 
  ) {

  showDialog(
    context: ctx,
    // barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 70,
                width: 70,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                "Successful", 
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ), 
              const SizedBox(height: 8),
              const Text(
                "You have complete your profile setup successfully.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 25),
              CustomButton(
                label: "Gp back",
                borderRadius: 30,
                labelColor: AppColors.white,
                labelSize: 13,
                width: Utils.windowWidth(context) * 0.8,
              )
            ],
          ),
        ),
      );
    },
  );
}
 static void showWarningModal (BuildContext ctx , 
     String? title, 
    String? description, 
    List<String>? options,
  
    {String primaryText= "Yes", String secondaryText = 'No', 
    int numOfActions=1,
    dynamic onPrimaryButtonPressed,
    dynamic onSecondaryButtonPressed,
    Widget? centerAction=null,
    bool isShowActions=true}
 )
 {

  SmartDialog.show(
    
    builder: (context) {
  return Container(
    height:  Utils.windowHeight(context) * 0.5,
    width: Utils.windowWidth(context) * 0.9,
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    alignment: Alignment.center,
    child: Padding(
                padding: EdgeInsets.only(left:ScallingConfig.scale(10), right: ScallingConfig.scale(10), top: ScallingConfig.scale(10)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    
                   SvgWrapper(assetPath:  ImagePaths.warning,
                  //  width: ScallingConfig.scale(40), height: ScallingConfig.scale(40),
                   ),
                    const SizedBox(height: 20),
                    if(centerAction != null) ...[centerAction],
                   if(title !=null) ...[CustomText(
                      text:title, 
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary500,
                      fontSize: 16.78,
                      fontFamily: "Gilroy-Bold",
                      maxLines: 2,
                    ),], 
                    // const SizedBox(height: 8),
                    if(description !=null) ...[CustomText(
                      text: "You have complete your profile setup successfully.",
                      textAlign: TextAlign.center,
                      color: AppColors.grayColor,
                      fontSize: 13,
                    )],
                   SizedBox(height: ScallingConfig.scale(10)),
                    if(options != null)            
                      ...[Options(options: options,)],
                    // const SizedBox(height: 25),
                  if(numOfActions > 1) ...[Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    CustomButton(
                      label: primaryText,
                      borderRadius: 30,
                      labelColor: AppColors.white,
                      onPressed: () {
                        print("pressed");
                        onPrimaryButtonPressed();
                        // Navigator.of(context).pop();
                      },
                      labelWeight: FontWeight.bold,
                      // outlined: true,
                      labelSize: 13,
                      height: ScallingConfig.scale(45),
                      width: Utils.windowWidth(context) * 0.4,
                      // width: Utils.windowWidth(context) * 0.35,
                    ),
                    SizedBox(width: ScallingConfig.scale(10),),
                    CustomButton(
                      label:secondaryText,
                      borderRadius: 30,
                      
                      labelColor: AppColors.primaryColor,
                      borderColor: AppColors.primaryColor,
                      labelWeight: FontWeight.bold,
                      outlined: true,
                      onPressed: () {
                        onSecondaryButtonPressed();
                      },
                      labelSize: 13,
                      height: ScallingConfig.scale(45),
                      width: Utils.windowWidth(context) * 0.4,
                    ),
                      ],
                    )],

                    if(numOfActions == 1) ...[
                      CustomButton(
                         label: primaryText,
                      borderRadius: 30,
                      labelColor: AppColors.white,
                      onPressed: () {
                        print("pressed");
                        onPrimaryButtonPressed();
                        // Navigator.of(context).pop();
                      },
                      labelWeight: FontWeight.bold,
                      // outlined: true,
                      labelSize: 13,
                      // height: ScallingConfig.scale(45),
                      width: Utils.windowWidth(context) * 0.8,
                      )
                    ]
                    // SizedBox(height: ScallingConfig.scale(10),)
              
                  ],
                ),
              ),

  );
});
 }
 
}

class Options extends StatefulWidget {
   Options({super.key, this.selectedReason = '', this.options});
   String selectedReason;
  final  List<String>? options;
  @override
  State<Options> createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
  @override
  Widget build(BuildContext context) {
    return                           RadioGroup<String>(
              groupValue: widget.selectedReason,
              onChanged: (value) {
                setState(() {
                  widget.selectedReason = value!;
                });
              },

              child: Column(
                children: widget.options!.map((reason) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Radio(
                          activeColor: AppColors.primaryColor,
                          value: reason,
                        ),
                        Expanded(
                          child: CustomText(
                            padding: EdgeInsets.only(top: 1),
                            text: reason,
                            fontFamily: "Gilroy-Medium",
                            // isBold: true,
                            fontSize: ScallingConfig.moderateScale(16),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
  }
}
