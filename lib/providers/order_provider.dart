import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../models/order_model.dart';
import '../services/order_service.dart';

// Pagination result class
class PaginationResult {
  final DocumentSnapshot? lastDocument;
  final bool hasMore;
  
  PaginationResult({required this.lastDocument, required this.hasMore});
}

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  final List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Fetch initial orders with filters
  Future<PaginationResult> fetchOrders({
    required int limit,
    String? statusFilter,
    String? searchQuery,
    DateTimeRange? dateRange,
    required String sortBy,
    required bool sortAscending,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final result = await _orderService.getOrders(
        limit: limit,
        statusFilter: statusFilter,
        searchQuery: searchQuery,
        startDate: dateRange?.start,
        endDate: dateRange?.end,
        sortBy: sortBy,
        sortAscending: sortAscending,
      );
      
      _orders.clear();
      _orders.addAll(result.orders);
      
      _isLoading = false;
      notifyListeners();
      
      return PaginationResult(
        lastDocument: result.lastDocument,
        hasMore: result.hasMore,
      );
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  // Fetch more orders (pagination)
  Future<PaginationResult> fetchMoreOrders({
    required DocumentSnapshot? lastDocument,
    required int limit,
    String? statusFilter,
    String? searchQuery,
    DateTimeRange? dateRange,
    required String sortBy,
    required bool sortAscending,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final result = await _orderService.getOrders(
        limit: limit,
        lastDocument: lastDocument,
        statusFilter: statusFilter,
        searchQuery: searchQuery,
        startDate: dateRange?.start,
        endDate: dateRange?.end,
        sortBy: sortBy,
        sortAscending: sortAscending,
      );
      
      _orders.addAll(result.orders);
      
      _isLoading = false;
      notifyListeners();
      
      return PaginationResult(
        lastDocument: result.lastDocument,
        hasMore: result.hasMore,
      );
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  // Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _orderService.updateOrderStatus(orderId, newStatus);
      
      // Update local order
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: newStatus);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  // Get order by ID
  OrderModel? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }
  
  // Get order count by status
  int getOrderCountByStatus(String status) {
    return _orders.where((order) => order.status == status).length;
  }
  
  // Get real-time order updates stream
  Stream<OrderModel> getOrderUpdatesStream() {
    return _orderService.getOrderUpdatesStream();
  }
  
  // Get order analytics data
  Future<Map<String, dynamic>> getOrderAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _orderService.getOrderAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
