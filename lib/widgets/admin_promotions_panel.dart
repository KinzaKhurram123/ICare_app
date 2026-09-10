import 'package:flutter/material.dart';
import 'package:icare/services/api_service.dart';
import 'package:icare/widgets/drag_scroll.dart';

/// Send a Promotions & Offers broadcast.
///
/// Users have had a "Promotions & Offers" notification switch in Settings since
/// launch with nothing behind it — the client asked what its functionality was,
/// and the honest answer was "none". POST /api/notifications/promotions is the
/// missing half; this is the screen an admin actually uses. Only users who left
/// that switch ON receive it, which is what the switch is for.
class AdminPromotionsPanel extends StatefulWidget {
  final ApiService api;
  const AdminPromotionsPanel({super.key, required this.api});

  @override
  State<AdminPromotionsPanel> createState() => _AdminPromotionsPanelState();
}

class _AdminPromotionsPanelState extends State<AdminPromotionsPanel> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _linkController = TextEditingController();

  /// Empty means every role that has promotions enabled.
  final Set<String> _roles = {};
  bool _sending = false;
  String? _lastResult;

  static const _allRoles = [
    'student',
    'patient',
    'doctor',
    'instructor',
    'pharmacy',
    'laboratory',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    if (title.isEmpty || message.isEmpty) {
      _toast('Title and message are both required', isError: true);
      return;
    }

    // Sending is not undoable — it lands in every matching user's
    // notifications immediately — so confirm the audience first.
    final who = _roles.isEmpty
        ? 'ALL roles'
        : _roles.map((r) => r[0].toUpperCase() + r.substring(1)).join(', ');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send this offer?'),
        content: Text(
          'It will go to $who — and only to users who have Promotions & Offers '
          'switched on. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Send'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _sending = true);
    try {
      final res = await widget.api.post('/notifications/promotions', {
        'title': title,
        'message': message,
        if (_linkController.text.trim().isNotEmpty)
          'link': _linkController.text.trim(),
        if (_roles.isNotEmpty) 'roles': _roles.toList(),
      });
      if (!mounted) return;
      if (res.data['success'] == true) {
        final sent = res.data['sent'] ?? 0;
        _titleController.clear();
        _messageController.clear();
        _linkController.clear();
        setState(() => _lastResult = 'Sent to $sent user(s)');
        _toast(
          sent == 0
              ? 'Nobody has Promotions & Offers switched on yet'
              : 'Offer sent to $sent user(s)',
        );
      } else {
        _toast(
          res.data['message']?.toString() ?? 'Could not send',
          isError: true,
        );
      }
    } catch (_) {
      if (mounted) _toast('Could not send the offer', isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _toast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            isError ? Colors.red.shade600 : const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DragScroll(
      builder: (context, controller) => SingleChildScrollView(
        controller: controller,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Send a Promotion or Offer',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'This appears under Promotions & Offers for the people you '
                  'pick, and only for those who left that notification '
                  'preference switched on.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _titleController,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    hintText: 'e.g. 20% off all courses this week',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _messageController,
                  maxLength: 400,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Message *',
                    hintText: 'What the offer is, and until when.',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _linkController,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    labelText: 'Link (optional)',
                    hintText: 'Where the offer should take them',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Send to',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Everyone'),
                      selected: _roles.isEmpty,
                      onSelected: (_) => setState(_roles.clear),
                    ),
                    ..._allRoles.map(
                      (r) => FilterChip(
                        label: Text(r[0].toUpperCase() + r.substring(1)),
                        selected: _roles.contains(r),
                        onSelected: (sel) => setState(() {
                          if (sel) {
                            _roles.add(r);
                          } else {
                            _roles.remove(r);
                          }
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.campaign_rounded),
                    label: Text(_sending ? 'Sending...' : 'Send Offer'),
                  ),
                ),
                if (_lastResult != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF10B981),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _lastResult!,
                          style: const TextStyle(
                            color: Color(0xFF047857),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
