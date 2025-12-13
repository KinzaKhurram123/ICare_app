import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/create_profile.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_record_card.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class DoctorProfile extends StatelessWidget {
  const DoctorProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(text: "Create Profile", fontSize: 17, fontFamily: "Gilroy-Bold",),
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => CreateProfile(isEdit: true,)));
            },
            child: SvgWrapper(assetPath: ImagePaths.edit),
          ),
          SizedBox(width: ScallingConfig.scale(20),)
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              profilePicker(),
              SizedBox(height: ScallingConfig.scale(15),),
              CustomText(
                text: "Aaron Smith", 
                color: AppColors.primary500, 
                fontFamily: "Gilroy-Bold",
                fontWeight: FontWeight.w400,
                fontSize: 16.78,
                ),
              SizedBox(height: ScallingConfig.scale(40),),
              CustomText(
                text: "16 Years", 
                color: AppColors.primary500, 
                fontFamily: "Gilroy-Bold",
                fontWeight: FontWeight.w400,
                fontSize: 34.78,
                ),
              CustomText(
                text: "Experience", 
                color: AppColors.primary500, 
                fontFamily: "Gilroy-Regular",
                // fontWeight: FontWeight.w400,
                fontSize: 16.78,
                ),
                SizedBox(height: ScallingConfig.scale(10),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                CustomRecordCard(
                  color: AppColors.primaryColor,
                  icon: SvgWrapper(assetPath: ImagePaths.profile2User),
                  number: "150",
                  label: "Total Consultations",
                ),
                SizedBox(width: ScallingConfig.scale(15),),
                CustomRecordCard(
                  icon: SvgWrapper(assetPath: ImagePaths.star),
                  number: "4.9" ,
                  label: "Ratings",
                ),
              ],
                ),
                
                SizedBox(height: ScallingConfig.scale(10),),
                SizedBox(
                  width: Utils.windowWidth(context) * 0.9,
                  child: ListTile(
                  
                    leading: SvgWrapper(assetPath: ImagePaths.sms),
                    title: CustomText(
                      text: "lisamarie@gmail.com", 
                      color: AppColors.grayColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily:"Gilroy-SemiBold",
                      ),
                    ),
                ),
                  SizedBox(
                    width: Utils.windowWidth(context) * 0.85,
                    child: Divider(),
                  ),
                SizedBox(height: ScallingConfig.scale(1),),
                SizedBox(
                  width: Utils.windowWidth(context) * 0.9,
                  child: ListTile(
                  
                    leading: SvgWrapper(assetPath: ImagePaths.calll, color: AppColors.primaryColor,),
                    title: CustomText(
                      text: "+1 234 567 8963", 
                      color: AppColors.grayColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily:"Gilroy-SemiBold",
                      ),
                    ),
                ),
                  SizedBox(
                    width: Utils.windowWidth(context) * 0.85,
                    child: Divider(),
                  ),

                  SizedBox(height: ScallingConfig.scale(5),),
                  CustomText(
                    text:"Bio:", 
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary500,
                    fontFamily: "Gilroy-Bold", width: Utils.windowWidth(context) * 0.85,),
                  SizedBox(height: ScallingConfig.scale(5),),
                  CustomText(
                    text:"Lorem ipsum dolor sit amet consectetur adipiscing elit  nascetur at leo accumsan, odio habitanLorem ipsum dolor.", 
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grayColor,
                    maxLines: 3,
                    fontFamily: "Gilroy-Medium", width: Utils.windowWidth(context) * 0.85,),
            ],
          ),
        ),
      ),
    );
  }
}

class profilePicker extends StatelessWidget {
  const profilePicker({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> _showImageSourcePicker(BuildContext context) async {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext bc) {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                // _pickImage(ImageSource.gallery);
                Navigator.of(context).pop(); // Close the bottom sheet
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                // _pickImage(ImageSource.camera);
                Navigator.of(context).pop(); // Close the bottom sheet
              },
            ),
          ],
        ),
      );
    },
  );
}
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: Utils.windowWidth(context) * 0.3,
          height: Utils.windowHeight(context) * 0.15,
          padding: EdgeInsets.all(7),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: AppColors.themeDarkGrey),

            borderRadius: BorderRadius.all(Radius.circular(35)),

          ),
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(30),
            child: SizedBox(
              width: Utils.windowWidth(context) * 0.26,
              height: Utils.windowHeight(context) * 0.1 ,
              child: Image.asset(ImagePaths.user7, 
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              )),
          ),
        ),

        Positioned(

          right: ScallingConfig.scale(-5),
          bottom: ScallingConfig.scale(-5),
          child: CustomButton(
            onPressed: () {
              _showImageSourcePicker(context);
            },
            padding: EdgeInsets.all(0),
            width: ScallingConfig.scale(30),
            borderRadius: 10,
            height: ScallingConfig.scale(25),
            bgColor: AppColors.lightGrey500,
             leadingIcon: SvgWrapper(
              width: ScallingConfig.scale(20),
              assetPath: ImagePaths.camera),),
        ),
      ],
    );
  }
}
