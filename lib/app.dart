import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/providers/common_provider.dart';
import 'package:icare/screens/select_user_type.dart';
import 'package:icare/screens/splash.dart';
import 'package:icare/screens/verify_code.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  Widget content = SplashScreen();

 @override
  void initState() {
    super.initState();
    loadData();
    splash();
  
  }

  void loadData() async{
        final userWalkthrough = await SharedPref().getUserWalkthrough();
        ref.watch(authProvider.notifier).setUserWalkthrough(userWalkthrough ?? false);

          print("$userWalkthrough" + ' ' + "===========>");
        final token = await SharedPref().getToken();
        ref.watch(authProvider.notifier).setUserToken(token!);

        final userData = await SharedPref().getUserData();
        ref.watch(commonProvider.notifier).setUserData(userData!);

        final userRole = await SharedPref().getUserRole();
        ref.watch(authProvider.notifier).setUserRole(userRole!);

  }

  void splash () async{
    await Future.delayed(const Duration(seconds: 6));

    if(!mounted) return;

    final bool userWalkthrough = ref.watch(authProvider).userWalkthrough;
    final String userRole = ref.watch(authProvider).userRole;
    final String? token = ref.watch(authProvider).token;
    
    
    setState(() {
      content = CreateProfile(); 
    });
  }  

  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SelectUserType(),
    );
  }
}