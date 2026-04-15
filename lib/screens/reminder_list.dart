import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/create_reminder.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';
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

  List<dynamic> get _doctorAssigned =>
      _remindersList.where((r) => r['doctor'] != null).toList();

  List<dynamic> get _selfCreated =>
      _remindersList.where((r) => r['doctor'] == null).toList();

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
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const CreateReminder()),
                            );
                            if (result == true) _loadReminders();
                          },
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add Reminder'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _remindersList.isEmpty
                          ? const Center(child: Text("No reminders found"))
                          : RefreshIndicator(
                              onRefresh: _loadReminders,
                              child: ListView(
                                padding: const EdgeInsets.only(bottom: 40),
                                children: [
                                  if (_doctorAssigned.isNotEmpty) ...[
                                    _buildSectionHeader('Doctor-Assigned Reminders', Icons.medical_services_rounded, const Color(0xFF3B82F6)),
                                    const SizedBox(height: 12),
                                    ..._doctorAssigned.map((item) => WebReminderWidget(
                                      title: item["title"],
                                      patientName: item["patientName"] ?? item["patient"]?["name"],
                                      date: item["date"] != null ? DateFormat('MMMM, dd, yyyy').format(DateTime.parse(item["date"])) : "N/A",
                                      time: item["time"] ?? "N/A",
                                      description: item["instructions"],
                                      description2: item["disease"],
                                      isAssigned: true,
                                    )),
                                    const SizedBox(height: 20),
                                  ],
                                  _buildSectionHeader('My Reminders', Icons.person_rounded, AppColors.primaryColor),
                                  const SizedBox(height: 12),
                                  if (_selfCreated.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 20),
                                      child: Center(child: Text('No self-created reminders yet.', style: TextStyle(color: Color(0xFF64748B)))),
                                    )
                                  else
                                    ..._selfCreated.map((item) => WebReminderWidget(
                                      title: item["title"],
                                      patientName: item["patientName"] ?? item["patient"]?["name"],
                                      date: item["date"] != null ? DateFormat('MMMM, dd, yyyy').format(DateTime.parse(item["date"])) : "N/A",
                                      time: item["time"] ?? "N/A",
                                      description: item["instructions"],
                                      description2: item["disease"],
                                    )),
                                ],
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

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
            fontFamily: 'Gilroy-Bold',
          ),
        ),
      ],
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
          : RefreshIndicator(
              onRefresh: _loadReminders,
              child: _remindersList.isEmpty
                  ? const Center(child: Text("No reminders found"))
                  : ListView(
                      padding: EdgeInsets.only(
                        bottom: ScallingConfig.verticalScale(80),
                        left: ScallingConfig.scale(20),
                        right: ScallingConfig.scale(20),
                        top: 12,
                      ),
                      children: [
                        if (_doctorAssigned.isNotEmpty) ...[
                          _buildSectionHeader('Doctor-Assigned Reminders', Icons.medical_services_rounded, const Color(0xFF3B82F6)),
                          const SizedBox(height: 8),
                          ..._doctorAssigned.map((item) => ReminderWidget(
                            title: item["title"],
                            patientName: item["patientName"] ?? item["patient"]?["name"],
                            date: item["date"] != null ? DateFormat('MMMM, dd, yyyy').format(DateTime.parse(item["date"])) : "N/A",
                            time: item["time"] ?? "N/A",
                            description2: item["disease"],
                            description: item["instructions"],
                          )),
                          const SizedBox(height: 16),
                        ],
                        _buildSectionHeader('My Reminders', Icons.person_rounded, AppColors.primaryColor),
                        const SizedBox(height: 8),
                        if (_selfCreated.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: Text('No self-created reminders yet.', style: TextStyle(color: Color(0xFF64748B)))),
                          )
                        else
                          ..._selfCreated.map((item) => ReminderWidget(
                            title: item["title"],
                            patientName: item["patientName"] ?? item["patient"]?["name"],
                            date: item["date"] != null ? DateFormat('MMMM, dd, yyyy').format(DateTime.parse(item["date"])) : "N/A",
                            time: item["time"] ?? "N/A",
                            description2: item["disease"],
                            description: item["instructions"],
                          )),
                      ],
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const CreateReminder()),
          );
          if (result == true) _loadReminders();
        },
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Reminder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
  final bool isAssigned;

  const WebReminderWidget({
    super.key,
    this.title,
    this.patientName,
    this.date,
    this.time,
    this.description,
    this.description2,
    this.isAssigned = false,
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
                          isAssigned ? Icons.medical_services_rounded : Icons.notifications_active_rounded,
                          color: isAssigned ? const Color(0xFF3B82F6) : AppColors.primaryColor,
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
