import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/create_reminder.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';
import 'package:intl/intl.dart';
import 'package:icare/services/reminder_service.dart';

class ReminderList extends StatefulWidget {
  const ReminderList({super.key});

  @override
  State<ReminderList> createState() => _ReminderListState();
}

class _ReminderListState extends State<ReminderList> {
  final ReminderService _reminderService = ReminderService();
  List<dynamic> _remindersList = [];
  bool _isLoading = true;
  var _selectedTime = '';
  var _selectedDate = '';

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final data = await _reminderService.getMyReminders();
    if (mounted) {
      setState(() {
        _remindersList = data;
        _isLoading = false;
      });
    }
  }

  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(
          text: "Patient Reminders",
          fontWeight: FontWeight.bold,
          letterSpacing: -0.31,
          lineHeight: 1.0,
          fontSize: 20,
          fontFamily: "Gilroy-Bold",
          color: AppColors.primaryColor,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Upcoming Reminders",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                            fontFamily: "Gilroy-Bold",
                          ),
                        ),
                        Row(
                          children: [
                            _buildWebFilterBtn(
                              context: context,
                              icon: Icons.access_time_filled_rounded,
                              label: _selectedTime.isNotEmpty
                                  ? _selectedTime
                                  : 'Select Time',
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (time != null)
                                  setState(
                                    () => _selectedTime = time.format(context),
                                  );
                              },
                            ),
                            const SizedBox(width: 12),
                            _buildWebFilterBtn(
                              context: context,
                              icon: Icons.calendar_today_rounded,
                              label: _selectedDate.isNotEmpty
                                  ? _selectedDate
                                  : "Select Date",
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2030),
                                );
                                if (date != null)
                                  setState(
                                    () => _selectedDate = DateFormat(
                                      "yyyy/MM/dd",
                                    ).format(date),
                                  );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _remindersList.isEmpty
                          ? const Center(child: Text("No reminders found"))
                          : RefreshIndicator(
                              onRefresh: _loadReminders,
                              child: ListView.builder(
                                padding: const EdgeInsets.only(bottom: 40),
                                itemCount: _remindersList.length,
                                itemBuilder: (ctx, i) {
                                  final item = _remindersList[i];
                                  return WebReminderWidget(
                                    title: item["title"],
                                    patientName:
                                        item["patientName"] ??
                                        item["patient"]?["name"],
                                    date: item["date"] != null
                                        ? DateFormat(
                                            'MMMM, dd, yyyy',
                                          ).format(DateTime.parse(item["date"]))
                                        : "N/A",
                                    time: item["time"] ?? "N/A",
                                    description: item["instructions"],
                                    description2: item["disease"],
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const CreateReminder()));
          if (result == true) _loadReminders();
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildWebFilterBtn({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primaryColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 600) {
      return _buildWebLayout(context);
    }

    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(
          text: "Patient Reminders List",
          fontWeight: FontWeight.bold,
          letterSpacing: -0.31,
          lineHeight: 1.0,
          fontSize: 16.78,
          fontFamily: "Gilroy-Bold",
          color: AppColors.primary500,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      boxShadow: BoxShadow(offset: Offset(0, 0)),
                      labelWidth: Utils.windowWidth(context) * 0.35,
                      borderRadius: 35,
                      borderColor: AppColors.veryLightGrey,
                      height: Utils.windowHeight(context) * 0.045,
                      width: Utils.windowWidth(context) * 0.45,
                      bgColor: AppColors.veryLightGrey,
                      label: _selectedTime.isNotEmpty
                          ? _selectedTime
                          : 'Select Time',
                      labelColor: AppColors.primaryColor,
                      labelSize: 11,
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null)
                          setState(() => _selectedTime = time.format(context));
                      },
                      trailingIcon: SvgWrapper(assetPath: ImagePaths.clock),
                    ),
                    SizedBox(width: ScallingConfig.scale(10)),
                    CustomButton(
                      boxShadow: BoxShadow(offset: Offset(0, 0)),
                      borderRadius: 35,
                      labelWidth: Utils.windowWidth(context) * 0.35,
                      borderColor: AppColors.veryLightGrey,
                      height: Utils.windowHeight(context) * 0.045,
                      width: Utils.windowWidth(context) * 0.45,
                      bgColor: AppColors.veryLightGrey,
                      label: _selectedDate.isNotEmpty
                          ? _selectedDate
                          : "Select Date",
                      labelColor: AppColors.primaryColor,
                      labelSize: 11,
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (date != null)
                          setState(
                            () => _selectedDate = DateFormat(
                              "yyyy/MM/dd",
                            ).format(date),
                          );
                      },
                      trailingIcon: SvgWrapper(assetPath: ImagePaths.calendar),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Expanded(
                  child: _remindersList.isEmpty
                      ? const Center(child: Text("No reminders found"))
                      : RefreshIndicator(
                          onRefresh: _loadReminders,
                          child: ListView.builder(
                            padding: EdgeInsets.only(
                              bottom: ScallingConfig.verticalScale(60),
                              left: ScallingConfig.scale(20),
                              right: ScallingConfig.scale(20),
                            ),
                            itemCount: _remindersList.length,
                            itemBuilder: (ctx, i) {
                              final item = _remindersList[i];
                              return ReminderWidget(
                                title: item["title"],
                                patientName:
                                    item["patientName"] ??
                                    item["patient"]?["name"],
                                date: item["date"] != null
                                    ? DateFormat(
                                        'MMMM, dd, yyyy',
                                      ).format(DateTime.parse(item["date"]))
                                    : "N/A",
                                time: item["time"] ?? "N/A",
                                description2: item["disease"],
                                description: item["instructions"],
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const CreateReminder()));
          if (result == true) _loadReminders();
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

class WebReminderWidget extends StatelessWidget {
  final String? title;
  final String? patientName;
  final String? date;
  final String? time;
  final String? description;
  final String? description2;

  const WebReminderWidget({
    super.key,
    this.title,
    this.patientName,
    this.date,
    this.time,
    this.description,
    this.description2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F4F9), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.notifications_active_rounded,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title ?? "",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                            fontFamily: "Gilroy-Bold",
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: Color(0xFFE2E8F0),
                        backgroundImage: AssetImage(ImagePaths.user7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        patientName ?? "",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        date ?? "",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Icon(
                        Icons.access_time_filled_rounded,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        time ?? "",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (description != null)
                          Text(
                            description!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF475569),
                              height: 1.5,
                            ),
                          ),
                        if (description2 != null)
                          Text(
                            description2!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF475569),
                              height: 1.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width:
                          100, // Fixed reasonable size for desktop instead of screen percentage
                      height: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          ImagePaths.attachment,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Right actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => CreateReminder(isEdit: true),
                    ),
                  ),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text("Edit"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    side: BorderSide(color: AppColors.primaryColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: const Text("Delete"),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReminderWidget extends StatelessWidget {
  const ReminderWidget({
    super.key,
    this.title,
    this.patientName,
    this.date,
    this.time,
    this.description,
    this.description2,
  });
  final String? title;
  final String? patientName;
  final String? date;
  final String? time;
  final String? description;
  final String? description2;
  // final String? ;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: ScallingConfig.verticalScale(15)),
      width: Utils.windowWidth(context) * 0.9,
      padding: EdgeInsets.symmetric(
        horizontal: ScallingConfig.scale(10),
        vertical: ScallingConfig.verticalScale(12),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomText(
            width: double.infinity,
            fontSize: 14.78,
            color: AppColors.primary500,
            text: title,
          ),
          CustomText(
            width: double.infinity,
            fontSize: 12.78,
            color: AppColors.darkGreyColor,
            text: patientName,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: "Date",
                fontSize: 12,
                color: AppColors.darkGreyColor,
              ),
              CustomText(
                text: date,
                isBold: true,
                color: AppColors.darkGreyColor,
              ),
            ],
          ),
          SizedBox(height: ScallingConfig.scale(5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: "Time",
                fontSize: 12,
                color: AppColors.darkGreyColor,
              ),
              CustomText(
                text: time,
                isBold: true,
                color: AppColors.darkGreyColor,
              ),
            ],
          ),
          SizedBox(height: ScallingConfig.scale(10)),
          CustomText(
            text: description,
            width: double.infinity,
            textAlign: TextAlign.left,
            fontFamily: "Gilroy-Medium",
            fontSize: 12.89,
          ),
          CustomText(
            width: double.infinity,
            text: description2,
            fontFamily: "Gilroy-Medium",
            maxLines: 2,
            fontSize: 12.89,
          ),
          SizedBox(height: ScallingConfig.scale(10)),
          Align(
            alignment: AlignmentGeometry.topLeft,
            child: SizedBox(
              width: Utils.windowWidth(context) * 0.25,
              height: Utils.windowWidth(context) * 0.25,
              child: ClipRect(
                child: Image.asset(ImagePaths.attachment, fit: BoxFit.cover),
              ),
            ),
          ),

          SizedBox(height: ScallingConfig.scale(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                width: Utils.windowWidth(context) * 0.4,
                borderRadius: 30,
                labelSize: 15,
                label: "Edit",
                onPressed: () {
                  // Navigator.of(context).pop(2);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => CreateReminder(isEdit: true),
                    ),
                  );
                },
              ),
              SizedBox(width: ScallingConfig.scale(10)),
              CustomButton(
                borderRadius: 30,
                labelSize: 15,
                labelColor: AppColors.primaryColor,
                width: Utils.windowWidth(context) * 0.4,
                label: "Delete",
                outlined: true,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
