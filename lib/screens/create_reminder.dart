
import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_drop_down.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/custom_text_input.dart';
import 'package:icare/widgets/dotted_button.dart';
import 'package:icare/widgets/svg_wrapper.dart';
import 'package:intl/intl.dart';

class CreateReminder extends StatefulWidget {
  const CreateReminder({super.key, this.isEdit = false});
  final bool isEdit;

  @override
  State<CreateReminder> createState() => _CreateReminderState();
}

class _CreateReminderState extends State<CreateReminder> {
  var _selectedTime = '';
  var _selectedDate = '';
  String? _selectedDisease;

  var diseaseList = [
  "Diabetes Mellitus",
  "Hypertension",
  "Asthma",
  "Influenza (Flu)",
  "COVID-19",
  "Tuberculosis",
  "Arthritis",
  "Migraine",
  "Depression",
  "Malaria",
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
                leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(text:"Create Reminder",
          fontSize: 16.78, 
          fontFamily: "Gilroy-Bold",
          fontWeight: FontWeight.w400,
          color: AppColors.primary500,
        ),),
      body: SingleChildScrollView(
        child: Column( 
          children: [
            CustomText(
            textAlign: TextAlign.left,
            width: Utils.windowWidth(context) * 0.9,  
            text: "Reminder for Patient",
            color: AppColors.themeDarkGrey,
            fontSize: 16,
            fontFamily: "Gilroy-Medium",
            ),
            CustomInputField(
            hintText: "Patient Email",
            hintStyle: TextStyle(
                color: AppColors.grayColor.withAlpha(60),
                fontFamily: "Gilroy-SemiBold",
                fontSize: 12,
              ),
            borderRadius: 30,
            borderColor: AppColors.grayColor.withAlpha(70),  
            width: Utils.windowWidth(context) * 0.9,
            ),
            CustomInputField(
            hintText: "Title",
            hintStyle: TextStyle(
                color: AppColors.grayColor.withAlpha(60),
                fontFamily: "Gilroy-SemiBold",
                fontSize: 12,
              ),
            borderRadius: 30,
            borderColor: AppColors.grayColor.withAlpha(70),
            width: Utils.windowWidth(context) * 0.9,
            ),
            CustomInputField(
            hintText: "Patient Name",
            // padding: EdgeInsets.only(left: ScallingConfig.scale(25), top: ScallingConfig.scale(10)),
            hintStyle: TextStyle(
                color: AppColors.grayColor.withAlpha(60),
                fontFamily: "Gilroy-SemiBold",
                fontSize: 12,
              ),
              borderRadius: 30,
              borderColor: AppColors.grayColor.withAlpha(70),
            width: Utils.windowWidth(context) * 0.9,
            ),
            
                CustomDropdown<String>( 
                  title: "disease",
                  showTitle: false,
                  textColor: AppColors.grayColor.withAlpha(60),
                selectedItem: _selectedDisease,
                margin: EdgeInsets.symmetric(vertical: ScallingConfig.verticalScale(6) ),
                items: diseaseList, 
                onChanged: (value){
                  setState(() {
                  _selectedDisease = value;
                  });
                }
                ),
CustomInputField(
            hintText: "tablet Name",
            // padding: EdgeInsets.only(left: ScallingConfig.scale(25), top: ScallingConfig.scale(10)),
            hintStyle: TextStyle(
                color: AppColors.grayColor.withAlpha(60),
                fontFamily: "Gilroy-SemiBold",
                fontSize: 12,
              ),
              borderRadius: 30,
              borderColor: AppColors.grayColor.withAlpha(70),
            width: Utils.windowWidth(context) * 0.9,
            ),
            CustomInputField(
              width: Utils.windowWidth(context) * 0.9,
              hintText: "What Patient have to do...",
              hintStyle: TextStyle(
                color: AppColors.grayColor.withAlpha(60),
                fontFamily: "Gilroy-SemiBold",
                fontSize: 12,
              ),
              padding: EdgeInsets.only(left: ScallingConfig.scale(25), top: ScallingConfig.scale(10)),
              height: Utils.windowHeight(context) * 0.15,
              maxLines: 50,
              borderRadius: 25,
              borderColor: AppColors.grayColor.withAlpha(70),
            ),

            SizedBox(height: ScallingConfig.scale(12),),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  boxShadow: BoxShadow(offset: Offset(0, 0)),
                  labelWidth: Utils.windowWidth(context) * 0.35,
                  borderRadius: 35,
                  // outlined: true,
                  borderColor: AppColors.veryLightGrey,
                  height: Utils.windowHeight(context) * 0.045,
                  width: Utils.windowWidth(context) * 0.45,
                  bgColor: AppColors.veryLightGrey,
                  label: _selectedTime.isNotEmpty
                      ? _selectedTime
                      : 'Select Time',
                  labelColor: AppColors.primaryColor,
                  labelSize: 11,
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _selectedTime = time.format(context);
                      });
                    }
                  },
                  trailingIcon: SvgWrapper(assetPath: ImagePaths.clock),
                ),
                SizedBox(width: ScallingConfig.scale(10) ,),  
                CustomButton(
                  boxShadow: BoxShadow(offset: Offset(0, 0)),
                  borderRadius: 35,
                  labelWidth: Utils.windowWidth(context) * 0.35,
                  borderColor: AppColors.veryLightGrey,
                  height: Utils.windowHeight(context) * 0.045,
                  width: Utils.windowWidth(context) * 0.45,
                  bgColor: AppColors.veryLightGrey,

                  label: _selectedDate.isNotEmpty
                      ? _selectedDate
                      : "Select Date",
                  labelColor: AppColors.primaryColor,
                  labelSize: 11,
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = DateFormat("yyyy/MM/dd").format(date);
                      });
                    }
                  },
                  trailingIcon: Align(
                    // alignment: AlignmentGeometry.xy(5, 0),
                    child: SvgWrapper(assetPath: ImagePaths.calendar),
                  ),
                ),
  
              ],
            ),
           SizedBox(height: ScallingConfig.scale(10),),
            DottedButton(
              width: Utils.windowWidth(context) * 0.9,
              title: "Uplaod Prescription", onPressed: () {}),
                       SizedBox(height: ScallingConfig.scale(15),),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  width: Utils.windowWidth(context) * 0.45,
                  borderRadius: 30,
                  labelSize: 15,
                  label: widget.isEdit ? "Edit Reminder" : "Create Reminder",
                  onPressed: () {
                    Navigator.of(context).pop(2);
                  },
                ),
                SizedBox(width: ScallingConfig.scale(10)),
                CustomButton(
                  borderRadius: 30,
                  labelSize: 15,
                  labelColor: AppColors.primaryColor,
                  width: Utils.windowWidth(context) * 0.45,
                  label: "Reminder List",
                  outlined: true,
                  onPressed: () {
                    // Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => DeclineAppointments()));
                  },
                ),
              ],
            ),

          ],
        ),
      ) ,
    );
  }
}