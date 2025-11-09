import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:icare/screens/profile_or_appointement_view.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';

enum Status { upcoming, cancelled, completed }

class BookingCategories extends StatefulWidget {
  const BookingCategories({super.key});

  @override
  State<BookingCategories> createState() => _BookingCategoriesState();
}

class _BookingCategoriesState extends State<BookingCategories>
    with SingleTickerProviderStateMixin {
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
        title: CustomText(text: "Upcoming"),
        bottom: TabBar(
          controller: controller,
          indicatorWeight: 6,
          indicatorColor: AppColors.themeBlack,
          tabs: [
            CustomText(
              text: "Upcoming",
              
              padding: EdgeInsets.only(bottom:5),
              width: Utils.windowWidth(context) * 0.33,
              textAlign: TextAlign.center,
            ),
            CustomText(
              text: "Cancelled",
              padding: EdgeInsets.only(bottom:5),
              width: Utils.windowWidth(context) * 0.33,
              textAlign: TextAlign.center,
            ),
            CustomText(
              padding: EdgeInsets.only(bottom:5),
              width: Utils.windowWidth(context) * 0.33,
              textAlign: TextAlign.center,
              text: "Completed",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: [
          UpcomingBOokingsList(
            status: Status.upcoming,
            data:[1,2,3],
          ),
          UpcomingBOokingsList(
            status: Status.cancelled,
            data:[1,2,3],
          ),
          UpcomingBOokingsList(
            status: Status.completed,
            data:[1,2,3],
          ),
          
        ],
      ),
    );
  }
}

class UpcomingBOokingsList extends StatelessWidget {
  const UpcomingBOokingsList({super.key, this.data, this.status});
  final List<dynamic>? data;
  final Status? status;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data!.length,
      padding: EdgeInsets.only(
        right: ScallingConfig.scale(20),
        bottom: ScallingConfig.scale(40),
        left: ScallingConfig.scale(20)),
      itemBuilder: (ctx, i) {
        return (BookingCard(status: status));
      },
    );
  }
}

class BookingCard extends StatelessWidget {
  const BookingCard({super.key, this.status});
  final Status? status;

  @override
  Widget build(BuildContext context) {
    Widget reminder = Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          text: "Reminds Me",
          color: AppColors.primary500,
          fontSize: 10,
          fontFamily: "Gilroy-SemiBold",
        ),
        SizedBox(width: 20),
        FlutterSwitch(
          width: 50.0,
          height: 20.0,

          toggleSize: 15.0,
          value: true,
          borderRadius: 30.0,
          padding: 2.0,
          toggleColor: Color.fromRGBO(225, 225, 225, 1),
          activeColor: AppColors.themeBlack,
          inactiveColor: AppColors.darkGreyColor,
          onToggle: (val) {
            // setState(() {
            // status2 = val;
            // });
          },
        ),
      ],
    );

    Widget action = status == Status.upcoming ?  Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                width: Utils.windowWidth(context) * 0.36,
                height: Utils.windowHeight(context) * 0.055,
                borderRadius: 30,
                labelSize: 15,
                label: "View",
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ProfileOrAppointmentViewScreen()));
                },
              ),
              SizedBox(width: ScallingConfig.scale(10)),
              CustomButton(
                borderRadius: 30,
                labelSize: 15,
                labelColor: AppColors.primaryColor,
                width: Utils.windowWidth(context) * 0.36,
                height: Utils.windowHeight(context) * 0.055,
                label: "Cancel",
                outlined: true,
                onPressed: () {
                  // Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => DeclineAppointments()));
                },
              ),
            ],
          ) : status == Status.cancelled ? 
          CustomButton(
            label: "View Appointment",
            height: Utils.windowHeight(context) * 0.055,
            borderRadius: 30,
            labelSize: 15,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ProfileOrAppointmentViewScreen()));
            },
            ) 
          : CustomButton(
            label: "View Chat",
            height: Utils.windowHeight(context) * 0.055,
            borderRadius: 30,
            labelSize: 15,
            ) ;

    return Container(
      width: Utils.windowWidth(context) * 0.75,
      margin: EdgeInsets.only(top: ScallingConfig.verticalScale(12)),
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: ScallingConfig.verticalScale(12),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        // borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.veryLightGrey.withOpacity(0.5),
            offset: Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: "Dec 05, 2023 - 10:00 AM",
                color: AppColors.primary500,
                fontSize: 12,
                fontFamily: "Gilroy-SemiBold",
              ),
              if (status == Status.upcoming) reminder,
            ],
          ),

          // SwitchListTile(
          //   title: CustomText(text: "Reminds me",),
          //   value: true, onChanged: (value){

          // })
          SizedBox(height: ScallingConfig.scale(10)),
          Row(
            children: [
              Container(
                width: Utils.windowWidth(context) * 0.22,
                height: Utils.windowWidth(context) * 0.22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(ImagePaths.user1, fit: BoxFit.cover),
              ),
              SizedBox(width: ScallingConfig.scale(12)),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomText(
                      width: double.infinity,
                      text: "Emily Jordan",
                      isSemiBold: true,
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: ScallingConfig.scale(5)),
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
                    SizedBox(height: ScallingConfig.scale(6)),
                    Row(
                      children: [
                        SvgWrapper(assetPath: ImagePaths.scan),
                        SizedBox(width: Utils.windowWidth(context) * 0.025),
                        CustomText(
                          text: "Booking ID: #DR452SA54",
                          fontSize: 12,
                          color: AppColors.darkGreyColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ScallingConfig.scale(20)),
          action
        ],
      ),
    );
  }
}
