import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/filters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/custom_text_input.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class LabsListScreen extends StatefulWidget {
  const LabsListScreen({super.key});

  @override
  State<LabsListScreen> createState() => _LabsListScreenState();
}

class _LabsListScreenState extends State<LabsListScreen> 
with SingleTickerProviderStateMixin {

  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
  }
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
      body: Center(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
          children: [
                       CustomInputField(
              width: Utils.windowWidth(context) * 0.9,
              
             hintText: "Search", 
             trailingIcon: SvgWrapper(assetPath: ImagePaths.filters,onPress: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> FiltersScreen()));
             },),
             leadingIcon: SvgWrapper(assetPath: ImagePaths.search),
             ),
SizedBox(height: ScallingConfig.scale(20),),
          SizedBox(
            width: Utils.windowWidth(context),

            // height: Utils.windowHeight(context) * 0.06,
            child: TabBar(
            controller: controller,
            indicatorWeight: 6,
            indicatorColor: AppColors.themeBlack,
            tabs: [
              CustomText(
                text: "History",
                
                padding: EdgeInsets.only(bottom:5),
                width: Utils.windowWidth(context) * 0.33,
                textAlign: TextAlign.center,
              ),
              CustomText(
                text: "Pending Tests",
                padding: EdgeInsets.only(bottom:5),
                width: Utils.windowWidth(context) * 0.33,
                textAlign: TextAlign.center,
              ),
            ],
                    ),
          ),   
          Expanded(child: TabBarView(
        controller: controller,
        children: [
            LabsList(),
            LabsList(),
        ],
      ),),

            
          ],
        ),
      ) ,
    );
  }
}

class LabsList extends StatelessWidget {
  const LabsList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(14)),
        itemCount: 3,
        itemBuilder: (ctx,i) {
        return (
          LabWidget(lab: i+1,)
        );
      });
  }
}

class LabWidget extends StatelessWidget {
  const LabWidget({super.key, this.lab=1});
  final dynamic lab;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: ScallingConfig.verticalScale(15)),
      margin: EdgeInsets.only(top: ScallingConfig.verticalScale(10) ),
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(
          color: AppColors.lightGrey100,
          offset: Offset(0, 4),
          blurRadius: 8
        )],
        borderRadius: BorderRadius.circular(10),
        color: AppColors.white),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                
                borderRadius: BorderRadiusGeometry.circular(18),
                clipBehavior: Clip.hardEdge,
                // clipper: CustomClipper<>(reclip: ),
                child: Image.asset(
                  lab == 1 ? 
                  ImagePaths.lab1
                  :
                  ImagePaths.lab2,
                  fit: BoxFit.cover,
                width: ScallingConfig.scale(80),
                            height: ScallingConfig.scale(80),
                ),
              ),
              SizedBox(width: ScallingConfig.scale(10),),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  CustomText(
                    text: "Green Lab",
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Gilroy-Bold",
                    color: AppColors.themeDarkGrey,
                  ),
                  SizedBox(width: ScallingConfig.scale(90),),
    Icon(Icons.star, color: Colors.amber,),
    CustomText(text:"4.9", fontFamily: "Gilroy-Bold", fontSize: 12, fontWeight: FontWeight.w400,)
 
                  ],),
                  SizedBox(height: ScallingConfig.verticalScale(5) ,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgWrapper(assetPath: ImagePaths.location),
                      SizedBox(width: ScallingConfig.scale(6),),
                      CustomText(
                        text: "20 Cooper Square, USA",
                        color: AppColors.darkGreyColor,
                        fontSize: 12,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgWrapper(assetPath: ImagePaths.delievry),
                      SizedBox(width: ScallingConfig.scale(6),),
                      CustomText(
                        text: "Home Delievery: 25min",
                        color: AppColors.darkGreyColor,
                        fontSize: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: ScallingConfig.scale(10)),
          CustomButton(
            label: "Book a Lab Test",
            width: Utils.windowWidth(context) * 0.8,
            height: ScallingConfig.scale(50),
            borderRadius: 35,
          ),
        ],
      ),
    );
  }
}


