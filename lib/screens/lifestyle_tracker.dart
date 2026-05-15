import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/screens/my_learning.dart';
import 'package:icare/services/lifestyle_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Vitals config ────────────────────────────────────────────────────────────
const _vitals = [
  {'id': 'bp',          'name': 'Blood Pressure',  'unit': 'mmHg', 'hint': '120/80', 'icon': Icons.favorite_rounded,             'color': 0xFFEF4444},
  {'id': 'sugar',       'name': 'Blood Sugar',      'unit': 'mg/dL','hint': '100',    'icon': Icons.bloodtype_rounded,            'color': 0xFFF59E0B},
  {'id': 'weight',      'name': 'Weight',           'unit': 'kg',   'hint': '70',     'icon': Icons.monitor_weight_rounded,       'color': 0xFF8B5CF6},
  {'id': 'heart_rate',  'name': 'Heart Rate',       'unit': 'bpm',  'hint': '72',     'icon': Icons.show_chart_rounded,           'color': 0xFFEC4899},
  {'id': 'spo2',        'name': 'SpO2',             'unit': '%',    'hint': '98',     'icon': Icons.air_rounded,                  'color': 0xFF3B82F6},
  {'id': 'temperature', 'name': 'Temperature',      'unit': '°C',   'hint': '37.0',   'icon': Icons.thermostat_rounded,           'color': 0xFFFF6B35},
  {'id': 'steps',       'name': 'Steps',            'unit': 'steps','hint': '5000',   'icon': Icons.directions_walk_rounded,      'color': 0xFF10B981},
  {'id': 'calories',    'name': 'Calories',         'unit': 'kcal', 'hint': '500',    'icon': Icons.local_fire_department_rounded,'color': 0xFFF97316},
];

class LifestyleTrackerScreen extends StatefulWidget {
  const LifestyleTrackerScreen({super.key});
  @override
  State<LifestyleTrackerScreen> createState() => _LifestyleTrackerScreenState();
}

class _LifestyleTrackerScreenState extends State<LifestyleTrackerScreen> {
  double _waterIntake = 0;
  double _sleepHours = 0;
  int _steps = 0;
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _vitalLogs = [];
  String _logFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadLogs();
  }

  // ── Persistence ────────────────────────────────────────────────────────────

  Future<void> _loadLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('vitals_logs');
      if (raw != null && mounted) {
        final decoded = jsonDecode(raw) as List;
        setState(() => _vitalLogs = decoded.cast<Map<String, dynamic>>());
      }
    } catch (_) {}
  }

  Future<void> _saveLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('vitals_logs', jsonEncode(_vitalLogs));
    } catch (_) {}
  }

  // ── Lifestyle data ─────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final response = await LifestyleService.getTodayData();
      final data = response['data'];
      if (mounted) {
        setState(() {
          _waterIntake = (data['waterIntake'] ?? 0).toDouble();
          _sleepHours = (data['sleepHours'] ?? 0).toDouble();
          _steps = data['steps'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _updateData({double? water, double? sleep, int? steps}) async {
    try {
      await LifestyleService.updateData(waterIntake: water, sleepHours: sleep, steps: steps);
      if (water != null) setState(() => _waterIntake = water);
      if (sleep != null) setState(() => _sleepHours = sleep);
      if (steps != null) setState(() => _steps = steps);
    } catch (_) {}
  }

  // ── Goal period labels ─────────────────────────────────────────────────────

  String _weekLabel() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return '${DateFormat('dd MMM').format(monday)} – ${DateFormat('dd MMM').format(sunday)}';
  }

  String _monthLabel() => DateFormat('MMMM yyyy').format(DateTime.now());

  // ── Log More ───────────────────────────────────────────────────────────────

  void _showLogMore() {
    final searchCtrl = TextEditingController();
    List<Map<String, dynamic>> filtered = List.from(_vitals);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModal) {
          return DraggableScrollableSheet(
            initialChildSize: 0.75,
            maxChildSize: 0.95,
            minChildSize: 0.4,
            builder: (_, scroll) => Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Log a Vital', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                        const SizedBox(height: 12),
                        TextField(
                          controller: searchCtrl,
                          decoration: InputDecoration(
                            hintText: 'Search vitals...',
                            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onChanged: (q) {
                            setModal(() {
                              filtered = (_vitals as List).cast<Map<String, dynamic>>()
                                  .where((v) => (v['name'] as String).toLowerCase().contains(q.toLowerCase()))
                                  .toList();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      controller: scroll,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final v = filtered[i];
                        final color = Color(v['color'] as int);
                        return InkWell(
                          onTap: () {
                            Navigator.pop(ctx);
                            _showLogEntry(v);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                                  child: Icon(v['icon'] as IconData, color: color, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(v['name'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                                      Text('e.g. ${v['hint']} ${v['unit']}', style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showLogEntry(Map<String, dynamic> vital) {
    final valueCtrl = TextEditingController();
    final now = DateTime.now();
    final timeLabel = DateFormat('dd MMM yyyy, hh:mm a').format(now);
    final color = Color(vital['color'] as int);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(vital['icon'] as IconData, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(vital['name'] as String, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Enter value in ${vital['unit']}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            TextField(
              controller: valueCtrl,
              autofocus: true,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: vital['hint'] as String,
                suffixText: vital['unit'] as String,
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: color, width: 1.5)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Text(timeLabel, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = valueCtrl.text.trim();
              if (val.isEmpty) return;
              Navigator.pop(ctx);
              setState(() {
                _vitalLogs.insert(0, {
                  'type': vital['id'],
                  'name': vital['name'],
                  'value': val,
                  'unit': vital['unit'],
                  'ts': now.toIso8601String(),
                  'color': vital['color'],
                  'icon': null,
                });
              });
              _saveLogs();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${vital['name']} logged at ${DateFormat('hh:mm a').format(now)}'),
                backgroundColor: color,
                duration: const Duration(seconds: 2),
              ));
            },
            style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── My Logs ────────────────────────────────────────────────────────────────

  void _showMyLogs() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModal) {
        // Filtered logs
        final logs = _logFilter == 'all'
            ? _vitalLogs
            : _vitalLogs.where((l) => l['type'] == _logFilter).toList();

        // Group by date
        final Map<String, List<Map<String, dynamic>>> grouped = {};
        for (final log in logs) {
          try {
            final dt = DateTime.parse(log['ts'] as String);
            final now = DateTime.now();
            String label;
            if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
              label = 'Today — ${DateFormat('dd MMM yyyy').format(dt)}';
            } else if (dt.year == now.year && dt.month == now.month && dt.day == now.day - 1) {
              label = 'Yesterday — ${DateFormat('dd MMM yyyy').format(dt)}';
            } else {
              label = DateFormat('EEEE — dd MMM yyyy').format(dt);
            }
            grouped.putIfAbsent(label, () => []).add(log);
          } catch (_) {}
        }
        final dateKeys = grouped.keys.toList();

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (_, scroll) => Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                  child: Row(
                    children: [
                      const Text('My Logs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                      const Spacer(),
                      if (_vitalLogs.isNotEmpty)
                        Text('${_vitalLogs.length} entries', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                // Filter chips
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _filterChip('all', 'All', setModal),
                      ..._vitals.map((v) => _filterChip(v['id'] as String, v['name'] as String, setModal)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: logs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history_rounded, size: 56, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              const Text('No logs yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                              const SizedBox(height: 4),
                              const Text('Tap "Log More" to add your first entry.', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scroll,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                          itemCount: dateKeys.length,
                          itemBuilder: (_, gi) {
                            final key = dateKeys[gi];
                            final entries = grouped[key]!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Text(key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                                ),
                                ...entries.map((log) {
                                  final vConfig = (_vitals as List).cast<Map<String, dynamic>>()
                                      .firstWhere((v) => v['id'] == log['type'], orElse: () => {'icon': Icons.circle, 'color': 0xFF64748B});
                                  final color = Color(vConfig['color'] as int);
                                  final dt = DateTime.tryParse(log['ts'] as String ?? '');
                                  final timeStr = dt != null ? DateFormat('hh:mm a').format(dt) : '';
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                          child: Icon(vConfig['icon'] as IconData, color: color, size: 18),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(log['name'] as String? ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                                              Text('${log['value']} ${log['unit']}', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                        Text(timeStr, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _filterChip(String id, String label, StateSetter setModal) {
    final selected = _logFilter == id;
    return GestureDetector(
      onTap: () { setState(() => _logFilter = id); setModal(() {}); },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primaryColor : const Color(0xFFE2E8F0)),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? Colors.white : const Color(0xFF64748B))),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const CustomBackButton(),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Lifestyle Tracker', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800)),
        actions: [
          TextButton.icon(
            onPressed: _showMyLogs,
            icon: const Icon(Icons.history_rounded, size: 18),
            label: const Text('My Logs', style: TextStyle(fontWeight: FontWeight.w700)),
            style: TextButton.styleFrom(foregroundColor: AppColors.primaryColor),
          ),
          IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF0F172A)), onPressed: _loadData),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLogMore,
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log More', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Unable to load data'), const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
            ]))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLmsLinkageCard(context),
                  const SizedBox(height: 24),

                  // ── Activity trackers ───────────────────────────────────
                  const Text('Daily Activities', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  const SizedBox(height: 16),
                  _buildActivityCard('Water Intake', '${_waterIntake.toStringAsFixed(1)} / 3.0 L', _waterIntake / 3.0, Icons.water_drop_rounded, const Color(0xFF3B82F6), () => _updateData(water: _waterIntake + 0.25)),
                  const SizedBox(height: 12),
                  _buildActivityCard('Sleep Duration', '${_sleepHours.toStringAsFixed(1)} / 8.0 hrs', _sleepHours / 8.0, Icons.nights_stay_rounded, const Color(0xFF8B5CF6), () => _updateData(sleep: _sleepHours + 0.5)),
                  const SizedBox(height: 12),
                  _buildActivityCard('Steps', '$_steps / 10,000', _steps / 10000.0, Icons.directions_run_rounded, const Color(0xFF10B981), null),
                  const SizedBox(height: 32),

                  // ── Goals ───────────────────────────────────────────────
                  const Text('Goals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  const SizedBox(height: 16),
                  _buildGoalCard('Daily Goal', 'Today', const Color(0xFF3B82F6), [
                    _goalRow('Water', '${_waterIntake.toStringAsFixed(1)}L', '2.0L', _waterIntake / 2.0),
                    _goalRow('Sleep', '${_sleepHours.toStringAsFixed(1)}h', '8h', _sleepHours / 8.0),
                    _goalRow('Steps', '$_steps', '10,000', _steps / 10000.0),
                  ]),
                  const SizedBox(height: 12),
                  _buildGoalCard('Weekly Goal', _weekLabel(), const Color(0xFF10B981), [
                    _goalRow('Water', '${(_waterIntake * 7).toStringAsFixed(1)}L', '14L', (_waterIntake * 7) / 14.0),
                    _goalRow('Sleep', '${(_sleepHours * 7).toStringAsFixed(1)}h', '56h', (_sleepHours * 7) / 56.0),
                    _goalRow('Steps', '${_steps * 7}', '70,000', (_steps * 7) / 70000.0),
                  ]),
                  const SizedBox(height: 12),
                  _buildGoalCard('Monthly Goal', _monthLabel(), const Color(0xFF7C3AED), [
                    _goalRow('Water', '${(_waterIntake * 30).toStringAsFixed(1)}L', '60L', (_waterIntake * 30) / 60.0),
                    _goalRow('Sleep', '${(_sleepHours * 30).toStringAsFixed(1)}h', '240h', (_sleepHours * 30) / 240.0),
                    _goalRow('Steps', '${_steps * 30}', '300,000', (_steps * 30) / 300000.0),
                  ]),

                  const SizedBox(height: 32),

                  // ── Today's vitals summary ──────────────────────────────
                  if (_todayLogs.isNotEmpty) ...[
                    const Text("Today's Vitals", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    const SizedBox(height: 16),
                    ..._todayLogs.map((log) {
                      final vConfig = (_vitals as List).cast<Map<String, dynamic>>()
                          .firstWhere((v) => v['id'] == log['type'], orElse: () => {'icon': Icons.circle, 'color': 0xFF64748B});
                      final color = Color(vConfig['color'] as int);
                      final dt = DateTime.tryParse(log['ts'] as String? ?? '');
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: Row(
                          children: [
                            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(vConfig['icon'] as IconData, color: color, size: 18)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(log['name'] as String? ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                                Text('${log['value']} ${log['unit']}', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
                              ]),
                            ),
                            if (dt != null) Text(DateFormat('hh:mm a').format(dt), style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
    );
  }

  List<Map<String, dynamic>> get _todayLogs {
    final now = DateTime.now();
    return _vitalLogs.where((log) {
      try {
        final dt = DateTime.parse(log['ts'] as String);
        return dt.year == now.year && dt.month == now.month && dt.day == now.day;
      } catch (_) { return false; }
    }).toList();
  }

  // ── Goal card ──────────────────────────────────────────────────────────────

  Widget _buildGoalCard(String title, String period, Color color, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.flag_rounded, color: color, size: 16)),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)), child: Text(period, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color))),
            ],
          ),
          const SizedBox(height: 14),
          ...rows,
        ],
      ),
    );
  }

  Widget _goalRow(String label, String current, String target, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
              Text('$current / $target', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(progress >= 1.0 ? Colors.green : AppColors.primaryColor),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  // ── Activity card ──────────────────────────────────────────────────────────

  Widget _buildActivityCard(String title, String subtitle, double progress, IconData icon, Color color, VoidCallback? onAdd) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A))),
                  Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF64748B))),
                ]),
              ),
              if (onAdd != null)
                IconButton(onPressed: onAdd, icon: const Icon(Icons.add_circle_rounded), color: color, iconSize: 32),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  // ── LMS card ───────────────────────────────────────────────────────────────

  Widget _buildLmsLinkageCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.school_rounded, color: Colors.white, size: 24)),
            const SizedBox(width: 12),
            const Expanded(child: Text('Care Plan Insights', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))),
          ]),
          const SizedBox(height: 16),
          Text('Based on your active Health Program, your target water intake is extremely vital today. Watch Module 3 to learn more.', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14, height: 1.5)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyLearningScreen())),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF6366F1), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
            child: const Text('Review Health Program', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
