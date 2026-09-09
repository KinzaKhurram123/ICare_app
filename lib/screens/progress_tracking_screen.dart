import 'package:flutter/material.dart';
import 'package:icare/services/course_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/drag_scroll.dart';

/// Course-completion overview across every enrolled course.
///
/// Settings > Progress Tracking used to push the whole StudentLmsDashboard,
/// which is why the client asked "Progress Tracking par iCare Academy kyun khul
/// raha hai? Yeh to phir poora course khul raha hai." This is the page that was
/// missing: one row per course with its own percentage, plus an overall figure.
class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({super.key});

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> {
  final CourseService _courseService = CourseService();
  List<dynamic> _enrollments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _courseService.myPurchases();
      if (!mounted) return;
      setState(() {
        _enrollments = data.where((e) => e['course'] != null).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load your progress. Please try again.';
        _loading = false;
      });
    }
  }

  /// Enrollments report progress either as a bare number or as {percent: n},
  /// depending on which endpoint filled them in — handle both.
  double _progressOf(dynamic item) {
    final p = item['progress'];
    if (p is num) return p.toDouble().clamp(0, 100);
    if (p is Map) return ((p['percent'] ?? 0) as num).toDouble().clamp(0, 100);
    return 0;
  }

  String _titleOf(dynamic item) {
    final c = item['course'];
    final t = (c is Map ? (c['title'] ?? c['name']) : null)?.toString().trim();
    return (t == null || t.isEmpty) ? 'Untitled course' : t;
  }

  double get _overall {
    if (_enrollments.isEmpty) return 0;
    final total = _enrollments.fold<double>(0, (sum, e) => sum + _progressOf(e));
    return total / _enrollments.length;
  }

  Color _colorFor(double pct) {
    if (pct >= 100) return const Color(0xFF10B981);
    if (pct >= 50) return AppColors.primaryColor;
    return const Color(0xFFF59E0B);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: const Text(
          'Progress Tracking',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(onRefresh: _load, child: _body()),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 44, color: Color(0xFF94A3B8)),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return DragScroll(
      builder: (context, controller) => SingleChildScrollView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_enrollments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 64),
                    child: Center(
                      child: Text(
                        'You have not enrolled in any course yet.',
                        style: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                    ),
                  )
                else ...[
                  _overallCard(),
                  const SizedBox(height: 16),
                  ..._enrollments.map(_courseRow),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _overallCard() {
    final pct = _overall;
    final completed =
        _enrollments.where((e) => _progressOf(e) >= 100).length;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: pct / 100,
                    strokeWidth: 7,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor:
                        AlwaysStoppedAnimation(_colorFor(pct)),
                  ),
                ),
                Text(
                  '${pct.round()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completed of ${_enrollments.length} '
                  '${_enrollments.length == 1 ? 'course' : 'courses'} completed',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _courseRow(dynamic item) {
    final pct = _progressOf(item);
    final color = _colorFor(pct);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _titleOf(item),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${pct.round()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          if (pct >= 100) ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    size: 15, color: Color(0xFF10B981)),
                SizedBox(width: 6),
                Text(
                  'Completed',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
