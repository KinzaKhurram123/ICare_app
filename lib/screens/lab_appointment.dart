import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/models/lab.dart';
import 'package:icare/screens/select_payment_method.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/lab_widget.dart';

class LabAppointments extends StatelessWidget {
  const LabAppointments({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Lab> lab_appointments = [
      Lab(
        id: "1",
        title: "Green Lab",
        // rating: "4.9",
        delivery: "Home Sample",
        appointmentFee: "20",
        address: "20 Cooper Square, USA",
        photo: ImagePaths.lab1,
        tests: ["Blood Sugar test"],
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(text: "Lab Appointment"),
      ),

      body: ListView.builder(
        itemCount: lab_appointments.length,
        padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(15)),

        itemBuilder: (ctx, i) {
          return (LabWidget(
            lab: lab_appointments[i],
            actionText: "Pay Now",
            onActionBtnPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => SelectPaymentMethod()),
              );
            },
          ));
        },
      ),
    );
  }
}
