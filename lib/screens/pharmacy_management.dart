import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/models/app_enums.dart';
import 'package:icare/screens/cancelled_orders.dart';
import 'package:icare/screens/delievered_order.dart';
import 'package:icare/screens/filters.dart';
import 'package:icare/screens/my_orders.dart';
import 'package:icare/screens/recieved_orders.dart';
import 'package:icare/screens/transit_order.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/custom_text_input.dart';
import 'package:icare/widgets/order_type-card.dart';
import 'package:icare/widgets/section_header.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class PharmacyManagementScreen extends StatelessWidget {
  const PharmacyManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(
          text: 'Pharmacy Management',
          fontFamily: "Gilroy-Bold",
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.primary500,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              CustomInputField(
                width: Utils.windowWidth(context) * 0.9,

                hintText: "Search",
                trailingIcon: SvgWrapper(
                  assetPath: ImagePaths.filters,
                  onPress: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => FiltersScreen()),
                    );
                  },
                ),
                leadingIcon: SvgWrapper(assetPath: ImagePaths.search),
              ),
              SizedBox(height: ScallingConfig.scale(20)),
              SectionHeader(
                title: "Order Details",
                margin: EdgeInsets.symmetric(
                  horizontal: ScallingConfig.scale(10),
                ),
                showAction: false,
              ),
              SizedBox(height: ScallingConfig.scale(20)),
              SizedBox(
                width: Utils.windowWidth(context),
                height: Utils.windowHeight(context) * 0.6,
                child: GridView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: Utils.windowHeight(context) * 0.27,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  children: [
                    OrderTypecard(
                      type: OrderType.recent,
                      title: "Recent Orders",
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => RecievedOrders()));  
                      },
                    ),
                    OrderTypecard(
                      type: OrderType.delivered,
                      title: "Delivered Orders",
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => DelieveredOrder()));  
                      },
                    ),
                    OrderTypecard(
                      type: OrderType.cancelled,
                      title: "Cancelled Orders",
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => CancelledOrders()));  
                      },
                    ),
                    OrderTypecard(
                      type: OrderType.inTransit,
                      title: "In-Transit Orders",
                      onTap: () {

                        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => TransitOrderScreen()));  
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: ScallingConfig.scale(20)),
              SectionHeader(
                title: "My Products",
                margin: EdgeInsets.symmetric(
                  horizontal: ScallingConfig.scale(15),
                ),
                onActionTap: (){
                  // Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => MyOrdersScreen() ));
                },
                showAction: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
