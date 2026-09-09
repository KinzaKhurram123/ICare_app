import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:icare/screens/chat_screen.dart';
import 'package:icare/navigators/deferred_route.dart';
import 'package:icare/screens/classroom_course_view.dart'
    deferred as classroom_view;
import 'package:icare/screens/instructor_grading_screen.dart'
    deferred as i_grading;
import 'package:icare/screens/doctor_appointments.dart';
import 'package:icare/services/notification_service.dart';
import 'package:icare/services/lms_service.dart';
import 'package:icare/utils/shared_pref.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:intl/intl.dart';

class DoctorNotifications extends StatefulWidget {
  const DoctorNotifications({super.key});

  @override
  State<DoctorNotifications> createState() => _DoctorNotificationsState();
}

class _DoctorNotificationsState extends State<DoctorNotifications> {
  final NotificationService _notificationService = NotificationService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String _filter = 'all'; // 'all' | 'unread' | 'read'

  // Ids that were unread when this screen opened. Opening the screen marks
  // everything read - the client's point was that having to press "Mark all as
  // read" is busywork ("jab khul gaya to uska matlab hai READ hai") and that
  // the count kept sticking around. But the highlight is still useful, so what
  // was new stays visually marked for this visit while the count goes to zero.
  final Set<String> _newOnOpen = {};
  bool _markedOnOpen = false;

  /// True while this visit should still show the item as new.
  bool _isNew(Map<String, dynamic> n) =>
      _newOnOpen.contains(n['id']?.toString());

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_filter == 'all') return _notifications;
    if (_filter == 'unread') return _notifications.where(_isNew).toList();
    return _notifications.where((n) => !_isNew(n)).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    final result = await _notificationService.getNotifications();

    if (result['success'] && mounted) {
      final notifications = result['notifications'] ?? [];
      setState(() {
        _notifications = List<Map<String, dynamic>>.from(
          notifications.map(
            (n) => {
              'id': n['_id'],
              'type': n['type'],
              'title': n['title'],
              'message': n['message'],
              'time': DateTime.parse(n['createdAt']),
              'read': n['read'],
              'data': n['data'],
              'icon': _getIconForType(n['type']),
              'color': _getColorForType(n['type']),
            },
          ),
        );
        _isLoading = false;
      });
      _clearUnreadOnFirstOpen();
    } else {
      // If failed or empty, set empty list
      setState(() {
        _notifications = [];
        _isLoading = false;
      });
    }
  }

  /// Opening the list counts as reading it, so the badge must not survive the
  /// visit. Runs once per screen instance; the ids seen as unread are kept in
  /// [_newOnOpen] so they still render highlighted while the count reads zero.
  void _clearUnreadOnFirstOpen() {
    if (_markedOnOpen) return;
    _markedOnOpen = true;

    final unread = _notifications
        .where((n) => n['read'] != true)
        .map((n) => n['id']?.toString())
        .whereType<String>()
        .toSet();
    if (unread.isEmpty) return;

    setState(() {
      _newOnOpen.addAll(unread);
      for (final n in _notifications) {
        n['read'] = true;
      }
    });
    // Fire-and-forget: the count is already zero on screen, and a failed call
    // simply means the server still has them unread for the next visit.
    _notificationService.markAllAsRead();
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'appointment':
        return Icons.calendar_month_rounded;
      case 'cancellation':
        return Icons.cancel_rounded;
      case 'reminder':
        return Icons.alarm_rounded;
      case 'review':
        return Icons.star_rounded;
      case 'progress':
        return Icons.trending_up_rounded;
      case 'completion':
        return Icons.task_alt_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'appointment':
        return const Color(0xFF3B82F6);
      case 'cancellation':
        return const Color(0xFFEF4444);
      case 'reminder':
        return const Color(0xFFF59E0B);
      case 'review':
        return const Color(0xFF10B981);
      case 'progress':
        return const Color(0xFF8B5CF6);
      case 'completion':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF64748B);
    }
  }

  /// Navigate to the item a notification refers to (assignments, courses,
  /// appointments) so the user can act on it directly.
  Future<void> _openNotificationTarget(
    Map<String, dynamic> notification,
  ) async {
    final rawData = notification['data'];
    final type = notification['type']?.toString() ?? '';

    // Appointment-type notifications → appointments screen
    if (type == 'appointment' || type == 'cancellation') {
      final user = await SharedPref().getUserData();
      if (!mounted) return;
      if ((user?.role ?? '').toLowerCase() == 'doctor') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DoctorAppointmentsScreen()),
        );
        return;
      }
    }

    if (rawData is! Map) return;
    final data = Map<String, dynamic>.from(rawData);
    final dType = data['type']?.toString() ?? '';
    final courseId = data['courseId']?.toString() ?? '';

    try {
      // Instructor: student submitted an assignment → open grading screen
      if (dType == 'assignment_submission_received') {
        final assignmentId = data['assignmentId']?.toString() ?? '';
        if (assignmentId.isNotEmpty && mounted) {
          // Extract assignment title from message: ... submitted "title" ...
          final msg = notification['message']?.toString() ?? '';
          final m = RegExp(r'"([^"]+)"').firstMatch(msg);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DeferredScreen(
                loader: i_grading.loadLibrary,
                builder: () => i_grading.InstructorGradingScreen(
                  assignmentId: assignmentId,
                  assignmentTitle: m?.group(1) ?? 'Assignment',
                ),
              ),
            ),
          );
          return;
        }
      }

      // Other LMS notifications with a courseId → open course classroom
      if (courseId.isNotEmpty) {
        final res = await LmsService().getCourseDetails(courseId);
        final course = (res['course'] is Map)
            ? Map<String, dynamic>.from(res['course'] as Map)
            : (res['data'] is Map
                  ? Map<String, dynamic>.from(res['data'] as Map)
                  : <String, dynamic>{});
        if (course.isEmpty || !mounted) return;
        final user = await SharedPref().getUserData();
        final isInstructor = (user?.role ?? '').toLowerCase() == 'instructor';
        if (!mounted) return;
        final isClasswork =
            dType.contains('assignment') || dType.contains('quiz');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DeferredScreen(
              loader: classroom_view.loadLibrary,
              builder: () => classroom_view.ClassroomCourseView(
                course: course,
                isInstructor: isInstructor,
                initialTab: isClasswork ? 1 : 0,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Notification navigation error: $e');
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await _notificationService.markAsRead(id);
      setState(() {
        final notification = _notifications.firstWhere((n) => n['id'] == id);
        notification['read'] = true;
      });
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;
    // Deliberately the stored read flag, not _isNew: opening the screen is
    // reading it, so the count goes to zero immediately. _isNew only keeps the
    // highlight and the Unread filter meaningful for the rest of the visit.
    final unreadCount = _notifications.where((n) => n['read'] != true).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Gilroy-Bold',
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          // "Mark all read" removed - opening the screen already marks
          // everything read, so the button had nothing left to do.
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 40 : 20),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 800 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (unreadCount > 0) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.notifications_active_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'You have $unreadCount unread notification${unreadCount > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (_notifications.isNotEmpty) ...[
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // All / Unread / Read only. The type chips
                              // (Appointments, Reminders, Reviews, General)
                              // were removed at the client's request: "General
                              // aur All ek hi cheez hai... ya All karte hain,
                              // Unread karte hain, aur Read karte hain - BAS."
                              _buildFilterChip('all', 'All'),
                              const SizedBox(width: 8),
                              _buildFilterChip('unread', 'Unread'),
                              const SizedBox(width: 8),
                              _buildFilterChip('read', 'Read'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (_notifications.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(48),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.notifications_off_rounded,
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No notifications yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'You\'ll see notifications here when you have updates',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (_filteredNotifications.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text(
                              'No notifications match this filter',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      else
                        ..._filteredNotifications.asMap().entries.map(
                          (entry) => _buildNotificationCard(
                            entry.value,
                            entry.key + 1,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF6366F1) : const Color(0xFF64748B),
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 13,
      ),
      side: BorderSide(
        color: selected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int number) {
    // _isNew, not the stored flag: opening the screen marks everything read so
    // the count clears, but what arrived since the last visit should still look
    // new for this visit.
    final isRead = !_isNew(notification);
    final color = notification['color'] as Color;
    final time = notification['time'] as DateTime;
    final timeAgo = _getTimeAgo(time);

    return InkWell(
      onTap: () async {
        await _markAsRead(notification['id']);
        // Navigate to chat if it's a message notification
        if (notification['title'] == 'New Message' &&
            notification['data'] != null) {
          final data = notification['data'] as Map<String, dynamic>;
          final senderId = data['senderId']?.toString() ?? '';
          final senderName = data['senderName']?.toString() ?? 'User';
          if (senderId.isNotEmpty && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ChatScreen(userId: senderId, userName: senderName),
              ),
            );
          }
          return;
        }
        await _openNotificationTarget(notification);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead
                ? const Color(0xFFE2E8F0)
                : color.withValues(alpha: 0.2),
            width: isRead ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(notification['icon'], color: color, size: 24),
                ),
                Positioned(
                  top: -6,
                  left: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification['title'],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isRead
                                ? FontWeight.w700
                                : FontWeight.w900,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['message'],
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(time);
    }
  }
}
