import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/order_item_widget.dart'; // Ensure this path is correct
import 'orders_menu.dart'; // Ensure this path is correct
import '../../models/order_model.dart';


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
          elevation: 0,
          title: const Text('Orders', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF31135F),
        ),
        body: const Center(
          child: Text('Please log in to view your orders.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF31135F),
        elevation: 2,
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
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Processing'),
            Tab(text: 'Completed'),
          ],
          labelStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: const OrdersMenu(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList('Pending'),
                _buildOrdersList('Processing'),
                _buildOrdersList('Completed'),
              ],
            ),
    );
  }

  Widget _buildOrdersList(String statusFilter) {
    String firestoreStatus;
    switch (statusFilter) {
      case 'Processing':
        firestoreStatus = 'on the way';
        break;
      case 'Completed':
        firestoreStatus = 'Completed';
        break;
      case 'Pending':
      default:
        firestoreStatus = 'Pending';
        break;
    }

    final filteredOrders = _cachedOrders.where((order) {
      final List<dynamic> items = order['items'] ?? [];
      // Check for items that belong to this vendor AND match the status
      final vendorItems = items.where((item) =>
          item['vendorId'] == _vendorId &&
          (item['status'] ?? 'Pending') == firestoreStatus).toList();
      return vendorItems.isNotEmpty;
    }).toList();

    if (filteredOrders.isEmpty) {
      return Center(
          child: Text('No $statusFilter orders found',
              style: const TextStyle(fontSize: 16)));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: filteredOrders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return FutureBuilder<OrderModel>(
          future: OrderModel.fromFirestoreWithCustomer(order),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('Loading...')),
                ),
              );
            }

            if (snapshot.hasError) {
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                      child: Text('Error loading order: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red))),
                ),
              );
            }

            final orderModel = snapshot.data!;
            return OrderItemWidget(
              order: orderModel, // Pass only the order
            );
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
