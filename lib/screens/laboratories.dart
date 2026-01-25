import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/laboratory.dart';

class LaboratoriesScreen extends StatelessWidget {
  const LaboratoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: "Laboratories",
          fontFamily: "Gilroy-Bold",
          fontSize: 16.78,
          fontWeight: FontWeight.bold,
          color: AppColors.primary500,
        ),
        automaticallyImplyLeading: false,
        leading: CustomBackButton(),
        
      ),
      body: ListView.builder(
        itemCount: 3,
        padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(20)),

        itemBuilder: (ctx,i) {
        return (
          Laboratory(
            margin: EdgeInsets.only(top: ScallingConfig.scale(10)),
          )
        );
      }),
    );
  }
}