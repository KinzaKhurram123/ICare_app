import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/upload_prescription.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class BottomTabBar extends ConsumerWidget {
  const BottomTabBar({super.key, required this.tabs, required this.onSelect, });
   final List<Widget>? tabs;
   final Function(dynamic value) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.read(authProvider).userRole;
    return SafeArea(
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
                children: tabs ?? [],
              ),
             ),
              Positioned(
                left: Utils.windowWidth(context) * 0.41,
                top: ScallingConfig.verticalScale(-30),
                child: Container(
                // width: Utils.windowWidth(context) > 762 ? Utils.windowWidth(context) * 0.1 :Utils.windowWidth(context) * 0.2,
                // height: Utils.windowWidth(context) > 762 ? Utils.windowWidth(context) * 0.1 :Utils.windowWidth(context) * 0.2,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // color: Colors.green,
                  color: Colors.grey.withAlpha(10)
                ),
                  child: CircleAvatar(
                    maxRadius: Utils.windowWidth(context) * 0.08,
                    // maxRadius: Utils.windowWidth(context) > 762 ? Utils.windowWidth(context) * 0.1 :Utils.windowWidth(context) * 0.2,
                    backgroundColor: Colors.white,
                    child: IconButton(onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => UploadPrescriptionScreen() ));
                    }, icon: SvgWrapper(assetPath: 
                    userRole == "instructor" ? ImagePaths.prescription :
                    ImagePaths.centerIcon))) ,
                ) 
                ),
           ],
         ),
       );
  }
}