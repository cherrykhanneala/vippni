import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/order_item_widget.dart'; // Ensure this path is correct
import 'orders_menu.dart'; // Ensure this path is correct
import '../../models/order_model.dart';
import 'order_details_screen.dart';
import 'edit_order_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  OrdersScreenState createState() => OrdersScreenState();
}

class OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _vendorId =
      FirebaseAuth.instance.currentUser!.uid; // Ensure current user is handled correctly
  late TabController _tabController;
  bool _isLoading = true;
  late List<QueryDocumentSnapshot> _cachedOrders;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .get();
      _cachedOrders = snapshot.docs;
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Consider adding error handling UI feedback
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle the case when the user is not logged in
      return Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
        ),
        body: const Center(
          child: Text('Please log in to view your orders.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF31135F),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'On the Way'),
            Tab(text: 'Completed'),
          ],
          labelColor: Colors.white,
        ),
      ),
      drawer: const OrdersMenu(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList('Pending'),
                _buildOrdersList('On the Way'),
                _buildOrdersList('Completed'),
              ],
            ),
    );
  }

  Widget _buildOrdersList(String statusFilter) {
    final filteredOrders = _cachedOrders.where((order) {
      final List<dynamic> items = order['items'];
      final vendorItems = items.where((item) =>
          item['vendorId'] == _vendorId && item['status'] == statusFilter).toList();
      return vendorItems.isNotEmpty;
    }).toList();

    return filteredOrders.isEmpty
        ? const Center(child: Text('No orders found.'))
        : ListView.builder(
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              final List<dynamic> items = order['items'];
              final vendorItems = items.where((item) {
                return item['vendorId'] == _vendorId &&
                    item['status'] == statusFilter;
              }).toList();

              return OrderItemWidget(
                order: OrderModel(
                  id: order.id,
                  customerId: order['userId'] ?? '',
                  date: (order['orderDate'] as Timestamp).toDate(),
                  total: (order['totalPrice'] ?? 0).toDouble(),
                  status: statusFilter,
                  items: vendorItems.map<OrderItem>((item) => OrderItem.fromMap(item)).toList(),
                  // The following fields are not present in your Firestore, so set as null
                  customerName: null,
                  customerEmail: null,
                  customerPhone: null,
                  shipping: null,
                  payment: null,
                ),
                onView: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => OrderDetailsScreen(
                        order: OrderModel(
                          id: order.id,
                          customerId: order['userId'] ?? '',
                          date: (order['orderDate'] as Timestamp).toDate(),
                          total: (order['totalPrice'] ?? 0).toDouble(),
                          status: statusFilter,
                          items: vendorItems.map<OrderItem>((item) => OrderItem.fromMap(item)).toList(),
                          customerName: null,
                          customerEmail: null,
                          customerPhone: null,
                          shipping: null,
                          payment: null,
                        ),
                      ),
                    ),
                  );
                },
                onEdit: () async {
                  final updated = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditOrderScreen(
                        order: OrderModel(
                          id: order.id,
                          customerId: order['userId'] ?? '',
                          date: (order['orderDate'] as Timestamp).toDate(),
                          total: (order['totalPrice'] ?? 0).toDouble(),
                          status: statusFilter,
                          items: vendorItems.map<OrderItem>((item) => OrderItem.fromMap(item)).toList(),
                          customerName: null,
                          customerEmail: null,
                          customerPhone: null,
                          shipping: null,
                          payment: null,
                        ),
                      ),
                    ),
                  );
                  if (updated == true) {
                    _fetchOrders();
                  }
                },
              );
            },
          );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
