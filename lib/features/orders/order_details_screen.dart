import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;
  
  const OrderDetailsScreen({
    super.key, 
    required this.order,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _isLoading = true;
  bool _hasUnsavedChanges = false; // Track unsaved changes
  Map<String, dynamic>? _userData;
  Map<String, List<Map<String, dynamic>>> _productsData = {};
  final Set<String> _selectedProductIds = {}; // Track selected product IDs

  @override
  void initState() {
    super.initState();
    _fetchRelatedData();
  }

  Future<void> _fetchRelatedData() async {
    try {
      // Fetch user data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.order.customerId)
          .get();
      
      // Fetch products data
      final productIds = widget.order.items.map((item) => item.productId).toList();
      final productsData = await Future.wait(
        productIds.map((id) => FirebaseFirestore.instance
            .collection('products')
            .doc(id)
            .get())
      );

      if (mounted) {
        setState(() {
          _userData = userDoc.data();
          _productsData = Map.fromIterables(
            productIds,
            productsData.map((doc) => [doc.data() ?? {}]),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading order details')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Intercept back navigation
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Order #${widget.order.orderNumber}'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Order Details'),
                Tab(text: 'Parcel Details'),
              ],
            ),
          ),
          body: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildOrderDetailsTab(),
                  _buildParcelDetailsTab(),
                ],
              ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      final shouldLeave = await _showUnsavedChangesDialog();
      return shouldLeave ?? false; // Allow navigation if user confirms
    }
    return true; // Allow navigation if no unsaved changes
  }

  Future<bool?> _showUnsavedChangesDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Unsaved Changes'),
          content: _hasTrackingNumberEntered()
              ? const Text(
                  'You have entered a tracking number. Do you want to update the order status to "On the Way"?')
              : const Text(
                  'You have unsaved changes. Do you want to save them before leaving?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Discard changes
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () async {
                if (_hasTrackingNumberEntered()) {
                  _updateOrderStatusToOnTheWay(); // Update status to "On the Way"
                }
                await _saveChanges(); // Save changes
                Navigator.of(context).pop(true); // Allow navigation
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderOverview(),
          const Divider(height: 32),
          _buildCustomerDetails(),
          const Divider(height: 32),
          _buildOrderItems(),
          const Divider(height: 32),
          _buildPricingSummary(),
        ],
      ),
    );
  }

  Widget _buildOrderOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Order Number:', '#${widget.order.orderNumber}'),
            _buildInfoRow(
              'Order Date:', 
              DateFormat('MMM dd, yyyy - hh:mm a')
                .format(widget.order.date),
            ),
            _buildInfoRow('Total Items:', '${widget.order.items.length}'),
            _buildInfoRow(
              'Total Amount:', 
              NumberFormat.currency(symbol: '\$').format(widget.order.totalPrice),
            ),
            _buildInfoRow(
              'Payment Method:', 
              widget.order.payment?['method'] ?? 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerDetails() {
    return SizedBox(
      width: double.infinity, // Ensure the card takes the full width
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Name:', _userData?['fullName'] ?? 'N/A'),
              _buildInfoRow('Email:', _userData?['email'] ?? 'N/A'),
              if (_userData?['address'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Address:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Line 1:', _userData!['address']['line1'] ?? ''),
                _buildInfoRow('Line 2:', _userData!['address']['line2'] ?? ''),
                _buildInfoRow(
                  'City & Postcode:',
                  '${_userData!['address']['city'] ?? ''}, ${_userData!['address']['postCode'] ?? ''}',
                ),
                _buildInfoRow('Country:', _userData!['address']['country'] ?? ''),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItems() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Items',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...widget.order.items.map((item) {
              final productData = _productsData[item.productId]?.first;
              return ListTile(
                leading: productData?['images'] != null 
                  ? Image.network(
                      productData!['images'][0],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image_not_supported),
                title: Text(item.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quantity: ${item.quantity}'),
                    Text('Status: ${item.status}'),
                  ],
                ),
                trailing: Text(
                  NumberFormat.currency(symbol: '\$').format(item.price),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Subtotal:', 
              NumberFormat.currency(symbol: '\$').format(widget.order.totalPrice),
            ),
            if (widget.order.payment != null) ...[
              _buildInfoRow(
                'Shipping:', 
                NumberFormat.currency(symbol: '\$')
                  .format(widget.order.payment?['deliveryCharge'] ?? 0),
              ),
              _buildInfoRow(
                'Discount:', 
                NumberFormat.currency(symbol: '\$')
                  .format(widget.order.payment?['discount'] ?? 0),
              ),
            ],
            const Divider(),
            _buildInfoRow(
              'Total:', 
              NumberFormat.currency(symbol: '\$').format(widget.order.totalPrice),
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParcelDetailsTab() {
    final items = widget.order.items;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Details Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Address Info',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.map, color: Colors.blue),
                        onPressed: () {
                          // Handle "Show on Map" action
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Handle "Edit Address" action
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            _userData?['fullName'] ?? 'N/A',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          const Icon(Icons.phone, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(_userData?['phone'] ?? 'N/A'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formatFullAddress(_userData?['address']),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 32),

              // Common Fields Section
              if (_selectedProductIds.isNotEmpty) _buildCommonFields(),

              // Parcel Details Section
              Text(
                'Parcel Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Display individual product cards with expandable fields
              ...items.map((item) {
                final productData = _productsData[item.productId]?.first;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Checkbox(
                          value: _selectedProductIds.contains(item.productId),
                          onChanged: (isSelected) {
                            setState(() {
                              if (isSelected == true) {
                                _selectedProductIds.add(item.productId);
                              } else {
                                _selectedProductIds.remove(item.productId);
                              }
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Product: ${item.name}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text('Quantity: ${item.quantity}'),
                    leading: productData?['images'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              productData!['images'][0],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.image_not_supported),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEditableField(
                              label: 'Tracking Number',
                              icon: Icons.local_shipping,
                              initialValue: item.trackingNumber ?? '',
                              onChanged: (value) {
                                _updateOrderItemField(
                                    item, 'trackingNumber', value);
                              },
                            ),
                            _buildEditableField(
                              label: 'Parcel Weight (grams)',
                              icon: Icons.scale,
                              initialValue: (item.weight ?? '').toString(),
                              onChanged: (value) {
                                _updateOrderItemField(
                                    item, 'weight', double.tryParse(value) ?? 0);
                              },
                            ),
                            _buildEditableField(
                              label: 'Parcel Size (Cubic mm)',
                              icon: Icons.straighten,
                              initialValue: item.size ?? '',
                              onChanged: (value) {
                                _updateOrderItemField(item, 'size', value);
                              },
                            ),
                            _buildEditableField(
                              label: 'Shipping Cost',
                              icon: Icons.attach_money,
                              initialValue: item.shippingCost ?? '',
                              onChanged: (value) {
                                _updateOrderItemField(item, 'shippingCost', value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),

        // Save Changes Button at the Bottom
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommonFields() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Common Fields for Selected Products',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              label: 'Shipping Cost',
              icon: Icons.attach_money,
              initialValue: '',
              onChanged: (value) {
                for (final productId in _selectedProductIds) {
                  final item = widget.order.items.firstWhere((item) => item.productId == productId);
                  _updateOrderItemField(item, 'shippingCost', value);
                }
              },
            ),
            _buildEditableField(
              label: 'Tracking Number',
              icon: Icons.local_shipping,
              initialValue: '',
              onChanged: (value) {
                for (final productId in _selectedProductIds) {
                  final item = widget.order.items.firstWhere((item) => item.productId == productId);
                  _updateOrderItemField(item, 'trackingNumber', value);
                }
              },
            ),
            _buildEditableField(
              label: 'Weight (grams)',
              icon: Icons.scale,
              initialValue: '',
              onChanged: (value) {
                for (final productId in _selectedProductIds) {
                  final item = widget.order.items.firstWhere((item) => item.productId == productId);
                  _updateOrderItemField(item, 'weight', double.tryParse(value) ?? 0);
                }
              },
            ),
            _buildEditableField(
              label: 'Size (Cubic mm)',
              icon: Icons.straighten,
              initialValue: '',
              onChanged: (value) {
                for (final productId in _selectedProductIds) {
                  final item = widget.order.items.firstWhere((item) => item.productId == productId);
                  _updateOrderItemField(item, 'size', value);
                }
              },
            ),
            _buildDropdownField(
              label: 'Status',
              value: null,
              items: const ['Pending', 'On the Way', 'Completed'],
              onChanged: (value) {
                if (value != null) {
                  for (final productId in _selectedProductIds) {
                    final item = widget.order.items.firstWhere((item) => item.productId == productId);
                    _updateOrderItemField(item, 'status', value);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatFullAddress(Map<String, dynamic>? address) {
    if (address == null) return 'N/A';
    return '${address['line1'] ?? ''}, ${address['line2'] ?? ''}, ${address['city'] ?? ''}, ${address['postCode'] ?? ''}, ${address['country'] ?? ''}';
  }

  Widget _buildEditableField({
    required String label,
    required IconData icon,
    required String initialValue,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : null, // Ensure value is valid
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _updateOrderItemField(OrderItem item, String field, dynamic value) async {
    setState(() {
      final index = widget.order.items.indexWhere((i) => i.productId == item.productId);
      if (index != -1) {
        final updatedItem = widget.order.items[index].toMap();
        updatedItem[field] = value;
        widget.order.items[index] = OrderItem.fromMap(updatedItem);

        // Mark as having unsaved changes
        _hasUnsavedChanges = true;
      }
    });
  }

  Future<void> _saveChanges() async {
    try {
      // Convert all items to a list of maps for Firestore
      final List<Map<String, dynamic>> updatedItems = widget.order.items.map((item) => item.toMap()).toList();

      // Update the Firestore document
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.id)
          .update({'items': updatedItems});

      setState(() {
        _hasUnsavedChanges = false; // Reset unsaved changes flag
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save changes')),
      );
    }
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasTrackingNumberEntered() {
    return widget.order.items.any((item) => 
        item.trackingNumber != null && item.trackingNumber!.isNotEmpty);
  }

  void _updateOrderStatusToOnTheWay() {
    setState(() {
      for (final item in widget.order.items) {
        if (item.trackingNumber != null && item.trackingNumber!.isNotEmpty) {
          _updateOrderItemField(item, 'status', 'On the Way');
        }
      }
    });
  }
}