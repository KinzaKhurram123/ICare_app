import 'package:flutter/foundation.dart';
import 'package:icare/services/api_service.dart';

class PharmacyService {
  final ApiService _apiService = ApiService();
  String? _cachedPharmacyId;

  // Get all pharmacies (public endpoint)
  Future<List<dynamic>> getAllPharmacies() async {
    final response = await _apiService.get('/pharmacy/get_all_pharmacy');
    return response.data['pharmacies'] as List;
  }

  // Get pharmacy profile for logged-in pharmacist
  Future<Map<String, dynamic>> getPharmacyProfile() async {
    final response = await _apiService.get('/pharmacy/profile');
    final pharmacy = response.data['pharmacy'];
    _cachedPharmacyId = pharmacy['_id'];
    return pharmacy;
  }

  // Update pharmacy profile
  Future<Map<String, dynamic>> updatePharmacyProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.post(
        '/pharmacy/add_pharmacy_details',
        data,
      );
      return response.data['pharmacy'] ?? response.data['existingProfile'];
    } catch (e) {
      debugPrint('Error updating pharmacy profile: $e');
      rethrow;
    }
  }

  Future<String> _getPharmacyId() async {
    try {
      if (_cachedPharmacyId != null) {
        debugPrint('✅ Using cached pharmacy ID: $_cachedPharmacyId');
        return _cachedPharmacyId!;
      }
      debugPrint('🔍 Fetching pharmacy profile from: /pharmacy/profile');
      final profile = await getPharmacyProfile();
      debugPrint('✅ Got pharmacy profile, ID: ${profile['_id']}');
      return profile['_id'];
    } catch (e) {
      debugPrint('❌ Error getting pharmacy ID: $e');
      rethrow;
    }
  }

  // Get pharmacy statistics
  Future<Map<String, dynamic>> getPharmacyStats() async {
    try {
      debugPrint('📊 Getting pharmacy stats...');
      final pharmacyId = await _getPharmacyId();
      debugPrint('✅ Pharmacy ID: $pharmacyId');

      // Get all orders for the pharmacy
      debugPrint('📦 Fetching orders from: /pharmacy/orders/pharmacy/list');
      final ordersResponse = await _apiService.get(
        '/pharmacy/orders/pharmacy/list',
      );
      final orders = ordersResponse.data['orders'] as List;
      debugPrint('✅ Got ${orders.length} orders');

      // Get all medicines for the pharmacy
      debugPrint(
        '💊 Fetching medicines from: /pharmacy/products?pharmacyId=$pharmacyId',
      );
      final medicinesResponse = await _apiService.get(
        '/pharmacy/products?pharmacyId=$pharmacyId',
      );
      final medicines = medicinesResponse.data['medicines'] as List;
      debugPrint('✅ Got ${medicines.length} medicines');

      // Calculate stats
      final totalOrders = orders.length;
      final pendingOrders = orders
          .where((o) => o['status'] == 'pending')
          .length;
      final completedOrders = orders
          .where((o) => o['status'] == 'completed')
          .length;
      final totalProducts = medicines.length;
      final lowStock = medicines.where((m) => (m['quantity'] ?? 0) < 30).length;

      // Calculate revenue from completed orders
      final revenue = orders
          .where((o) => o['status'] == 'completed')
          .fold<double>(
            0,
            (sum, o) => sum + (o['totalAmount'] ?? 0).toDouble(),
          );

      return {
        'totalOrders': totalOrders,
        'pendingOrders': pendingOrders,
        'completedOrders': completedOrders,
        'totalProducts': totalProducts,
        'lowStock': lowStock,
        'revenue': revenue.toInt(),
      };
    } catch (e) {
      debugPrint('Error getting pharmacy stats: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getMedicines({String? category, String? search}) async {
    final pharmacyId = await _getPharmacyId();
    return getMedicinesByPharmacyId(
      pharmacyId,
      category: category,
      search: search,
    );
  }

  Future<List<dynamic>> getMedicinesByPharmacyId(
    String pharmacyId, {
    String? category,
    String? search,
  }) async {
    String url = '/pharmacy/products?pharmacyId=$pharmacyId';
    if (category != null && category != 'All')
      url += '&category=${Uri.encodeComponent(category)}';
    if (search != null && search.isNotEmpty)
      url += '&q=${Uri.encodeComponent(search)}';
    final response = await _apiService.get(url);
    return response.data['medicines'] as List;
  }

  Future<Map<String, dynamic>> createMedicine(Map<String, dynamic> data) async {
    final response = await _apiService.post('/pharmacy/products', data);
    return response.data['medicine'];
  }

  Future<Map<String, dynamic>> updateMedicine(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.put('/pharmacy/products/$id', data);
    return response.data['medicine'];
  }

  Future<void> deleteMedicine(String id) async {
    await _apiService.delete('/pharmacy/products/$id');
  }

  // Order Management
  Future<List<dynamic>> getPharmacyOrders({String? status}) async {
    String url = '/pharmacy/orders/pharmacy/list';
    if (status != null && status != 'all') {
      url += '?status=$status';
    }
    final response = await _apiService.get(url);
    return response.data['orders'] as List;
  }

  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    final response = await _apiService.get('/pharmacy/orders/$orderId');
    return response.data['order'];
  }

  Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    final response = await _apiService.put('/pharmacy/orders/$orderId/status', {
      'status': status,
    });
    return response.data['order'];
  }

  // Analytics
  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final pharmacyId = await _getPharmacyId();

      final ordersResponse = await _apiService.get(
        '/pharmacy/orders/pharmacy/list',
      );
      final orders = ordersResponse.data['orders'] as List;

      final medicinesResponse = await _apiService.get(
        '/pharmacy/products?pharmacyId=$pharmacyId',
      );
      final medicines = medicinesResponse.data['medicines'] as List;

      // Calculate total revenue
      final totalRevenue = orders
          .where((o) => o['status'] == 'completed')
          .fold<double>(
            0,
            (sum, o) => sum + (o['totalAmount'] ?? 0).toDouble(),
          );

      final totalOrders = orders.length;
      final averageOrderValue = totalOrders > 0
          ? totalRevenue / totalOrders
          : 0;

      // Get real top selling products from backend
      List<dynamic> topSellingProducts = [];
      try {
        final topSellingResponse = await _apiService.get(
          '/pharmacy/top-selling',
        );
        topSellingProducts = topSellingResponse.data['topProducts'] ?? [];
      } catch (e) {
        debugPrint('Error getting top selling products: $e');
        // Fallback to empty list if endpoint fails
        topSellingProducts = [];
      }

      return {
        'totalRevenue': totalRevenue.toInt(),
        'totalOrders': totalOrders,
        'averageOrderValue': averageOrderValue,
        'topSellingProducts': topSellingProducts,
      };
    } catch (e) {
      debugPrint('Error getting analytics: $e');
      rethrow;
    }
  }
}
