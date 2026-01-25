import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_drop_down.dart';
import 'package:icare/widgets/custom_text.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
var specialityArray = [
  "Cardiologist",
  "Dermatologist",
  "Neurologist",
  "Orthopedic",
  "Pediatrician",
  "Psychiatrist",
  "Dentist"
];

var availabilityArray = [
  "Today",
  "Tomorrow",
  "This Week",
  "Next Week"
];

var consultationTypeArray = [
  "Video",
  "Audio",
  "In-Person"
];

var locationArray = [
  "Nearby",
  "Within 5 km",
  "Within 10 km",
  "Citywide"
];

var reviewsArray = [
  "1+ Stars",
  "2+ Stars",
  "3+ Stars",
  "4+ Stars",
  "5 Stars"
];

var languageArray = [
  "English",
  "Urdu",
  "Spanish",
  "French",
  "German",
  "Arabic"
];

var _selectedSpeciality;
var _selectedAvailablity;
var _selectedConsultationType;
var _selectedLocation;
var _selectedReviews;
var _selectedLanguage;

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
                CustomDropdown<String>(title: "Speciality", 
                selectedItem: _selectedSpeciality,
                 margin: EdgeInsets.symmetric(vertical: ScallingConfig.verticalScale(6) ),
                items: specialityArray, onChanged: (value){
                  setState(() {
                    _selectedSpeciality = value!;
                  });
                }),
                CustomDropdown<String>(title: "Availablity", 
                selectedItem: _selectedAvailablity,
                 margin: EdgeInsets.symmetric(vertical: ScallingConfig.verticalScale(6) ),
                items: availabilityArray, onChanged: (value){
                  setState(() {
                    _selectedAvailablity = value!;
                  });
                }),
                CustomDropdown<String>(
                title: "Consultation Type", 
                selectedItem: _selectedConsultationType,
                 margin: EdgeInsets.symmetric(
                  vertical: ScallingConfig.verticalScale(6) 
                  ),
                items: consultationTypeArray,

                onChanged: (value){
                  setState(() {
                    _selectedConsultationType = value!;
                  });
                }),
                CustomDropdown<String>(title: "Reviews", 
                selectedItem: _selectedReviews,
                 margin: EdgeInsets.symmetric(vertical: ScallingConfig.verticalScale(6) ),
                items: specialityArray, onChanged: (value){
                  setState(() {
                    _selectedReviews = value!;
                  });
                }),
                CustomDropdown<String>(title: "Location", 
                margin: EdgeInsets.symmetric(vertical: ScallingConfig.verticalScale(6) ),
                selectedItem: _selectedLocation,
                items: locationArray, onChanged: (value){
                  setState(() {
                    _selectedLocation = value!;
                  });
                }),
                CustomDropdown<String>(title: "Language", 
                margin: EdgeInsets.symmetric(vertical: ScallingConfig.verticalScale(6) ),
                selectedItem: _selectedLanguage,
                items: languageArray, 
                onChanged: (value){
                  setState(() {
                    _selectedLanguage = value!;
                  });
                }),
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