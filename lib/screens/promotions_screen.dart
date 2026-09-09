import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:icare/services/api_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/drag_scroll.dart';

/// Promotions & Offers.
///
/// Settings has carried a "Promotions & Offers" notification switch since
/// launch, but nothing could ever trigger it — there was no promotion type and
/// no way to send one, so the client's question ("iski functionality kya hai?")
/// had no good answer. This is the page those offers land on; an admin sends
/// them through POST /api/notifications/promotions, and only users who left
/// that switch on receive them.
class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _items = [];
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
      final res = await _api.get('/notifications/promotions');
      if (!mounted) return;
      setState(() {
        _items = res.data['promotions'] ?? [];
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load offers. Please try again.';
        _loading = false;
      });
    }
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
          'Promotions & Offers',
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
            child: _items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 64),
                    child: Column(
                      children: [
                        Icon(Icons.local_offer_outlined,
                            size: 48, color: Color(0xFFCBD5E1)),
                        SizedBox(height: 12),
                        Text(
                          'No offers right now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'New promotions and discounts will appear here.\n'
                          'You can turn these off in Settings > Notifications.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _items.map(_card).toList(),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _card(dynamic item) {
    final title = (item['title'] ?? 'Offer').toString();
    final message = (item['message'] ?? '').toString();
    final when = DateTime.tryParse(item['createdAt']?.toString() ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.local_offer_rounded,
                color: AppColors.primaryColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF475569),
                      height: 1.4,
                    ),
                  ),
                ],
                if (when != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('MMM d, yyyy').format(when),
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
