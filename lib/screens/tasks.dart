import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen>
    with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(
          text: "My Tasks",
          fontWeight: FontWeight.bold,
          letterSpacing: -0.31,
          lineHeight: 1.0,
          fontSize: 16.78,
          fontFamily: "Gilroy-Bold",
          color: AppColors.primary500,
        ),
        bottom: TabBar(
          controller: controller,
          indicatorWeight: 6,

          indicatorColor: AppColors.themeBlack,
          tabs: [
            CustomText(
              text: "Assigned",

              padding: EdgeInsets.only(bottom: 5),
              width: Utils.windowWidth(context) * 0.45,
              textAlign: TextAlign.center,
              fontFamily: "Gilroy-Bold",
              fontSize: 13,
            ),
            CustomText(
              text: "Completed",
              fontFamily: "Gilroy-Bold",
              fontSize: 13,
              padding: EdgeInsets.only(bottom: 5),
              width: Utils.windowWidth(context) * 0.45,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: [TasksList(), TasksList()],
      ),
    );
  }
}

class TasksList extends StatelessWidget {
  const TasksList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(14)),
      itemCount: 5,
      itemBuilder: (ctx, i) {
        return (Task());
      },
    );
  }
}

class Task extends StatelessWidget {
  const Task({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: ScallingConfig.verticalScale(10)),
      padding: EdgeInsets.symmetric(
        vertical: ScallingConfig.verticalScale(10),
        horizontal: ScallingConfig.scale(15),
      ),
      width: Utils.windowWidth(context) * 0.9,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightGrey100,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: "12/12/2023",
                color: AppColors.tertiaryColor,
                fontSize: 10,
                fontWeight: FontWeight.w400,
                fontFamily: "Gilroy-Regular",
              ),
              Icon(Icons.more_horiz, color: AppColors.tertiaryColor),
            ],
          ),
          SizedBox(height: ScallingConfig.scale(8)),

          CustomText(
            text:
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever...",
            color: AppColors.primary500,
            fontSize: 12,
            maxLines: 8,
            fontWeight: FontWeight.w400,
            fontFamily: "Gilroy-Regular",
          ),
        ],
      ),
    );
  }
}
