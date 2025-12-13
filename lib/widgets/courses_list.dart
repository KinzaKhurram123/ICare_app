import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/course_card.dart';

class CoursesList extends StatelessWidget {
  const CoursesList({super.key, this.mypurchased = false});
final bool mypurchased;
  @override
  Widget build(BuildContext context) {
    var courses =   [
  {
    "id": 1,
    "name": "Behavioral Therapist",
   "instructor": "Kewshun",
    "desc": "Lorem Ipsum is simply dummy text...",
    "image": ImagePaths.course1, // or appropriate image path
    "onpress": () => log("Behavioral Therapist - Kewshun selected")
  },
  {
    "id": 2,
    "name": "Child Therapist",
    "instructor": "Kewshun",
    "desc": "Lorem Ipsum is simply dummy text...",
    "image": ImagePaths.course2, // or appropriate image path
    "onpress": () => log("Child Therapist - Kewshun selected")
  },
  {
    "id": 3,
    "name": "Child Therapist",
    "instructor": "James",
    "desc": "Lorem Ipsum is simply dummy text...",
    "image": ImagePaths.course1, // or appropriate image path
    "onpress": () => log("Child Therapist - James selected")
  },
  {
    "id": 4,
    "name": "Behavioral Therapist",
    "instructor": "James",
    "desc": "Lorem Ipsum is simply dummy text...",
    "image": ImagePaths.course1, // or appropriate image path
    "onpress": () => log("Behavioral Therapist - James selected")
  },
  {
    "id": 3,
    "name": "Child Therapist",
    "instructor": "James",
    "desc": "Lorem Ipsum is simply dummy text...",
    "image": ImagePaths.course1, // or appropriate image path
    "onpress": () => log("Child Therapist - James selected")
  },
  {
    "id": 4,
    "name": "Behavioral Therapist",
    "instructor": "James",
    "desc": "Lorem Ipsum is simply dummy text...",
    "image": ImagePaths.course1, // or appropriate image path
    "onpress": () => log("Behavioral Therapist - James selected")
  },
  {
    "id": 3,
    "name": "Child Therapist",
    "instructor": "James",
    "desc": "Lorem Ipsum is simply dummy text...",
    "image": ImagePaths.course1, // or appropriate image path
    "onpress": () => log("Child Therapist - James selected")
  },
  {
    "id": 4,
    "name": "Behavioral Therapist",
    "instructor": "James",
    "desc": "Lorem Ipsum is simply dummy text...",
    "image": ImagePaths.course1, // or appropriate image path
    "onpress": () => log("Behavioral Therapist - James selected")
  },
  {
    "id": 3,
    "name": "Child Therapist",
    "instructor": "James",
    "desc": "Lorem Ipsum is simply dummy text...",
    "image": ImagePaths.course1, // or appropriate image path
    "onpress": () => log("Child Therapist - James selected")
  },
  {
    "id": 4,
    "name": "Behavioral Therapist",
    "instructor": "James",
    "desc": "Lorem Ipsum is simply dummy text...",
    "image": ImagePaths.course1, // or appropriate image path
    "onpress": () => log("Behavioral Therapist - James selected")
  },
  {
    "id": 3,
    "name": "Child Therapist",
    "instructor": "James",
    "desc": "Lorem Ipsum is simply dummy text...",
    "image": ImagePaths.course1, // or appropriate image path
    "onpress": () => log("Child Therapist - James selected")
  },
  {
    "id": 4,
    "name": "Behavioral Therapist",
    "instructor": "James",
    "desc": "Lorem Ipsum is simply dummy text...",
    "image": ImagePaths.course1, // or appropriate image path
    "onpress": () => log("Behavioral Therapist - James selected")
  },
];
    return ConstrainedBox(
              // width: double.infinity,
              constraints: BoxConstraints(
                maxHeight:  Utils.windowHeight(context) * 0.7,),
              child: GridView.builder(
                itemCount: mypurchased ? 1 : courses.length,
                padding: EdgeInsets.all(20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: Utils.windowHeight(context) * 0.3,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),  itemBuilder: (ctx,i){
                      return (
                        CourseCard(image: courses[i]["image"] as String,
                        title: courses[i]["name"] as String,
                        desc: courses[i]["desc"] as String,
                        instructor: courses[i]["instructor"] as String,
                        )
                      );
                    }),
            );
  }
}