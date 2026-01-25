import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/choose_location_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_drop_down.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';
import 'package:icare/widgets/toggle_switch_button_with_placeHolder.dart';

class LabFilters extends StatefulWidget {
  const LabFilters({super.key});

  @override
  State<LabFilters> createState() => _LabFiltersState();
}

class _LabFiltersState extends State<LabFilters> {
  String? _selectedSortByOption;

  final List<String> sortByOptions = [
    "distance",
    "newest",
    "oldest",
    "price_low_to_high",
    "price_high_to_low",
    "rating",
  ];

  List<String> reviewOptions = [
    'All Reviews',
    '5 Stars',
    '4 Stars',
    '3 Stars',
    '2 Stars',
    '1 Star',
    'With Comments',
    'With Photos',
    'Most Recent',
    'Oldest',
  ];
  var _review;
  var _isHomeSample = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: "Filter",
          fontSize: 16.78,
          fontFamily: "Gilroy-Bold",
          fontWeight: FontWeight.bold,
          letterSpacing: -0.31,
          lineHeight: 1.0,
          color: AppColors.primary500,
        ),
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChooseLocationButton(),

                  CustomDropdown<String>(
                    title: "Reviews",
                    selectedItem: _review,
                    margin: EdgeInsets.symmetric(
                      vertical: ScallingConfig.verticalScale(6),
                    ),
                    items: reviewOptions,
                    onChanged: (value) {
                      setState(() {
                        _review = value!;
                      });
                    },
                  ),

                  CustomDropdown<String>(
                    title: "Sort By",
                    selectedItem: _selectedSortByOption,
                    margin: EdgeInsets.symmetric(
                      vertical: ScallingConfig.verticalScale(6),
                    ),
                    items: sortByOptions,
                    onChanged: (value) {
                      setState(() {
                        _selectedSortByOption = value!;
                      });
                    },
                  ),

                  ToggleSwitchButtonWithPlaceholder(
                    title: "Home Sample",
                    value: _isHomeSample,
                    onToggle: (value) {
                      setState(() {
                        _isHomeSample = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(bottom: ScallingConfig.verticalScale(40)),
            child: CustomButton(
              label: "Search",
              borderRadius: 30,
              width: Utils.windowWidth(context) * 0.9,
            ),
          ),
        ],
      ),
    );
  }
}
