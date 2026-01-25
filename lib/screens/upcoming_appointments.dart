import 'dart:developer';

import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/appointment_card.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:intl/intl.dart';

class UpcomingAppointments extends StatefulWidget {
  const UpcomingAppointments({super.key});

  @override
  State<UpcomingAppointments> createState() => _UpcomingAppointmentsState();
}

class _UpcomingAppointmentsState extends State<UpcomingAppointments> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: "Upcoming Appointments",
          fontSize: 16.78,
          fontFamily: "Gilroy-Bold",
          letterSpacing: -0.31,
          lineHeight: 1.0,
          color: AppColors.primary500,
          fontWeight: FontWeight.bold,
        ),
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          EasyDateTimeLinePicker.itemBuilder(
            focusedDate: _selectedDate,
            firstDate: DateTime(2024, 3, 18),
            lastDate: DateTime(2030, 3, 18),
            itemExtent: ScallingConfig.scale(70),
            itemBuilder:
                (context, date, isSelected, isDisabled, isToday, onTap) {
                  print(_selectedDate);
                  return InkWell(
                    onTap: () {
                      onTap();
                    },
                    child: Container(
                      width: ScallingConfig.scale(60),
                      height: ScallingConfig.scale(40),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.secondaryColor
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: ScallingConfig.scale(10)),
                          CustomText(
                            fontSize: 22,
                            fontFamily: "Gilroy-SemiBold",

                            text: date.day.toString(),
                            color: isSelected
                                ? AppColors.white
                                : AppColors.darkGray400,
                          ),
                          SizedBox(height: ScallingConfig.scale(10)),
                          CustomText(
                            fontSize: 14,
                            fontFamily: "Gilroy-SemiBold",

                            text: DateFormat('EEE').format(date).toString(),
                            color: isSelected
                                ? AppColors.white
                                : AppColors.darkGray400,
                          ),
                        ],
                      ),
                    ),
                  );
                },
            onDateChange: (date) {
              print(date);
              setState(() {
                log('$date ====      ');
                _selectedDate = date;
              });
            },
          ),

          SizedBox(height: ScallingConfig.scale(20)),
          Expanded(
            child: ListView.builder(
              itemCount: 4,
              padding: EdgeInsets.symmetric(
                horizontal: ScallingConfig.scale(20),
              ),
              itemBuilder: (ctx, i) {
                return AppointmentCard();
              },
            ),
          ),
          SizedBox(height: Utils.windowHeight(context) * 0.08),
        ],
      ),
    );
  }
}
