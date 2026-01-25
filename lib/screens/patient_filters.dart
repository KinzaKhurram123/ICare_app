import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/choose_location_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_drop_down.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/toggle_switch_button_with_placeHolder.dart';

class PatientFiltersScreen extends StatefulWidget {
  const PatientFiltersScreen({super.key});

  @override
  State<PatientFiltersScreen> createState() => _PatientFiltersScreenState();
}

class _PatientFiltersScreenState extends State<PatientFiltersScreen> {
  var specialityArray = [
  "Cardiologist",
  "Dermatologist",
  "Neurologist",
  "Orthopedic",
  "Pediatrician",
  "Psychiatrist",
  "Dentist"
];
final List<String> reviewsList = [
    '1+ Stars',
    '2+ Stars',
    '3+ Stars',
    '4+ Stars',
    '5 Stars',
  ];

  final List<String> sortByOptions = [
    "distance",
    "newest",
    "oldest",
    "price_low-to-high",
    "price_high-to-low",
    "rating",
  ];
  final List<String> pharmacyTypeList = [
  "24/7",
  "Retail",
  "Hospital",
  "Community",
  "Clinical",
  "Online",
  "Compounding",
  "Specialty",
  "Home Care",
  "Wholesale",
  "Veterinary",
];

String? _selectedSpeciality;
 String? _selectedReviews;
 String? _selectedSortByOption;
 String? _selectedPharmacyType;
 bool _medicineAvailablity = false;
 bool _homeAvailablity = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: CustomText(
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
               ChooseLocationButton(
                label:"Choose Location",
               ),
                CustomDropdown<String>(title: "Doctor's Speciality", 
                selectedItem: _selectedSpeciality,
                 margin: EdgeInsets.symmetric(vertical: ScallingConfig.verticalScale(6) ),
                items: specialityArray, onChanged: (value){
                  setState(() {
                    _selectedSpeciality = value!;
                  });
                }),
                  CustomDropdown<String>(title: "Reviews", 
                selectedItem: _selectedReviews,
                 margin: EdgeInsets.symmetric(vertical: ScallingConfig.verticalScale(6) ),
                items: reviewsList, onChanged: (value){
                  setState(() {
                    _selectedReviews = value!;
                  });
                }),
                CustomDropdown<String>(title: "Sort By", 
                selectedItem: _selectedSortByOption,
                 margin: EdgeInsets.symmetric(vertical: ScallingConfig.verticalScale(6) ),
                items: sortByOptions, onChanged: (value){
                  setState(() {
                    _selectedSortByOption = value!;
                  });
                }),
                CustomDropdown<String>(
                title: "Pharmcy Type (Optional)", 
                selectedItem: _selectedPharmacyType,
                 margin: EdgeInsets.symmetric(
                  vertical: ScallingConfig.verticalScale(6) 
                  ),
                items: pharmacyTypeList,

                onChanged: (value){
                  setState(() {
                    _selectedPharmacyType= value!;
                  });
                }),
 Padding(
  padding: EdgeInsetsGeometry.symmetric(horizontal: ScallingConfig.scale(5)),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    spacing: ScallingConfig.scale(18),
  children: [

 ToggleSwitchButtonWithPlaceholder(
  value: _medicineAvailablity,
  onToggle: (value) {
    setState(() {
      _medicineAvailablity=value;
    });
  },
  title: "Medicine Availability",
  width: Utils.windowWidth(context) * 0.42,
 ),
 ToggleSwitchButtonWithPlaceholder(
  title: "Home Availability",
  value: _homeAvailablity,
  onToggle: (value) {
    setState(() {
      _homeAvailablity=value;
    });
  },
  width: Utils.windowWidth(context) * 0.42,
 ),
//  ToggleSwitchButtonWithPlaceholder(
//   title: "Medicine Availability",
//     width: Utils.windowWidth(context) * 0.24,
//  ),

  ],
 )),              

               
               
               
                
                
                SizedBox(height: ScallingConfig.scale(20),),
                CustomButton(         
                  label: "Search", borderRadius: 30, width: Utils.windowWidth(context) * 0.9,)
            ],
          ),
        ) ,
      ),
    );
  }
}