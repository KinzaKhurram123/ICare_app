import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/models/app_enums.dart';
import 'package:icare/providers/auth_provider.dart';

import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/boooking_card.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/test_appointment.dart';

class BookingCategories extends StatefulWidget {
  const BookingCategories({super.key});

  @override
  State<BookingCategories> createState() => _BookingCategoriesState();
}

class _BookingCategoriesState extends State<BookingCategories>
    with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: CustomBackButton(),
        title: CustomText(text: "Upcoming"),
        bottom: TabBar(
          controller: controller,
          indicatorWeight: 6,
          indicatorColor: AppColors.themeBlack,
          tabs: [
            CustomText(
              text: "Upcoming",
              
              padding: EdgeInsets.only(bottom:5),
              width: Utils.windowWidth(context) * 0.33,
              textAlign: TextAlign.center,
            ),
            CustomText(
              text: "Cancelled",
              padding: EdgeInsets.only(bottom:5),
              width: Utils.windowWidth(context) * 0.33,
              textAlign: TextAlign.center,
            ),
            CustomText(
              padding: EdgeInsets.only(bottom:5),
              width: Utils.windowWidth(context) * 0.33,
              textAlign: TextAlign.center,
              text: "Completed",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: [
          UpcomingBOokingsList(
            status: BookingStatus.upcoming,
            data:[1,2,3],
          ),
          UpcomingBOokingsList(
            status: BookingStatus.cancelled,
            data:[1,2,3],
          ),
          UpcomingBOokingsList(
            status: BookingStatus.completed,
            data:[1,2,3],
          ),
          
        ],
      ),
    );
  }
}

class UpcomingBOokingsList extends ConsumerWidget {
  const UpcomingBOokingsList({super.key, this.data, this.status});
  final List<dynamic>? data;
  final BookingStatus? status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = ref.watch(authProvider).userRole;
    return ListView.builder(
      itemCount: data!.length,
      padding: EdgeInsets.only(
        right: ScallingConfig.scale(20),
        bottom: ScallingConfig.scale(40),
        left: ScallingConfig.scale(20)),
      itemBuilder: (ctx, i) {
        return (
          selectedRole == "lab_technician" ?
          TestAppointment(status : status)
           :
          BookingCard(status: status)
          
          );
      },
    );
  }
}


