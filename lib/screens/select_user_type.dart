import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/login.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/user_type_card.dart';
import 'package:path/path.dart';

class SelectUserType extends ConsumerStatefulWidget {
  const SelectUserType({super.key});

  @override
  ConsumerState<SelectUserType> createState() => _SelectUserTypeState();
}

class _SelectUserTypeState extends ConsumerState<SelectUserType> {
  final List<Map<String, dynamic>> userTypes = [
  {
    "id": 1,
    "title": "I am a Patient",
    "description": "The easy way to reach your Doctor face-to-face.",
    "role": "patient",
    "image":ImagePaths.userType1,
  },
  {
    "id": 2,
    "title": "I am a Doctor",
    "description": "The easy way to reach your Patients face-to-face.",
    "role": "doctor",
    "image": ImagePaths.userType2,
  },
  {
    "id": 4,
    "title": "I am a Lab Technician",
    "description": "The easy way to reach your Tests/Reports face-to-face.",
    "role": "lab_technician",
    "image":  ImagePaths.userType4,
  },
  {
    "id": 3,
    "title": "I am a Pharmacist",
    "description": "The easy way to reach your Medicine face-to-face.",
    "role": "pharmacist",
    "image": ImagePaths.userType3,
  },
    {
    "id": 5,
    "title": "I am an Instructor",
    "description": "The easy way to manage and guide your students.",
    "role": "instructor",
    "image": ImagePaths.userType5,
  },
  {
    "id": 6,
    "title": "I am a Student",
    "description": "The easy way to learn and connect with instructors.",
    "role": "student",
    "image": ImagePaths.userType6,
  },
];

var selected_id = null;

void onSelect(int id) {

  setState(() {
    selected_id= id;
  });
}

@override
  void dispose() {
    setState(() {
      selected_id = null;
    });
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {


    return Container(
        width: Utils.windowWidth(context),
        height: Utils.windowHeight(context),
        // margin: EdgeInsets.only(top: ),
        // padding: EdgeInsets.only(top:ScallingConfig.verticalScale(40), left:ScallingConfig.scale(10) , right: ScallingConfig.scale(10)),
        
        decoration: BoxDecoration(
        
        image: DecorationImage(image: AssetImage("assets/images/bgImage.jpeg", ),
         fit: BoxFit.cover
        )
        ),
        child: Padding(
          padding:  EdgeInsets.only(top:ScallingConfig.verticalScale(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(height: ScallingConfig.scale(50),),
              CustomText(text: "Select Type Of Your Account",
              fontSize:25.27,
              maxLines: 2,
              padding: EdgeInsets.only(left: ScallingConfig.moderateScale(12)),
              color: AppColors.themeBlue,
              width: Utils.windowWidth(context) * 0.5 ,
              fontWeight: FontWeight.w700,
              isBold: true,
              ),
              CustomText(text: "Choose the type of your account, Note: Account type cannot be changed later",
              padding: EdgeInsets.only(top: ScallingConfig.verticalScale(10), left: ScallingConfig.moderateScale(12)),

              width: Utils.windowWidth(context) * 0.8 ,
              textAlign: TextAlign.start,
              fontSize: 12.60,
              maxLines: 2,
              isSemiBold: true,
                    ),
              SizedBox(height: ScallingConfig.scale(20),),
              Expanded(child: Stack(
                children: [
                  Container(
                    clipBehavior: Clip.hardEdge,
                   width: Utils.windowWidth(context),
                   padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(10)), 
                    decoration: BoxDecoration(

                        color: AppColors.bgColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        
                      ),
                      child: Center(
                        child: ListView.builder(
                          padding: EdgeInsets.only(bottom: ScallingConfig.verticalScale(60)),                          
                          itemCount: userTypes.length,
                          itemBuilder: (ctx,i) {
                          return UserTypeCard(
                            image:userTypes[i]["image"],
                            title: userTypes[i]["title"],
                            description: userTypes[i]["description"],
                            onPressed: () {
  ref.read(authProvider.notifier).setUserRole(userTypes[i]["role"]);                              
                              onSelect(userTypes[i]["id"]);
                            },
                            isSelected: selected_id == userTypes[i]["id"]  ,
                          ); 
                        }
                        ),
                      ),
                  ),
                  if(selected_id != null)
                  Positioned(
                    bottom: ScallingConfig.verticalScale(20),
                    left: ScallingConfig.scale(20),
                    child: CustomButton(label: "Continue", 
                    borderRadius: ScallingConfig.moderateScale(30),
                    onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => LoginScreen()));
                  },))
                ],
              ))         
            ],
          ),
        ) 
    );
  }
}