import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/app.dart';
import 'package:icare/screens/splash.dart';
import 'package:icare/screens/walkthrough.dart';
import 'package:icare/utils/theme.dart';

void main() {
  runApp(
    ProviderScope(child: const MyApp())
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ScallingConfig().init(context);
    return  MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.mainTheme,
      debugShowCheckedModeBanner: false,
      home: App(),
    );

  
  }
}
