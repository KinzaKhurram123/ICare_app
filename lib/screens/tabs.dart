import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/app.dart';
import 'package:icare/screens/bookings.dart';
import 'package:icare/screens/chatlist.dart';
import 'package:icare/screens/home.dart';
import 'package:icare/screens/notifications.dart';
import 'package:icare/screens/profile.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/drawer.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});
  @override
  State<TabsScreen> createState() => _TabsScreenState();
}
class _TabsScreenState extends State<TabsScreen> {
  var currentIndex=0;
  void _selectPage(int index){
    setState(() {
      currentIndex= index;
    });
  }
  
  
  @override
  Widget build(BuildContext context) {
   Widget  activePage = HomeScreen();
   if(currentIndex == 1){
    activePage= BookingsScreen(tabs:true);
    // activePage= Center(
    //   child: CustomText(text: "Bookings",),
    // );
   } else if(currentIndex == 2){
    activePage = ChatlistScreen();
   }else if(currentIndex == 3){
    activePage= ProfileScreen();
   } else {
    activePage = HomeScreen();
   }

    return Scaffold(

      appBar: AppBar(
        
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) {
            return Padding(
              padding:  EdgeInsets.only(left:ScallingConfig.scale(28.0)),
              child: GestureDetector(
                onTap: (){
                  Scaffold.of(context).openDrawer();
                },
                child: CircleAvatar(
                  backgroundColor: AppColors.white,
                  child: SvgWrapper(assetPath: ImagePaths.menu),
                )),
            );
          }
        ),
          actions: [
             Padding(
               padding:EdgeInsets.only(right: ScallingConfig.scale(10)),
               child: GestureDetector(
                onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => NotificationScreen()));
                },
                         child: CircleAvatar(
                           backgroundColor: AppColors.white,
                           child: SvgWrapper(assetPath: ImagePaths.notification),
                         )),
             ),  
          ],
      ),
      drawer: CustomDrawer(),
      body: activePage,

       bottomNavigationBar: SafeArea(
         child: Stack(
          clipBehavior: Clip.none,
           children: [
             Container(
              height: Utils.windowHeight(context) * 0.09,
                   decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15)
              )
                   ),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
         
                  IconButton(onPressed: (){
                    _selectPage(0);
                  }, icon: SvgWrapper(assetPath: ImagePaths.home, color: currentIndex == 0 ? AppColors.primaryColor : AppColors.grayColor ,)
                  ),
                  CustomText(text: "Home",)
         
                    ],
                  ),
                                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
         
                  IconButton(onPressed: (){
                    _selectPage(1);
                  }, icon: SvgWrapper(assetPath: ImagePaths.bookings, color: currentIndex == 1 ? AppColors.primaryColor : AppColors.grayColor ,)
                  ),
                  CustomText(text: "Bookings",)
         
                    ],
                  ),
                  SizedBox(width: 20,),
            //         CustomPaint(
            //   size: Size(MediaQuery.of(context).size.width, 70),
            //   painter: BottomNavCurvePainter(),
            // ),
                                 Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
         
                  IconButton(onPressed: (){
                    _selectPage(2);
                  }, icon: SvgWrapper(assetPath: ImagePaths.message, color: currentIndex == 2 ? AppColors.primaryColor : AppColors.grayColor ,)
                  ),
                  CustomText(text: "Chat",)
         
                    ],
                  ),
                                 Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
         
                  IconButton(onPressed: (){
                    _selectPage(3);
                  }, icon: SvgWrapper(assetPath: ImagePaths.profile2, color: currentIndex == 3 ? AppColors.primaryColor : AppColors.grayColor ,)
                  ),
                  CustomText(text: "Profile",)
         
                    ],
                  ),
                ],
              ),
             ),
            
              Positioned(
                left: Utils.windowWidth(context) * 0.41,
                top: ScallingConfig.verticalScale(-30),
                child: Container(
                width: Utils.windowWidth(context) > 762 ? Utils.windowWidth(context) * 0.1 :Utils.windowWidth(context) * 0.2,
                height: Utils.windowWidth(context) > 762 ? Utils.windowWidth(context) * 0.1 :Utils.windowWidth(context) * 0.2,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey
                ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(onPressed: (){}, icon: SvgWrapper(assetPath: ImagePaths.centerIcon))) ,
                ) 
                ),
           ],
         ),
       ),
    );
  }
}

