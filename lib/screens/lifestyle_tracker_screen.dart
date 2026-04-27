import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';

class LifestyleTrackerScreen extends StatefulWidget {
  const LifestyleTrackerScreen({super.key});

  @override
  State<LifestyleTrackerScreen> createState() => _LifestyleTrackerScreenState();
}

class _LifestyleTrackerScreenState extends State<LifestyleTrackerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Placeholder state data ──────────────────────────────────────────────
  // Vitals
  int _systolic = 120;
  int _diastolic = 80;
  double _bloodSugar = 110;
  double _weight = 70.4;
  int _heartRate = 78;
  int _spO2 = 98;

  // Lifestyle
  int _waterGlasses = 5;
  int _steps = 2500;
  double _sleepHours = 7.0;
  String _mealQuality = 'Good';

  // Medication
  bool _medicationTaken = true;
  bool _missedDose = false;

  // Condition-specific
  String _conditionMode = 'General Wellness';

  // Mood
  String _selectedMood = '😊';
  int _stressLevel = 3;
  int _calories = 1450;
  int _hydrationPct = 62;

  // Menstrual cycle
  bool _periodTracking = true;
  int _cycleDay = 14;
  String _cyclePhase = 'Ovulation';

  // Points
  int _pointsToday = 45;

  double get _dailyGoalProgress => 0.62;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Generic single-field numeric dialog ────────────────────────────────
  Future<void> _showNumericDialog({
    required String title,
    required String subtitle,
    required String unit,
    required double currentValue,
    required ValueChanged<double> onSave,
    int earnPoints = 5,
  }) async {
    final controller =
        TextEditingController(text: currentValue.toStringAsFixed(currentValue == currentValue.roundToDouble() ? 0 : 1));
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LogBottomSheet(
        title: title,
        subtitle: subtitle,
        unit: unit,
        controller: controller,
        earnPoints: earnPoints,
        onSave: () {
          final val = double.tryParse(controller.text);
          if (val != null) {
            onSave(val);
            setState(() => _pointsToday += earnPoints);
          }
          Navigator.pop(ctx);
        },
      ),
    );
  }

  // ── BP dialog (two fields) ──────────────────────────────────────────────
  Future<void> _showBPDialog() async {
    final sysCtrl = TextEditingController(text: _systolic.toString());
    final diaCtrl = TextEditingController(text: _diastolic.toString());
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BPBottomSheet(
        sysCtrl: sysCtrl,
        diaCtrl: diaCtrl,
        onSave: () {
          final sys = int.tryParse(sysCtrl.text);
          final dia = int.tryParse(diaCtrl.text);
          if (sys != null && dia != null) {
            setState(() {
              _systolic = sys;
              _diastolic = dia;
              _pointsToday += 5;
            });
          }
          Navigator.pop(ctx);
        },
      ),
    );
  }

  // ── Mood picker dialog ─────────────────────────────────────────────────
  Future<void> _showMoodPicker() async {
    const moods = ['😊', '😐', '😔', '😡', '😴', '🤒'];
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('How are you feeling today?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Wrap(
          spacing: 16,
          children: moods
              .map((m) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMood = m;
                        _pointsToday += 5;
                      });
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: m == _selectedMood
                            ? AppColors.primaryColor.withOpacity(0.12)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: m == _selectedMood
                              ? AppColors.primaryColor
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(m, style: const TextStyle(fontSize: 32)),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: const Text(
          'Health Tracker',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w900,
            fontSize: 18,
            fontFamily: 'Gilroy-Bold',
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '$_pointsToday pts today',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeroHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVitalsTab(),
                _buildLifestyleTab(),
                _buildMedicationTab(),
                _buildConditionTab(),
                _buildMoodTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _tabController.animateTo(0),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Log More',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ── Hero header ─────────────────────────────────────────────────────────
  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hello, Sarah 👋',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              fontFamily: 'Gilroy-Bold',
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Your Health Today',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Daily Goal',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B)),
                        ),
                        Text(
                          '${(_dailyGoalProgress * 100).toInt()}% Complete',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: _dailyGoalProgress,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 20)),
                    Text(
                      '$_pointsToday',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFB45309),
                      ),
                    ),
                    const Text('pts',
                        style:
                            TextStyle(fontSize: 10, color: Color(0xFFB45309))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tab bar ─────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    const tabs = [
      _TabMeta('Vitals', Icons.favorite_outline_rounded),
      _TabMeta('Lifestyle', Icons.directions_walk_rounded),
      _TabMeta('Medication', Icons.medication_outlined),
      _TabMeta('Condition', Icons.health_and_safety_outlined),
      _TabMeta('Mood', Icons.sentiment_satisfied_alt_outlined),
    ];

    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: const Color(0xFF94A3B8),
        indicatorColor: AppColors.primaryColor,
        indicatorWeight: 2.5,
        labelStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        tabs: tabs
            .map((t) => Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(t.icon, size: 16),
                      const SizedBox(width: 6),
                      Text(t.label),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // Tab 1 — VITALS
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildVitalsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Vitals', 'Tap any card to log manually'),
          const SizedBox(height: 12),
          // Quick overview tiles row
          _buildQuickTiles(),
          const SizedBox(height: 20),
          // Detailed vital cards
          _vitalCard(
            icon: Icons.favorite_rounded,
            iconColor: const Color(0xFFEF4444),
            bgColor: const Color(0xFFFEF2F2),
            label: 'Blood Pressure',
            value: '$_systolic/$_diastolic',
            unit: 'mmHg',
            status: _bpStatus,
            statusColor: _bpStatusColor,
            onTap: _showBPDialog,
          ),
          const SizedBox(height: 12),
          _vitalCard(
            icon: Icons.water_drop_rounded,
            iconColor: const Color(0xFF3B82F6),
            bgColor: const Color(0xFFEFF6FF),
            label: 'Blood Sugar',
            value: _bloodSugar.toStringAsFixed(0),
            unit: 'mg/dL',
            status: _bloodSugar < 100
                ? 'Normal'
                : _bloodSugar < 126
                    ? 'Pre-diabetic'
                    : 'High',
            statusColor: _bloodSugar < 100
                ? Colors.green
                : _bloodSugar < 126
                    ? Colors.orange
                    : Colors.red,
            onTap: () => _showNumericDialog(
              title: 'Blood Sugar',
              subtitle: 'Enter your fasting blood sugar reading',
              unit: 'mg/dL',
              currentValue: _bloodSugar,
              onSave: (v) => setState(() => _bloodSugar = v),
            ),
          ),
          const SizedBox(height: 12),
          _vitalCard(
            icon: Icons.monitor_weight_outlined,
            iconColor: const Color(0xFF8B5CF6),
            bgColor: const Color(0xFFF5F3FF),
            label: 'Weight',
            value: _weight.toStringAsFixed(1),
            unit: 'kg',
            status: 'BMI: 25.8',
            statusColor: Colors.orange,
            onTap: () => _showNumericDialog(
              title: 'Weight',
              subtitle: 'Enter your current body weight',
              unit: 'kg',
              currentValue: _weight,
              onSave: (v) => setState(() => _weight = v),
            ),
          ),
          const SizedBox(height: 12),
          _vitalCard(
            icon: Icons.monitor_heart_outlined,
            iconColor: const Color(0xFFF59E0B),
            bgColor: const Color(0xFFFFFBEB),
            label: 'Heart Rate',
            value: _heartRate.toString(),
            unit: 'BPM',
            status: _heartRate < 60
                ? 'Low'
                : _heartRate <= 100
                    ? 'Normal'
                    : 'High',
            statusColor: _heartRate < 60 || _heartRate > 100
                ? Colors.red
                : Colors.green,
            onTap: () => _showNumericDialog(
              title: 'Heart Rate',
              subtitle: 'Enter your resting heart rate in BPM',
              unit: 'BPM',
              currentValue: _heartRate.toDouble(),
              onSave: (v) => setState(() => _heartRate = v.toInt()),
            ),
          ),
          const SizedBox(height: 12),
          _vitalCard(
            icon: Icons.air_rounded,
            iconColor: const Color(0xFF10B981),
            bgColor: const Color(0xFFECFDF5),
            label: 'SpO2 (Oxygen)',
            value: '$_spO2',
            unit: '%',
            status: _spO2 >= 95 ? 'Normal' : 'Low — See Doctor',
            statusColor: _spO2 >= 95 ? Colors.green : Colors.red,
            onTap: () => _showNumericDialog(
              title: 'SpO2 Level',
              subtitle: 'Enter your blood oxygen saturation (%)',
              unit: '%',
              currentValue: _spO2.toDouble(),
              onSave: (v) => setState(() => _spO2 = v.toInt().clamp(0, 100)),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildQuickTiles() {
    return Row(
      children: [
        Expanded(
          child: _miniTile(
            '💓',
            '$_systolic/$_diastolic',
            'BP',
            const Color(0xFFFEF2F2),
            onTap: _showBPDialog,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _miniTile(
            '🩸',
            '${_bloodSugar.toStringAsFixed(0)} mg',
            'Sugar',
            const Color(0xFFEFF6FF),
            onTap: () => _showNumericDialog(
              title: 'Blood Sugar',
              subtitle: 'Enter your fasting blood sugar reading',
              unit: 'mg/dL',
              currentValue: _bloodSugar,
              onSave: (v) => setState(() => _bloodSugar = v),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _miniTile(
            '⚖️',
            '${_weight.toStringAsFixed(1)} kg',
            'Weight',
            const Color(0xFFF5F3FF),
            onTap: () => _showNumericDialog(
              title: 'Weight',
              subtitle: 'Enter your current body weight',
              unit: 'kg',
              currentValue: _weight,
              onSave: (v) => setState(() => _weight = v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniTile(String emoji, String value, String label, Color bg,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
            Text(label,
                style:
                    const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  String get _bpStatus {
    if (_systolic < 120 && _diastolic < 80) return 'Normal';
    if (_systolic < 130 && _diastolic < 80) return 'Elevated';
    if (_systolic < 140 || _diastolic < 90) return 'High Stage 1';
    return 'High Stage 2';
  }

  Color get _bpStatusColor {
    if (_systolic < 120 && _diastolic < 80) return Colors.green;
    if (_systolic < 130) return Colors.orange;
    return Colors.red;
  }

  Widget _vitalCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
    required String unit,
    required String status,
    required Color statusColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(value,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A))),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(unit,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF94A3B8))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(status,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_note_rounded,
                color: Color(0xFFCBD5E1), size: 20),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // Tab 2 — LIFESTYLE
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildLifestyleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Lifestyle', 'Track daily habits'),
          const SizedBox(height: 12),

          // Water intake — circular progress
          GestureDetector(
            onTap: () => _showNumericDialog(
              title: 'Water Intake',
              subtitle: 'How many glasses of water have you had?',
              unit: 'glasses',
              currentValue: _waterGlasses.toDouble(),
              onSave: (v) =>
                  setState(() => _waterGlasses = v.toInt().clamp(0, 20)),
            ),
            child: _waterCard(),
          ),
          const SizedBox(height: 12),

          // Steps
          _lifestyleCard(
            emoji: '🚶',
            label: 'Steps Today',
            value: '$_steps',
            unit: 'steps',
            target: '10,000 goal',
            progress: (_steps / 10000).clamp(0.0, 1.0),
            progressColor: const Color(0xFFF59E0B),
            onTap: () => _showNumericDialog(
              title: 'Steps',
              subtitle: 'Enter your step count for today',
              unit: 'steps',
              currentValue: _steps.toDouble(),
              onSave: (v) => setState(() => _steps = v.toInt()),
            ),
          ),
          const SizedBox(height: 12),

          // Sleep
          _lifestyleCard(
            emoji: '😴',
            label: 'Sleep',
            value: _sleepHours.toStringAsFixed(1),
            unit: 'hours',
            target: '8 hrs goal',
            progress: (_sleepHours / 8).clamp(0.0, 1.0),
            progressColor: const Color(0xFF8B5CF6),
            onTap: () => _showNumericDialog(
              title: 'Sleep',
              subtitle: 'How many hours did you sleep last night?',
              unit: 'hours',
              currentValue: _sleepHours,
              onSave: (v) =>
                  setState(() => _sleepHours = v.clamp(0, 24)),
            ),
          ),
          const SizedBox(height: 12),

          // Meal quality
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('🥗', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 10),
                    Text('Diet / Meal Quality',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A))),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: ['Excellent', 'Good', 'Fair', 'Poor']
                      .map((q) => GestureDetector(
                            onTap: () =>
                                setState(() => _mealQuality = q),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: _mealQuality == q
                                    ? AppColors.primaryColor
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(q,
                                  style: TextStyle(
                                    color: _mealQuality == q
                                        ? Colors.white
                                        : const Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  )),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _waterCard() {
    final pct = (_waterGlasses / 8).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: pct,
                  strokeWidth: 7,
                  backgroundColor: const Color(0xFFDBEAFE),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                  strokeCap: StrokeCap.round,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💧', style: TextStyle(fontSize: 18)),
                    Text('$_waterGlasses/8',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E40AF))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Water Intake',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text('$_waterGlasses of 8 glasses',
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                Text(
                  _waterGlasses >= 8
                      ? '🎉 Daily goal reached!'
                      : 'Tap to log more glasses',
                  style: TextStyle(
                    fontSize: 12,
                    color: _waterGlasses >= 8
                        ? Colors.green
                        : AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.add_rounded,
                  color: Color(0xFF3B82F6), size: 20),
              onPressed: () =>
                  setState(() => _waterGlasses = (_waterGlasses + 1).clamp(0, 20)),
              tooltip: 'Add a glass',
            ),
          ),
        ],
      ),
    );
  }

  Widget _lifestyleCard({
    required String emoji,
    required String label,
    required String value,
    required String unit,
    required String target,
    required double progress,
    required Color progressColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Text(label,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const Spacer(),
                Text(target,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A))),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(unit,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF94A3B8))),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // Tab 3 — MEDICATION
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildMedicationTab() {
    final meds = [
      _MedItem('Metformin 500mg', 'Twice daily — After meals', true),
      _MedItem('Lisinopril 10mg', 'Once daily — Morning', false),
      _MedItem('Atorvastatin 20mg', 'Once daily — Night', false),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Medication', 'Track your prescriptions'),
          const SizedBox(height: 12),

          // Summary chips
          Row(
            children: [
              _medChip('💊', '${meds.where((m) => m.taken).length}/${meds.length}',
                  'Taken', const Color(0xFFECFDF5), Colors.green),
              const SizedBox(width: 10),
              _medChip('⚠️', _missedDose ? '1' : '0', 'Missed',
                  const Color(0xFFFEF2F2), Colors.red),
            ],
          ),
          const SizedBox(height: 16),

          // Medication list
          ...meds.asMap().entries.map((entry) {
            final i = entry.key;
            final med = entry.value;
            return _medCard(med, i);
          }),

          const SizedBox(height: 16),
          // Add medication note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline_rounded,
                    color: Color(0xFFB45309), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Prescription tracking is for reminders only. Always follow your doctor\'s advice.',
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFB45309),
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _medChip(
      String emoji, String count, String label, Color bg, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(count,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: textColor)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _medCard(_MedItem med, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: med.taken
                  ? const Color(0xFFECFDF5)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              med.taken
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color:
                  med.taken ? Colors.green : const Color(0xFFCBD5E1),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(med.schedule,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Switch(
            value: med.taken,
            activeColor: AppColors.primaryColor,
            onChanged: (v) => setState(() => med.taken = v),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // Tab 4 — CONDITION-SPECIFIC
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildConditionTab() {
    final conditionCards = {
      'General Wellness': [
        _CondItem('🏃', 'Daily Exercise', 'Did you exercise today?', false),
        _CondItem('🥦', 'Balanced Diet', 'Ate fruits/vegetables?', true),
        _CondItem('💤', 'Good Sleep', 'Slept 7+ hours?', true),
      ],
      'Diabetes': [
        _CondItem('🩸', 'Morning Sugar', 'Logged fasting glucose?', false),
        _CondItem('💊', 'Insulin/Meds', 'Taken as prescribed?', true),
        _CondItem('🦶', 'Foot Check', 'Daily foot inspection done?', false),
        _CondItem('🥗', 'Carb Intake', 'Tracked carbohydrates?', true),
      ],
      'Hypertension': [
        _CondItem('❤️', 'BP Logged', 'Blood pressure recorded?', true),
        _CondItem('🧂', 'Low Salt', 'Avoided high-sodium foods?', false),
        _CondItem('🚶', 'Light Walk', 'Done 30-min walk?', false),
        _CondItem('😌', 'Stress Check', 'Practiced relaxation?', true),
      ],
    };

    final items = conditionCards[_conditionMode] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Condition-Specific', 'Personalized tracking'),
          const SizedBox(height: 12),

          // Mode selector
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: conditionCards.keys.map((mode) {
                final selected = _conditionMode == mode;
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _conditionMode = mode),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            selected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 6,
                                )
                              ]
                            : [],
                      ),
                      child: Text(
                        mode,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? AppColors.primaryColor
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Checklist items
          ...items.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Text(item.emoji,
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A))),
                          Text(item.subtitle,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: item.checked,
                      activeColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      onChanged: (v) =>
                          setState(() => item.checked = v ?? false),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // Tab 5 — MOOD & MENTAL
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildMoodTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Mood & Mental Health', 'How are you feeling?'),
          const SizedBox(height: 12),

          // Mood selector card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor.withOpacity(0.07),
                  const Color(0xFFEFF6FF),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Today's Mood",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                const Text('Tap an emoji to log how you feel',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFF64748B))),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _showMoodPicker,
                  child: Row(
                    children: [
                      Text(_selectedMood,
                          style: const TextStyle(fontSize: 48)),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _moodLabel(_selectedMood),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryColor),
                          ),
                          Text('Tap to change',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Stress level
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Stress Level',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    5,
                    (i) => GestureDetector(
                      onTap: () =>
                          setState(() => _stressLevel = i + 1),
                      child: Column(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _stressLevel == i + 1
                                  ? _stressColor(i + 1)
                                  : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                              border: _stressLevel == i + 1
                                  ? Border.all(
                                      color: _stressColor(i + 1),
                                      width: 2)
                                  : null,
                            ),
                            child: Center(
                              child: Text('${i + 1}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: _stressLevel == i + 1
                                        ? Colors.white
                                        : const Color(0xFF94A3B8),
                                  )),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            i == 0
                                ? 'Low'
                                : i == 4
                                    ? 'High'
                                    : '',
                            style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Calories & Hydration row
          Row(
            children: [
              Expanded(
                child: _moodMetricCard(
                  emoji: '🔥',
                  label: 'Calories',
                  value: '$_calories',
                  unit: 'kcal',
                  color: const Color(0xFFEF4444),
                  onTap: () => _showNumericDialog(
                    title: 'Calories',
                    subtitle: 'Estimated calories consumed today',
                    unit: 'kcal',
                    currentValue: _calories.toDouble(),
                    onSave: (v) =>
                        setState(() => _calories = v.toInt()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _moodMetricCard(
                  emoji: '💧',
                  label: 'Hydration',
                  value: '$_hydrationPct',
                  unit: '%',
                  color: const Color(0xFF3B82F6),
                  onTap: () => _showNumericDialog(
                    title: 'Hydration',
                    subtitle: 'Estimated hydration level (%)',
                    unit: '%',
                    currentValue: _hydrationPct.toDouble(),
                    onSave: (v) => setState(
                        () => _hydrationPct = v.toInt().clamp(0, 100)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Menstrual Cycle tracker
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🌸', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Menstrual Cycle',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A))),
                          Text('Cycle day tracking',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    Switch(
                      value: _periodTracking,
                      activeColor: const Color(0xFFEC4899),
                      onChanged: (v) =>
                          setState(() => _periodTracking = v),
                    ),
                  ],
                ),
                if (_periodTracking) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Day $_cycleDay of cycle',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A))),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDF2F8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(_cyclePhase,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFEC4899))),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Color(0xFFEC4899)),
                            onPressed: () => setState(() {
                              _cycleDay =
                                  (_cycleDay - 1).clamp(1, 35);
                              _cyclePhase = _getCyclePhase(_cycleDay);
                            }),
                          ),
                          Text('$_cycleDay',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFEC4899))),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                color: Color(0xFFEC4899)),
                            onPressed: () => setState(() {
                              _cycleDay =
                                  (_cycleDay + 1).clamp(1, 35);
                              _cyclePhase = _getCyclePhase(_cycleDay);
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _cycleDay / 28,
                      backgroundColor: const Color(0xFFFDF2F8),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFEC4899)),
                      minHeight: 8,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _moodMetricCard({
    required String emoji,
    required String label,
    required String value,
    required String unit,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF64748B))),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: color)),
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(unit,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF94A3B8))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _moodLabel(String emoji) {
    const map = {
      '😊': 'Happy',
      '😐': 'Neutral',
      '😔': 'Sad',
      '😡': 'Angry',
      '😴': 'Tired',
      '🤒': 'Unwell',
    };
    return map[emoji] ?? 'Unknown';
  }

  Color _stressColor(int level) {
    const colors = [
      Color(0xFF10B981),
      Color(0xFF84CC16),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF991B1B),
    ];
    return colors[(level - 1).clamp(0, 4)];
  }

  String _getCyclePhase(int day) {
    if (day <= 5) return 'Menstruation';
    if (day <= 13) return 'Follicular';
    if (day <= 16) return 'Ovulation';
    if (day <= 28) return 'Luteal';
    return 'Extended';
  }

  // ── Helpers ─────────────────────────────────────────────────────────────
  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                fontFamily: 'Gilroy-Bold')),
        Text(subtitle,
            style:
                const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Bottom sheet — generic numeric log
// ═══════════════════════════════════════════════════════════════════════════
class _LogBottomSheet extends StatelessWidget {
  const _LogBottomSheet({
    required this.title,
    required this.subtitle,
    required this.unit,
    required this.controller,
    required this.onSave,
    required this.earnPoints,
  });

  final String title;
  final String subtitle;
  final String unit;
  final TextEditingController controller;
  final VoidCallback onSave;
  final int earnPoints;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Log $title',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF64748B))),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
            ],
            autofocus: true,
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.w900),
            decoration: InputDecoration(
              suffixText: unit,
              suffixStyle: const TextStyle(
                  fontSize: 16, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                    color: AppColors.primaryColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text('+$earnPoints points on save',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB45309))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Save Entry',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Bottom sheet — Blood Pressure (two fields)
// ═══════════════════════════════════════════════════════════════════════════
class _BPBottomSheet extends StatelessWidget {
  const _BPBottomSheet({
    required this.sysCtrl,
    required this.diaCtrl,
    required this.onSave,
  });

  final TextEditingController sysCtrl;
  final TextEditingController diaCtrl;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Log Blood Pressure',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          const Text('Enter your systolic and diastolic readings',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _bpField(sysCtrl, 'Systolic', 'mmHg', context),
              ),
              const SizedBox(width: 12),
              const Text('/',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFFCBD5E1))),
              const SizedBox(width: 12),
              Expanded(
                child: _bpField(diaCtrl, 'Diastolic', 'mmHg', context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('⭐', style: TextStyle(fontSize: 14)),
                SizedBox(width: 6),
                Text('+5 points on save',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB45309))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Save Entry',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bpField(TextEditingController ctrl, String label, String unit,
      BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
        suffixStyle:
            const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: AppColors.primaryColor, width: 2),
        ),
      ),
    );
  }
}

// ── Simple data classes ──────────────────────────────────────────────────
class _TabMeta {
  final String label;
  final IconData icon;
  const _TabMeta(this.label, this.icon);
}

class _MedItem {
  final String name;
  final String schedule;
  bool taken;
  _MedItem(this.name, this.schedule, this.taken);
}

class _CondItem {
  final String emoji;
  final String title;
  final String subtitle;
  bool checked;
  _CondItem(this.emoji, this.title, this.subtitle, this.checked);
}
