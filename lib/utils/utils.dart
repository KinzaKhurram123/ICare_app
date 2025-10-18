import 'package:flutter/material.dart';

class Utils {
  static double windowWidth(BuildContext context){
    return MediaQuery.of(context).size.width;
  }
  static double windowHeight (BuildContext context){
    return MediaQuery.of(context).size.height;
  }

  
}