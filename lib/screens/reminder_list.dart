import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/create_reminder.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';
import 'package:intl/intl.dart';

class ReminderList extends StatefulWidget {
  const ReminderList({super.key});

  @override
  State<ReminderList> createState() => _ReminderListState();
}

class _ReminderListState extends State<ReminderList> {
  var _selectedTime = '';
  var _selectedDate = '';

  final List<Map<String, String>> _remindersList = [
    {
      "id": "1",
      "title": "Follow-up for Blood Pressure Check",
      "patient": "Emily Jordan",
      "date": "December, 05, 2025",
      "time": "10:00 AM – 10:30 AM (30 minutes)",
      "description1": "Patient to monitor BP at home. Start Tab.",
      "description2":
          "Amlodipine 5mg once daily. Return for follow-up in 3 days",
    },
    {
      "id": "2",
      "title": "Follow-up for Blood Pressure Check",
      "patient": "Emily Jordan",
      "date": "December, 05, 2025",
      "time": "10:00 AM – 10:30 AM (30 minutes)",
      "description1": "Patient to monitor BP at home. Start Tab.",
      "description2":
          "Amlodipine 5mg once daily. Return for follow-up in 3 days",
    },
    {
      "id": "3",
      "title": "Follow-up for Blood Pressure Check",
      "patient": "Emily Jordan",
      "date": "December, 05, 2025",
      "description1": "Patient to monitor BP at home. Start Tab.",
      "description2":
          "Amlodipine 5mg once daily. Return for follow-up in 3 days",
      "time": "10:00 AM – 10:30 AM (30 minutes)",
    },
    {
      "id": "4",
      "title": "Follow-up for Blood Pressure Check",
      "patient": "Emily Jordan",
      "date": "December, 05, 2025",
      "time": "10:00 AM – 10:30 AM (30 minutes)",
      "description1": "Patient to monitor BP at home. Start Tab.",
      "description2":
          "Amlodipine 5mg once daily. Return for follow-up in 3 days",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(
          text: "Patient Reminders List",
          fontWeight: FontWeight.bold,
          letterSpacing: -0.31,
          lineHeight: 1.0,
          fontSize: 16.78,
          fontFamily: "Gilroy-Bold",
          color: AppColors.primary500,
        ),
      ),
      body: Column(
        children: [
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
                label: _selectedTime.isNotEmpty ? _selectedTime : 'Select Time',
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
              SizedBox(width: ScallingConfig.scale(10)),
              CustomButton(
                boxShadow: BoxShadow(offset: Offset(0, 0)),
                borderRadius: 35,
                labelWidth: Utils.windowWidth(context) * 0.35,
                borderColor: AppColors.veryLightGrey,
                height: Utils.windowHeight(context) * 0.045,
                width: Utils.windowWidth(context) * 0.45,
                bgColor: AppColors.veryLightGrey,

                label: _selectedDate.isNotEmpty ? _selectedDate : "Select Date",
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
          SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(
                bottom: ScallingConfig.verticalScale(60),
                left: ScallingConfig.scale(20),
                right: ScallingConfig.scale(20),
              ),
              itemCount: _remindersList.length,
              itemBuilder: (ctx, i) {
                final item = _remindersList[i];
                return (ReminderWidget(
                  title: item["title"],
                  patientName: item["patient"],
                  date: item["date"],
                  time: item["time"],
                  description2: item["description2"],
                  description: item["description1"],
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ReminderWidget extends StatelessWidget {
  const ReminderWidget({
    super.key,
    this.title,
    this.patientName,
    this.date,
    this.time,
    this.description,
    this.description2,
  });
  final String? title;
  final String? patientName;
  final String? date;
  final String? time;
  final String? description;
  final String? description2;
  // final String? ;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: ScallingConfig.verticalScale(15)),
      width: Utils.windowWidth(context) * 0.9,
      padding: EdgeInsets.symmetric(
        horizontal: ScallingConfig.scale(10),
        vertical: ScallingConfig.verticalScale(12),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomText(
            width: double.infinity,
            fontSize: 14.78,
            color: AppColors.primary500,
            text: title,
          ),
          CustomText(
            width: double.infinity,
            fontSize: 12.78,
            color: AppColors.darkGreyColor,
            text: patientName,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: "Date",
                fontSize: 12,
                color: AppColors.darkGreyColor,
              ),
              CustomText(
                text: date,
                isBold: true,
                color: AppColors.darkGreyColor,
              ),
            ],
          ),
          SizedBox(height: ScallingConfig.scale(5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: "Time",
                fontSize: 12,
                color: AppColors.darkGreyColor,
              ),
              CustomText(
                text: time,
                isBold: true,
                color: AppColors.darkGreyColor,
              ),
            ],
          ),
          SizedBox(height: ScallingConfig.scale(10)),
          CustomText(
            text: description,
            width: double.infinity,
            textAlign: TextAlign.left,
            fontFamily: "Gilroy-Medium",
            fontSize: 12.89,
          ),
          CustomText(
            width: double.infinity,
            text: description2,
            fontFamily: "Gilroy-Medium",
            maxLines: 2,
            fontSize: 12.89,
          ),
          SizedBox(height: ScallingConfig.scale(10)),
          Align(
            alignment: AlignmentGeometry.topLeft,
            child: SizedBox(
              width: Utils.windowWidth(context) * 0.25,
              height: Utils.windowWidth(context) * 0.25,
              child: ClipRect(
                child: Image.asset(ImagePaths.attachment, fit: BoxFit.cover),
              ),
            ),
          ),

          SizedBox(height: ScallingConfig.scale(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                width: Utils.windowWidth(context) * 0.4,
                borderRadius: 30,
                labelSize: 15,
                label: "Edit",
                onPressed: () {
                  // Navigator.of(context).pop(2);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => CreateReminder(isEdit: true),
                    ),
                  );
                },
              ),
              SizedBox(width: ScallingConfig.scale(10)),
              CustomButton(
                borderRadius: 30,
                labelSize: 15,
                labelColor: AppColors.primaryColor,
                width: Utils.windowWidth(context) * 0.4,
                label: "Delete",
                outlined: true,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
