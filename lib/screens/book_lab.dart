import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';
import 'package:intl/intl.dart';

class BookLabScreen extends StatefulWidget {
  const BookLabScreen({super.key});

  @override
  State<BookLabScreen> createState() => _BookLabScreenState();
}

class _BookLabScreenState extends State<BookLabScreen> {
  var _selectedDate= '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(
        text:"Book A Lab", 
        fontFamily: "Gilroy-Bold", 
        fontSize: 18,
        color: AppColors.darkGray500,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
                        Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  boxShadow: BoxShadow(offset: Offset(0, 0)),
                  borderRadius: 35,
                  labelWidth: Utils.windowWidth(context) * 0.35,

                  // outlined: true,
                  borderColor: AppColors.veryLightGrey,
                  height: Utils.windowHeight(context) * 0.045,
                  width: Utils.windowWidth(context) * 0.4,
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
                SizedBox(width: ScallingConfig.scale(10) ,),
          ],
        )
          ]
      )
      
      ) 
    );
  }
}