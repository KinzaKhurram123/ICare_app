import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/filters.dart';
import 'package:icare/screens/profile_or_appointement_view.dart';
import 'package:icare/screens/upcoming_appointments.dart';
import 'package:icare/screens/video_call.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/appointment_card.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/custom_text_input.dart';
import 'package:icare/widgets/svg_wrapper.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _selectedDate;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Home"),
      // ),
      body: SingleChildScrollView(
        
        child: Column(
          
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
            height: Utils.windowHeight(context) * 0.25,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                 children: [
               
                  SizedBox(
                    width: Utils.windowWidth(context) * 0.8,
                    height: Utils.windowHeight(context) * 0.15,
                    child: Image.asset(ImagePaths.courseAd)),
                  SizedBox(
                    width: Utils.windowWidth(context) * 0.8,
              
                    child: Image.asset(ImagePaths.courseAd)),
                
                 ],
              ),
            ),
           ),
       
        Row(
          children: [
            CustomText(text: "Todays’s Appointments", 
            padding: EdgeInsets.only(left: 20),
            isBold: true,),
            CustomText(text: "(in 20 min)", 
            padding: EdgeInsets.only(left: 8),
            
            color: AppColors.themeRed, isBold: true,),
          ],
        ),
        DoctorConsultationCard(), 
        EasyDateTimeLinePicker.itemBuilder(
  
  focusedDate: _selectedDate,
  firstDate: DateTime(2024, 3, 18),
  lastDate: DateTime(2030, 3, 18),
  itemExtent: ScallingConfig.scale(70),
  itemBuilder: (context, date, isSelected, isDisabled, isToday, onTap) {
    print(_selectedDate);
    return InkWell(
      onTap: (){
        onTap();
      },
      child: Container(
        width: ScallingConfig.scale(60),
        height: ScallingConfig.scale(40),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondaryColor: AppColors.white,
           borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
              fontSize: 22,
              fontFamily: "Gilroy-SemiBold",
              
              text:date.day.toString(), color: isSelected ? AppColors.white : AppColors.darkGray400, ),
            SizedBox(
              height: ScallingConfig.scale(10),
            ),
            CustomText(
              fontSize: 14,
              fontFamily: "Gilroy-SemiBold",

              text:DateFormat('EEE').format(date).toString(), color: isSelected ? AppColors.white : AppColors.darkGray400, ),
          ],
        ),
      ),
    );
  },
  onDateChange: (date) {
      print(date);
          setState(() {
          print('${date}   ====      ');
            _selectedDate= date;
          });
  },
),
   SizedBox(
    width: Utils.windowWidth(context) * 0.9,
    child: AppointmentCard()),
  SizedBox(height: ScallingConfig.scale(20),),
  CustomText(text:"View All Upcoming Appointments", 
  onTap: () {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => UpcomingAppointments()));
  },
  fontFamily: "Gilroy-bold", underline: true,),
  SizedBox(height: ScallingConfig.scale(60),),
        
    ],
  )),
    );
  }
}

class ProfileInfoWidget extends StatelessWidget {
  const ProfileInfoWidget({super.key});


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> ProfileOrAppointmentViewScreen()));
      },
      child: Container(
        width: Utils.windowWidth(context),
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: AppColors.white),
        child: Row(
          children: [
            Container(
              width: Utils.windowWidth(context) * 0.25,
              height: Utils.windowWidth(context) * 0.25,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
              child: Image.asset(ImagePaths.user1, fit: BoxFit.cover),
            ),
            SizedBox(width: ScallingConfig.scale(12)),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(text: "Emily Jordan", isSemiBold: true),
                      // Spacer(),
                      SizedBox(width: ScallingConfig.scale(50)),
                      CustomText(
                        text: "View Profile",
                        underline: true,
                        onTap: () {
               Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ProfileOrAppointmentViewScreen()));

                        },
      
                        isSemiBold: true,
                      ),
                    ],
                  ),
                  SizedBox(height: ScallingConfig.scale(10)),
                  Row(
                    children: [
                      SvgWrapper(assetPath: ImagePaths.location),
                      SizedBox(width: Utils.windowWidth(context) * 0.025),
                      CustomText(
                        text: "20 Cooper Square, USA",
                        fontSize: 12,
                        color: AppColors.darkGreyColor,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SvgWrapper(assetPath: ImagePaths.scan),
                      SizedBox(width: Utils.windowWidth(context) * 0.025),
                      CustomText(text: "Booking ID: #DR452SA54", fontSize: 12),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class DoctorConsultationCard extends StatelessWidget {
  const DoctorConsultationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Utils.windowWidth(context) * 0.85,
      padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(10), vertical: ScallingConfig.verticalScale(12)),
      decoration: BoxDecoration(
      
        color: AppColors.white,
        boxShadow: [BoxShadow(
          color: AppColors.lightGrey100,
          offset: Offset(0, 4),
          blurRadius: 8
        )]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            child: Container(

              padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(8),vertical: ScallingConfig.verticalScale(3)),
              decoration: BoxDecoration(
              color: AppColors.darkGreyColor.withAlpha(40),
             borderRadius: BorderRadius.circular(15)
              ),
              child: CustomText(text: "Video Consultation",
              fontWeight: FontWeight.w400,
              ),
            ),
          ),
SizedBox(height: Utils.windowHeight(context) * 0.017 ,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(10)),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircleAvatar(
                  radius: ScallingConfig.scale(30),
                  foregroundImage: AssetImage(ImagePaths.user5) ,
                ),
                SizedBox(width: ScallingConfig.scale(20) ,),
      //  Spacer(),
                Column(
                  children: [
                    CustomText(text: "Adam", 
                    fontSize: 16.78,
                    fontWeight: FontWeight.w400,
                    isBold: true,
                    ),
                    CustomText(text: "9:00 Am",
                    fontSize: 16.78,
                    fontWeight: FontWeight.w400,
                    isBold: true,
                    ),
                  ],
                ),
                Spacer(),
                // SizedBox(width: ScallingConfig.scale(50),),
                CustomButton(
                  width: Utils.windowWidth(context) * 0.2,
                  height: ScallingConfig.verticalScale(25),
                  borderRadius: 20,
                  label: "Join",
                  labelSize: 14,
                  onPressed: () {
             Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => VideoCall()));

                  },
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}