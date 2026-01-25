import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/models/lab_test.dart';
import 'package:icare/screens/lab_appointment.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class SelectTest extends StatefulWidget {
  const SelectTest({super.key});

  @override
  State<SelectTest> createState() => _SelectTestState();
}

class _SelectTestState extends State<SelectTest> {
  var _selectedTests = [];

  void _onSelect(item) {
    setState(() {
      // _selectedTests.add(item.name);
      if (_selectedTests.contains(item?.name)) {
        log("if block");
        _selectedTests.remove(item?.name);
      } else {
        log("else block ${item.name}");
        _selectedTests.add(item?.name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<LabTest> labTests = [
      LabTest(id: '1', name: 'Blood Sugar Test', price: 20),
      LabTest(id: '2', name: 'CBC', price: 20),
      LabTest(id: '3', name: 'Thyroid Panel', price: 20),
      LabTest(id: '4', name: 'Kidney Function Test', price: 20),
      LabTest(id: '5', name: 'Urine Test', price: 20),
    ];

    log(jsonEncode(_selectedTests.map((e) => e).toList()));

    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(
          text: "Book A Lab",
          fontSize: 16.78,
          fontFamily: "Gilroy-Bold",
          fontWeight: FontWeight.bold,
          letterSpacing: -0.31,
          lineHeight: 1.0,
          color: AppColors.primary500,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: ScallingConfig.scale(10)),
              CustomText(
                width: Utils.windowWidth(context) * 0.9,
                text: "Select Test",
                fontFamily: "Gilroy-SemiBold",
                fontWeight: FontWeight.w400,
                fontSize: 14.78,
                color: AppColors.primary500,
              ),

              ...labTests.map(
                (labtest) => SelectableItem(
                  selected: _selectedTests.contains(labtest.name),
                  item: labtest,
                  onSelect: () => _onSelect(labtest),
                ),
              ),

              SizedBox(height: ScallingConfig.scale(20)),
              CustomButton(
                labelSize: 16.89,
                label: "Submit Request",
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => LabAppointments()),
                  );
                  // AppModals.showWarningModal(context,
                  // "Successful",
                  // "Your test request has been successfully sent.",
                  // onPrimaryButtonPressed: () {
                  //         // Navigator.pop(context);
                  // },
                  // null );
                  // AppModals.showSuccessModal(context, "Successful", "Your test request has been successfully sent."

                  // );
                  // Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ConfirmDetails()));
                },

                borderRadius: 30,
                width: Utils.windowWidth(context) * 0.9,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectableItem extends StatelessWidget {
  const SelectableItem({
    super.key,
    this.onSelect,
    this.selected = false,
    this.item,
    this.selectedItems,
  });
  final bool selected;
  final LabTest? item;
  final List? selectedItems;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: EdgeInsets.only(top: ScallingConfig.verticalScale(12)),
        padding: EdgeInsets.symmetric(
          vertical: ScallingConfig.verticalScale(10),
          horizontal: ScallingConfig.scale(15),
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.lightGrey10),
          borderRadius: BorderRadius.circular(25),
        ),
        width: Utils.windowWidth(context) * 0.9,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            selected
                ? SvgWrapper(
                    assetPath: ImagePaths.success,
                    width: ScallingConfig.scale(20),
                    height: ScallingConfig.scale(20),
                  )
                : Icon(
                    Icons.radio_button_unchecked,
                    color: AppColors.darkGreyColor.withAlpha(70),
                  ),
            SizedBox(width: ScallingConfig.scale(10)),
            Expanded(
              child: CustomText(
                text: item?.name ?? "",
                fontFamily: "Gilroy-Medium",
                fontSize: 14.79,
                color: AppColors.grayColor,
                fontWeight: FontWeight.w400,
              ),
            ),
            CustomText(
              text: "\$${item?.price}",
              fontFamily: "Gilroy-SemiBold",
              fontSize: 14.79,
              color: AppColors.primary500,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      ),
    );
  }
}
