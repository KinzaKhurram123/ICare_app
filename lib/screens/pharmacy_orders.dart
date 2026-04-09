import 'package:flutter/material.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/services/pharmacy_service.dart';
import 'package:icare/utils/utils.dart';
import 'package:intl/intl.dart';

class PharmacyOrders extends StatefulWidget {
  const PharmacyOrders({super.key});

  @override
  State<PharmacyOrders> createState() => _PharmacyOrdersState();
}

class _PharmacyOrdersState extends State<PharmacyOrders>
    with SingleTickerProviderStateMixin {
  final PharmacyService _pharmacyService = PharmacyService();
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _loadOrders();
    }
  }

  Future<void> _loadOrders() async {
    try {
      setState(() => _isLoading = true);
      final status = _getCurrentStatus();
      final orders = await _pharmacyService.getPharmacyOrders(status: status);
      setState(() {
        _orders = orders.map((o) {
          final user = o['user'] as Map<String, dynamic>?;
          return {
            '_id': o['_id'],
            'id': o['orderNumber'] ?? '#${o['_id'].toString().substring(0, 8)}',
            'customerName': user?['name'] ?? 'Guest Customer',
            'customerPhone': user?['phoneNumber'] ?? 'N/A',
            'items': (o['items'] as List?)?.length ?? 0,
            'total': (o['totalAmount'] ?? 0).toDouble(),
            'status': o['status'] ?? 'pending',
            'date': o['createdAt'] != null
                ? DateTime.parse(o['createdAt'])
                : DateTime.now(),
            'medicines':
                (o['items'] as List?)
                    ?.map((item) => item['productName'] ?? 'Unknown')
                    .toList() ??
                [],
            'prescriptionText': o['prescriptionText'],
            'medicalRecord': o['medicalRecord'],
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to load orders. Please try again.')),
        );
      }
    }
  }

  String _getCurrentStatus() {
    switch (_tabController.index) {
      case 0:
        return 'all';
      case 1:
        return 'pending';
      case 2:
        return 'processing';
      case 3:
        return 'completed';
      default:
        return 'all';
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _pharmacyService.updateOrderStatus(orderId, newStatus);
      await _loadOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status updated to $newStatus')),
        );
      }
    } catch (e) {
      if (mounted) {
        Utils.showErrorSnackBar(context, e);
      }
    }
  }

  List<Map<String, dynamic>> _getOrdersByStatus(String status) {
    return _orders;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: const Text(
          'Dispense Requests',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Gilroy-Bold',
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: AppColors.primaryColor,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Awaiting Fulfillment'),
            Tab(text: 'Processing'),
            Tab(text: 'Dispensed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(_getOrdersByStatus('all'), isDesktop),
          _buildOrdersList(_getOrdersByStatus('pending'), isDesktop),
          _buildOrdersList(_getOrdersByStatus('processing'), isDesktop),
          _buildOrdersList(_getOrdersByStatus('completed'), isDesktop),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Map<String, dynamic>> orders, bool isDesktop) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'No orders found',
              style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isDesktop ? 40 : 20),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(orders[index]);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final statusColor = _getStatusColor(status);
    final date = order['date'] as DateTime;
    final isDoctorReferred = order['medicalRecord'] != null;
    final hasPrescriptionText =
        order['prescriptionText'] != null &&
        order['prescriptionText'].toString().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDoctorReferred
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : statusColor.withValues(alpha: 0.2),
          width: isDoctorReferred ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor-referred badge
                if (isDoctorReferred)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.medical_services_rounded,
                          size: 14,
                          color: Color(0xFF10B981),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Doctor Prescribed',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.shopping_bag_rounded,
                        color: statusColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order['id'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order['customerName'],
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show prescription text if doctor-referred
                if (hasPrescriptionText) ...[
                  const Text(
                    'Prescription:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      order['prescriptionText'],
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const Text(
                  'Items:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                ...(order['medicines'] as List).map((medicine) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          medicine,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (order['prescriptionText'] != null &&
                    (order['prescriptionText'] as String).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.description_rounded,
                              color: Color(0xFF166534),
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'CLINICAL PRESCRIPTION',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF166534),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          order['prescriptionText'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF064E3B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (order['medicalRecord'] != null) ...[
                          const Divider(height: 16, color: Color(0xFFBBF7D0)),
                          Text(
                            "Diagnosis: ${order['medicalRecord']['diagnosis'] ?? 'N/A'}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          '\$${order['total']}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Order Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd, HH:mm').format(date),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (status == 'pending') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _updateOrderStatus(order['_id'], 'cancelled'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFEF4444)),
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _updateOrderStatus(order['_id'], 'confirmed'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                          ),
                          child: const Text('Accept'),
                        ),
                      ),
                    ],
                  ),
                ] else if (status == 'confirmed') ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        _updateOrderStatus(order['_id'], 'preparing'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                    ),
                    child: const Text('Start Preparing'),
                  ),
                ] else if (status == 'preparing') ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        _updateOrderStatus(order['_id'], 'out_for_delivery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                    ),
                    child: const Text('Out for Delivery'),
                  ),
                ] else if (status == 'out_for_delivery') ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        _updateOrderStatus(order['_id'], 'completed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                    ),
                    child: const Text('Mark as Completed'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'processing':
        return const Color(0xFF3B82F6);
      case 'completed':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }
}
