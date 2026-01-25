import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/models/lab.dart';
import 'package:icare/screens/courses.dart';
import 'package:icare/screens/filters.dart';
import 'package:icare/screens/instructor_filters.dart';
import 'package:icare/screens/lab_list.dart';
import 'package:icare/screens/laboratories.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/courses_list.dart';
import 'package:icare/widgets/custom_text_input.dart';
import 'package:icare/widgets/lab_widget.dart';
import 'package:icare/widgets/laboratory.dart';
import 'package:icare/widgets/section_header.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class InstructorHome extends StatelessWidget {
  const InstructorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: ScallingConfig.scale(20),),
             CustomInputField(
                width: Utils.windowWidth(context) * 0.9,
                hintText: "Search",
                trailingIcon: SvgWrapper(
                  assetPath: ImagePaths.filters,
                  onPress: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (ctx) => InstructorFiltersScreen()));
                  },
                ),
                leadingIcon: SvgWrapper(assetPath: ImagePaths.search),
              ),
        SizedBox(height: ScallingConfig.scale(20),),
          SectionHeader(title: "My Courses",
          width: Utils.windowWidth(context) * 0.9,
          onActionTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => Courses()));
          },
          ),
          CoursesList(numOfCourses: 2, constraintHeight: Utils.windowHeight(context) * 0.3,),
          SizedBox(height: ScallingConfig.scale(20),),
          SectionHeader(title:"Laboratories", 
          width: Utils.windowWidth(context) * 0.9,
           onActionTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => LaboratoriesScreen() ));
          },
          ),
          SizedBox(height: ScallingConfig.scale(20),),
          Laboratory(),

        ],
      ),
    );
  }
}