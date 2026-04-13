import 'package:flutter/foundation.dart';
import 'package:icare/services/api_service.dart';

class CartService {
  final ApiService _apiService = ApiService();

  // Get user's cart
  Future<Map<String, dynamic>> getCart() async {
    final response = await _apiService.get('/cart');
    return response.data['cart'];
  }

  // Add item to cart
  Future<Map<String, dynamic>> addItem(String medicineId, int quantity) async {
    final response = await _apiService.post('/cart/items', {
      'medicineId': medicineId,
      'quantity': quantity,
    });
    return response.data['cart'];
  }

  // Update item quantity in cart
  Future<Map<String, dynamic>> updateItem(
    String medicineId,
    int quantity,
  ) async {
    final response = await _apiService.put('/cart/items', {
      'medicineId': medicineId,
      'quantity': quantity,
    });
    return response.data['cart'];
  }

  // Remove item from cart (set quantity to 0)
  Future<Map<String, dynamic>> removeItem(String medicineId) async {
    final response = await _apiService.put('/cart/items', {
      'medicineId': medicineId,
      'quantity': 0,
    });
    return response.data['cart'];
  }

  // Clear entire cart
  Future<void> clearCart() async {
    await _apiService.delete('/cart');
  }
}
