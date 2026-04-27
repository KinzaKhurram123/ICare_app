import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_drop_down.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/custom_text_input.dart';
import 'package:icare/widgets/dotted_button.dart';
import 'package:icare/widgets/svg_wrapper.dart';
import 'package:intl/intl.dart';
import 'package:icare/services/reminder_service.dart';

class CreateReminder extends StatefulWidget {
  const CreateReminder({super.key, this.isEdit = false});
  final bool isEdit;

  @override
  State<CreateReminder> createState() => _CreateReminderState();
}

class _CreateReminderState extends State<CreateReminder> {
  final ReminderService _reminderService = ReminderService();
  final _emailController = TextEditingController();
  final _titleController = TextEditingController();
  final _nameController = TextEditingController();
  final _tabletController = TextEditingController();
  final _instructionsController = TextEditingController();

  var _selectedTime = '';
  var _selectedDate = '';
  String? _selectedDisease;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _titleController.dispose();
    _nameController.dispose();
    _tabletController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _submitReminder() async {
    if (_titleController.text.isEmpty ||
        _selectedTime.isEmpty ||
        _selectedDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final data = {
      "patientEmail": _emailController.text,
      "patientName": _nameController.text,
      "title": _titleController.text,
      "disease": _selectedDisease,
      "tablets": [_tabletController.text],
      "instructions": _instructionsController.text,
      "time": _selectedTime,
      "date": _selectedDate,
    };

    final result = await _reminderService.createReminder(data);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder created successfully')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to create reminder'),
          ),
        );
      }
    }
  }

  var diseaseList = [
    "Diabetes Mellitus",
    "Hypertension",
    "Asthma",
    "Influenza (Flu)",
    "COVID-19",
    "Tuberculosis",
    "Arthritis",
    "Migraine",
    "Depression",
    "Malaria",
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    if (isDesktop) {
      return _buildWebLayout();
    }
    return _buildMobileLayout();
  }

  // ══════════════════════════════════════════════════════════════════════
  // MOBILE LAYOUT — completely untouched original
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(
          text: "Create Reminder",
          fontSize: 16.78,
          fontFamily: "Gilroy-Bold",
          fontWeight: FontWeight.w400,
          color: AppColors.primary500,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomText(
              textAlign: TextAlign.left,
              width: Utils.windowWidth(context) * 0.9,
              text: "Reminder for Patient",
              color: AppColors.themeDarkGrey,
              fontSize: 16,
              fontFamily: "Gilroy-Medium",
            ),
            CustomInputField(
              controller: _emailController,
              hintText: "Patient Email",
              hintStyle: TextStyle(
                color: AppColors.grayColor.withAlpha(60),
                fontFamily: "Gilroy-SemiBold",
                fontSize: 12,
              ),
              borderRadius: 30,
              borderColor: AppColors.grayColor.withAlpha(70),
              width: Utils.windowWidth(context) * 0.9,
            ),
            CustomInputField(
              controller: _titleController,
              hintText: "Title",
              hintStyle: TextStyle(
                color: AppColors.grayColor.withAlpha(60),
                fontFamily: "Gilroy-SemiBold",
                fontSize: 12,
              ),
              borderRadius: 30,
              borderColor: AppColors.grayColor.withAlpha(70),
              width: Utils.windowWidth(context) * 0.9,
            ),
            CustomInputField(
              controller: _nameController,
              hintText: "Patient Name",
              hintStyle: TextStyle(
                color: AppColors.grayColor.withAlpha(60),
                fontFamily: "Gilroy-SemiBold",
                fontSize: 12,
              ),
              borderRadius: 30,
              borderColor: AppColors.grayColor.withAlpha(70),
              width: Utils.windowWidth(context) * 0.9,
            ),

            CustomDropdown<String>(
              title: "disease",
              showTitle: false,
              textColor: AppColors.grayColor.withAlpha(60),
              selectedItem: _selectedDisease,
              margin: EdgeInsets.symmetric(
                vertical: ScallingConfig.verticalScale(6),
              ),
              items: diseaseList,
              onChanged: (value) {
                setState(() {
                  _selectedDisease = value;
                });
              },
            ),
            CustomInputField(
              controller: _tabletController,
              hintText: "tablet Name",
              hintStyle: TextStyle(
                color: AppColors.grayColor.withAlpha(60),
                fontFamily: "Gilroy-SemiBold",
                fontSize: 12,
              ),
              borderRadius: 30,
              borderColor: AppColors.grayColor.withAlpha(70),
              width: Utils.windowWidth(context) * 0.9,
            ),
            CustomInputField(
              controller: _instructionsController,
              width: Utils.windowWidth(context) * 0.9,
              hintText: "What Patient have to do...",
              hintStyle: TextStyle(
                color: AppColors.grayColor.withAlpha(60),
                fontFamily: "Gilroy-SemiBold",
                fontSize: 12,
              ),
              padding: EdgeInsets.only(
                left: ScallingConfig.scale(25),
                top: ScallingConfig.scale(10),
              ),
              height: Utils.windowHeight(context) * 0.15,
              maxLines: 5,
              borderRadius: 25,
              borderColor: AppColors.grayColor.withAlpha(70),
            ),

            SizedBox(height: ScallingConfig.scale(12)),
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
                    if (time != null) {
                      setState(() {
                        _selectedTime = time.format(context);
                      });
                    }
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
                    if (date != null) {
                      setState(() {
                        _selectedDate = DateFormat("yyyy/MM/dd").format(date);
                      });
                    }
                  },
                  trailingIcon: Align(
                    child: SvgWrapper(assetPath: ImagePaths.calendar),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScallingConfig.scale(10)),
            DottedButton(
              width: Utils.windowWidth(context) * 0.9,
              title: "Uplaod Prescription",
              onPressed: () {},
            ),
            SizedBox(height: ScallingConfig.scale(15)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  width: Utils.windowWidth(context) * 0.45,
                  borderRadius: 30,
                  labelSize: 15,
                  label: _isSubmitting
                      ? "Processing..."
                      : (widget.isEdit ? "Edit Reminder" : "Create Reminder"),
                  onPressed: _isSubmitting ? null : _submitReminder,
                ),
                SizedBox(width: ScallingConfig.scale(10)),
                CustomButton(
                  borderRadius: 30,
                  labelSize: 15,
                  labelColor: AppColors.primaryColor,
                  width: Utils.windowWidth(context) * 0.45,
                  label: "Reminder List",
                  outlined: true,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // WEB / DESKTOP LAYOUT — premium responsive design
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildWebLayout() {
    const inputHintStyle = TextStyle(
      color: Color(0xFF94A3B8),
      fontFamily: "Gilroy-Medium",
      fontSize: 14,
    );
    const inputBorderColor = Color(0xFFE2E8F0);
    const double inputRadius = 14;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Column(
        children: [
          // ── Top Bar ────────────────────────────────────────────────
          Container(
            height: 72,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 12,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: [
                // Back button
                Material(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).pop(),
                    child: const SizedBox(
                      width: 42,
                      height: 42,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF0B2D6E),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isEdit ? "Edit Reminder" : "Create Reminder",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0B2D6E),
                        fontFamily: "Gilroy-Bold",
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Set up medication and appointment reminders for patients",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w400,
                        fontFamily: "Gilroy-Medium",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Content Area ───────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 780),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Main Form Card ──────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(44),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section Header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withOpacity(
                                      0.08,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.person_outline_rounded,
                                    color: AppColors.primaryColor,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Patient Information",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E293B),
                                        fontFamily: "Gilroy-Bold",
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "Enter the patient details for the reminder",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF94A3B8),
                                        fontFamily: "Gilroy-Medium",
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Row 1: Patient Email + Title
                            Row(
                              children: [
                                Expanded(
                                  child: _webField(
                                    "Patient Email",
                                    inputHintStyle,
                                    inputBorderColor,
                                    inputRadius,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _webField(
                                    "Title",
                                    inputHintStyle,
                                    inputBorderColor,
                                    inputRadius,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Row 2: Patient Name + Disease
                            Row(
                              children: [
                                Expanded(
                                  child: _webField(
                                    "Patient Name",
                                    inputHintStyle,
                                    inputBorderColor,
                                    inputRadius,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: CustomDropdown<String>(
                                    title: "disease",
                                    showTitle: false,
                                    textColor: const Color(0xFF94A3B8),
                                    selectedItem: _selectedDisease,
                                    margin: EdgeInsets.zero,
                                    items: diseaseList,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedDisease = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Row 3: Tablet Name
                            _webField(
                              "Tablet Name",
                              inputHintStyle,
                              inputBorderColor,
                              inputRadius,
                            ),
                            const SizedBox(height: 20),

                            // Separator
                            const Divider(color: Color(0xFFF1F5F9), height: 1),
                            const SizedBox(height: 28),

                            // Section: Details
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF22C55E,
                                    ).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.description_outlined,
                                    color: Color(0xFF22C55E),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Reminder Details",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E293B),
                                        fontFamily: "Gilroy-Bold",
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "Describe the instructions and schedule",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF94A3B8),
                                        fontFamily: "Gilroy-Medium",
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Instructions textarea
                            CustomInputField(
                              hintText: "What Patient have to do...",
                              hintStyle: inputHintStyle,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              height: 140,
                              maxLines: 50,
                              borderRadius: inputRadius,
                              borderColor: inputBorderColor,
                              bgColor: const Color(0xFFF8FAFC),
                            ),
                            const SizedBox(height: 24),

                            // Time & Date Row
                            Row(
                              children: [
                                Expanded(
                                  child: _webPickerButton(
                                    label: _selectedTime.isNotEmpty
                                        ? _selectedTime
                                        : "Select Time",
                                    icon: Icons.access_time_rounded,
                                    onTap: () async {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                      if (time != null) {
                                        setState(() {
                                          _selectedTime = time.format(context);
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _webPickerButton(
                                    label: _selectedDate.isNotEmpty
                                        ? _selectedDate
                                        : "Select Date",
                                    icon: Icons.calendar_today_rounded,
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(2030),
                                      );
                                      if (date != null) {
                                        setState(() {
                                          _selectedDate = DateFormat(
                                            "yyyy/MM/dd",
                                          ).format(date);
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Upload prescription
                            DottedButton(
                              title: "Upload Prescription",
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Action Buttons ──────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Cancel / Reminder List
                          SizedBox(
                            height: 52,
                            width: 180,
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                "Reminder List",
                                style: TextStyle(
                                  color: Color(0xFF475569),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  fontFamily: "Gilroy-SemiBold",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Primary action
                          SizedBox(
                            height: 52,
                            width: 200,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop(2);
                              },
                              icon: Icon(
                                widget.isEdit
                                    ? Icons.edit_rounded
                                    : Icons.add_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                              label: Text(
                                widget.isEdit
                                    ? "Edit Reminder"
                                    : "Create Reminder",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  fontFamily: "Gilroy-Bold",
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _webField(
    String hint,
    TextStyle hintStyle,
    Color borderColor,
    double radius,
  ) {
    return CustomInputField(
      hintText: hint,
      hintStyle: hintStyle,
      borderRadius: radius,
      borderColor: borderColor,
      borderWidth: 1.5,
      bgColor: const Color(0xFFF8FAFC),
    );
  }

  Widget _webPickerButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: label.startsWith("Select")
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Gilroy-SemiBold",
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
