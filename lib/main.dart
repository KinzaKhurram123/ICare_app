import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/app.dart';
import 'package:icare/utils/theme.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //   SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //   statusBarColor: Colors.deepOrange, // Set your desired color
  //   statusBarIconBrightness: Brightness.dark, // For white icons
  //   statusBarBrightness: Brightness.dark, // For iOS
  // ));
  runApp(
    ProviderScope(child: const MyApp())
    );
}
// 
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ScallingConfig().init(context);
    return  MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.mainTheme,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      home: App(),
    );

  
  }
}
