import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icare/app.dart';
import 'package:icare/utils/theme.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:responsive_framework/responsive_framework.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
    return ScreenUtilInit(
      designSize: const Size(1920, 1080), // Desktop design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: AppTheme.mainTheme,
          debugShowCheckedModeBanner: false,
          navigatorObservers: [FlutterSmartDialog.observer],
          builder: (context, child) {
            ScallingConfig().init(context);
            return ResponsiveBreakpoints.builder(
              child: FlutterSmartDialog.init()(context, child),
              breakpoints: const [
                Breakpoint(start: 0, end: 600, name: MOBILE),
                Breakpoint(start: 600, end: 900, name: TABLET), 
                Breakpoint(start: 901, end: 1920, name: DESKTOP),
                Breakpoint(start: 1921, end: double.infinity, name: '4K'),
              ],
            );
          },
          home: App(),
        );
      },
    );
  }
}
