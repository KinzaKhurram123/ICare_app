import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/create_profile.dart';
import 'package:icare/screens/rating_n_reviews.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_record_card.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class ViewProfile extends ConsumerWidget {
  const ViewProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.read(authProvider).userRole;
    log('profile  role ===> $role');

    final label = role == "patient"
        ? "Total Appointments"
        : role == "lab_technician"
        ? "Active Orders"
        : role == "pharmacist"
        ? "Total Appointments"
        : "Total Consultations";
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: "Create Profile",
          fontWeight: FontWeight.bold,
          fontSize: 16.78,
          color: AppColors.primary500,
          letterSpacing: -0.31,
          lineHeight: 1.0,
          fontFamily: "Gilroy-Bold",
        ),
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => CreateProfile(isEdit: true),
                ),
              );
            },
            child:
                // fromViewProfile ? Icon(Icons.favorite, color: AppColors.darkGray400,) :
                SvgWrapper(assetPath: ImagePaths.edit),
          ),
          SizedBox(width: ScallingConfig.scale(20)),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: ScallingConfig.scale(50)),
        child: Center(
          child: Column(
            children: [
              profilePicker(),
              SizedBox(height: ScallingConfig.scale(15)),
              CustomText(
                text: "Aaron Smith",
                color: AppColors.primary500,
                fontFamily: "Gilroy-Bold",
                fontWeight: FontWeight.w400,
                fontSize: 16.78,
              ),
              SizedBox(height: ScallingConfig.scale(40)),
              if (role != "instructor" && role != "student") ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomRecordCard(
                      color: AppColors.primaryColor,
                      icon: SvgWrapper(
                        assetPath: role == "lab_technician"
                            ? ImagePaths.lab_tech
                            : ImagePaths.profile2User,
                      ),
                      number: "150",
                      label: label,
                    ),
                    SizedBox(width: ScallingConfig.scale(15)),
                    CustomRecordCard(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => RatingAndReviews(),
                          ),
                        );
                      },
                      icon: SvgWrapper(
                        assetPath: role == "lab_technician"
                            ? ImagePaths.lab_tech
                            : ImagePaths.star,
                      ),
                      number: role == "lab_technician" ? "32" : "4.9",
                      label: role == "lab_technician"
                          ? "Completed Reports"
                          : "Ratings",
                    ),
                  ],
                ),
              ],

              SizedBox(height: ScallingConfig.scale(10)),
              SizedBox(
                width: Utils.windowWidth(context) * 0.9,
                child: ListTile(
                  leading: SvgWrapper(assetPath: ImagePaths.sms),
                  title: CustomText(
                    text: "lisamarie@gmail.com",
                    color: AppColors.grayColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Gilroy-SemiBold",
                  ),
                ),
              ),
              SizedBox(
                width: Utils.windowWidth(context) * 0.85,
                child: Divider(),
              ),
              SizedBox(height: ScallingConfig.scale(1)),
              SizedBox(
                width: Utils.windowWidth(context) * 0.9,
                child: ListTile(
                  leading: SvgWrapper(
                    assetPath: ImagePaths.calll,
                    color: AppColors.primaryColor,
                  ),
                  title: CustomText(
                    text: "+1 234 567 8963",
                    color: AppColors.grayColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Gilroy-SemiBold",
                  ),
                ),
              ),
              SizedBox(
                width: Utils.windowWidth(context) * 0.85,
                child: Divider(),
              ),

              SizedBox(height: ScallingConfig.scale(5)),
              CustomText(
                text: "Bio:",
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary500,
                fontFamily: "Gilroy-Bold",
                width: Utils.windowWidth(context) * 0.85,
              ),
              SizedBox(height: ScallingConfig.scale(5)),
              CustomText(
                text:
                    "Lorem ipsum dolor sit amet consectetur adipiscing elit  nascetur at leo accumsan, odio habitanLorem ipsum dolor.",
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.grayColor,
                maxLines: 3,
                fontFamily: "Gilroy-Medium",
                width: Utils.windowWidth(context) * 0.85,
              ),
              SizedBox(height: ScallingConfig.scale(10)),
              infoRowTile(
                iconPath: ImagePaths.calendar,
                infoText: "December 25, 1990",
              ),
              // SizedBox(height: ScallingConfig.scale(10),),
              infoRowTile(iconPath: ImagePaths.gender, infoText: "Male"),

              infoRowTile(
                iconPath: ImagePaths.marker2,
                infoText: "199 Water Street 24TH, New York ",
              ),
              infoRowTile(iconPath: ImagePaths.card, infoText: "5678 1234-A"),
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
            border: Border.all(width: 2, color: AppColors.themeDarkGrey),

            borderRadius: BorderRadius.all(Radius.circular(35)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(30),
            child: SizedBox(
              width: Utils.windowWidth(context) * 0.26,
              height: Utils.windowHeight(context) * 0.1,
              child: Image.asset(
                ImagePaths.user7,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),

        // Positioned(
        //   right: ScallingConfig.scale(-5),
        //   bottom: ScallingConfig.scale(-5),
        //   child: CustomButton(
        //     onPressed: () {
        //       _showImageSourcePicker(context);
        //     },
        //     padding: EdgeInsets.all(0),
        //     width: ScallingConfig.scale(30),
        //     borderRadius: 10,
        //     height: ScallingConfig.scale(25),
        //     bgColor: AppColors.lightGrey500,
        //     leadingIcon: SvgWrapper(
        //       width: ScallingConfig.scale(20),
        //       assetPath: ImagePaths.camera,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

class infoRowTile extends StatelessWidget {
  final String iconPath;
  final String infoText;
  const infoRowTile({
    super.key,
    required this.iconPath,
    required this.infoText,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: Utils.windowWidth(context) * 0.9,
          child: ListTile(
            leading: SvgWrapper(
              assetPath: iconPath,
              color: AppColors.primaryColor,
            ),
            title: CustomText(
              text: infoText,
              color: AppColors.grayColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: "Gilroy-SemiBold",
            ),
          ),
        ),
        SizedBox(width: Utils.windowWidth(context) * 0.85, child: Divider()),
      ],
    );
  }
}
