import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import '../models/order_model.dart';

// Result class for pagination
class OrderQueryResult {
  final List<OrderModel> orders;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;
  
  OrderQueryResult({
    required this.orders,
    required this.lastDocument,
    required this.hasMore,
  });
}

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get orders with pagination and filtering
  Future<OrderQueryResult> getOrders({
    required int limit,
    DocumentSnapshot? lastDocument,
    String? statusFilter,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    required String sortBy,
    required bool sortAscending,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Start building query
      Query query = _firestore.collection('orders')
          .where('sellerId', isEqualTo: userId);
      
      // Apply status filter
      if (statusFilter != null) {
        query = query.where('status', isEqualTo: statusFilter);
      }
      
      // Apply date range filter
      if (startDate != null && endDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: startDate)
                     .where('date', isLessThanOrEqualTo: endDate);
      }
      
      // Apply sorting
      String sortField;
      switch (sortBy) {
        case 'date':
          sortField = 'date';
          break;
        case 'total':
          sortField = 'total';
          break;
        case 'customer':
          sortField = 'customerName';
          break;
        case 'status':
          sortField = 'status';
          break;
        default:
          sortField = 'date';
      }
      
      query = query.orderBy(sortField, descending: !sortAscending);
      
      // Apply pagination
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      
      // Limit results
      query = query.limit(limit);
      
      // Execute query
      final snapshot = await query.get();
      final orders = snapshot.docs.map((doc) {
        return OrderModel.fromFirestore(doc);
      }).toList();
      
      // Filter by search query locally (Firestore doesn't support text search well)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        return OrderQueryResult(
          orders: orders.where((order) {
            return order.id.toLowerCase().contains(lowerQuery) ||
                   (order.customerName?.toLowerCase() ?? '').contains(lowerQuery) ||
                   (order.customerEmail?.toLowerCase() ?? '').contains(lowerQuery);
          }).toList(),
          lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
          hasMore: snapshot.docs.length >= limit,
        );
      }
      
      return OrderQueryResult(
        orders: orders,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        hasMore: snapshot.docs.length >= limit,
      );
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }
  
  // Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
  
  // Get real-time order updates stream
  Stream<OrderModel> getOrderUpdatesStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    return _firestore.collection('orders')
        .where('sellerId', isEqualTo: userId)
        .snapshots()
        .expand((snapshot) {
          return snapshot.docChanges
              .where((change) => change.type == DocumentChangeType.modified)
              .map((change) => OrderModel.fromFirestore(change.doc));
        });
  }
  
  // Get order analytics data
  Future<Map<String, dynamic>> getOrderAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      Query query = _firestore.collection('orders')
          .where('sellerId', isEqualTo: userId);
      
      if (startDate != null && endDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: startDate)
                     .where('date', isLessThanOrEqualTo: endDate);
      }
      
      final snapshot = await query.get();
      final orders = snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
      
      // Calculate analytics
      double totalRevenue = 0;
      Map<String, int> statusCounts = {
        'Pending': 0,
        'Processing': 0,
        'Shipped': 0,
        'Delivered': 0,
        'Cancelled': 0,
      };
      
      Map<String, double> dailyRevenue = {};
      Set<String> uniqueCustomers = {};
      
      for (var order in orders) {
        totalRevenue += order.totalPrice;
        statusCounts[order.status] = (statusCounts[order.status] ?? 0) + 1;
        
        final dateString = '${order.date.year}-${order.date.month}-${order.date.day}';
        dailyRevenue[dateString] = (dailyRevenue[dateString] ?? 0) + order.totalPrice;
        
        uniqueCustomers.add(order.customerId);
      }
      
      return {
        'totalOrders': orders.length,
        'totalRevenue': totalRevenue,
        'statusCounts': statusCounts,
        'dailyRevenue': dailyRevenue,
        'uniqueCustomers': uniqueCustomers.length,
        'averageOrderValue': orders.isEmpty ? 0 : totalRevenue / orders.length,
      };
    } catch (e) {
      throw Exception('Failed to fetch order analytics: $e');
    }
  }
}
