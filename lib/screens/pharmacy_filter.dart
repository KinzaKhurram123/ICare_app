import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/choose_location_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_drop_down.dart';
import 'package:icare/widgets/custom_text.dart';

class PharmacyFilterScreen extends StatefulWidget {
  const PharmacyFilterScreen({super.key});

  @override
  State<PharmacyFilterScreen> createState() => _PharmacyFilterScreenState();
}

class _PharmacyFilterScreenState extends State<PharmacyFilterScreen> {
   final List<String> medicineCategoryList = [
    'Pain Relief',
    'Antibiotics',
    'Vitamins & Supplements',
    'Diabetes Care',
    'Heart & BP',
    'Skin Care',
    'Cold & Flu',
  ];

  final List<String> medicineTypeList = [
    'Tablet',
    'Capsule',
    'Syrup',
    'Injection',
    'Cream / Ointment',
    'Drops',
  ];

  final List<String> brandManufacturerList = [
    'Pfizer',
    'GSK',
    'Novartis',
    'Sanofi',
    'Abbott',
    'Getz Pharma',
  ];

  final List<String> availabilityList = [
    'In Stock',
    'Out of Stock',
    'Available Today',
    'Pre-Order',
  ];

  final List<String> deliveryOptionList = [
    'Home Delivery',
    'Store Pickup',
    'Express Delivery',
  ];

  final List<String> priceRangeList = [
    'Under \$10',
    '\$10 – \$25',
    '\$25 – \$50',
    'Above \$50',
  ];

  final List<String> reviewsList = [
    '1+ Stars',
    '2+ Stars',
    '3+ Stars',
    '4+ Stars',
    '5 Stars',
  ];

  /// 🔹 Selected values (centralized)
  String? _selectedMedicineCategory;
  String? _selectedMedicineType;
  String? _selectedBrandManufacturer;

  String? _selectedDeliveryOption;
  String? _selectedReviews;
  
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
                CustomDropdown<String>(title: "Category", 
                selectedItem: _selectedMedicineCategory,
                 margin: EdgeInsets.symmetric(vertical: ScallingConfig.verticalScale(6) ),
                items: medicineCategoryList, onChanged: (value){
                  setState(() {
                    _selectedMedicineCategory = value!;
                  });
                }),
                CustomDropdown<String>(title: "Medicine Type", 
                selectedItem: _selectedMedicineType,
                 margin: EdgeInsets.symmetric(vertical: ScallingConfig.verticalScale(6) ),
                items: medicineTypeList, onChanged: (value){
                  setState(() {
                    _selectedMedicineType = value!;
                  });
                }),
                CustomDropdown<String>(
                title: "Brand Manifacturer", 
                selectedItem: _selectedBrandManufacturer,
                 margin: EdgeInsets.symmetric(
                  vertical: ScallingConfig.verticalScale(6) 
                  ),
                items: brandManufacturerList,

                onChanged: (value){
                  setState(() {
                    _selectedBrandManufacturer = value!;
                  });
                }),
               
               ChooseLocationButton(
                label:"Near By Store Availability",
               ),

               
                CustomDropdown<String>(title: "Delievery Option", 
                margin: EdgeInsets.symmetric(vertical: ScallingConfig.verticalScale(6) ),
                selectedItem: _selectedDeliveryOption,
 
                items: deliveryOptionList, onChanged: (value){
                  setState(() {
                    _selectedDeliveryOption = value!;
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