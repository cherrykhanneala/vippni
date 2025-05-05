import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../../models/order_model.dart';

class EditOrderScreen extends StatefulWidget {
  final OrderModel order;

  const EditOrderScreen({super.key, required this.order});

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  late String _status;
  late TextEditingController _shippingController;
  late TextEditingController _paymentController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.order.status;
    _shippingController = TextEditingController(text: widget.order.shipping.toString());
    _paymentController = TextEditingController(text: widget.order.payment.toString());
  }

  @override
  void dispose() {
    _shippingController.dispose();
    _paymentController.dispose();
    super.dispose();
  }

  Future<void> _saveOrder() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Get the current vendor's items
      final currentVendorId = FirebaseAuth.instance.currentUser?.uid;
      final orderRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.id);
      
      // Get the current order data
      final orderDoc = await orderRef.get();
      final data = orderDoc.data() as Map<String, dynamic>;
      final List<dynamic> items = List.from(data['items'] ?? []);

      // Update status for all items belonging to current vendor
      for (int i = 0; i < items.length; i++) {
        if (items[i]['vendorId'] == currentVendorId) {
          items[i]['status'] = _status;
        }
      }

      // Update the order document
      await orderRef.update({
        'items': items,
        'shipping': _shippingController.text.isNotEmpty ? 
          jsonDecode(_shippingController.text) : null,
        'payment': _paymentController.text.isNotEmpty ? 
          jsonDecode(_paymentController.text) : null,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update order: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Order'),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'on the Way', child: Text('Processing')),
                      DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _status = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _shippingController,
                    decoration: const InputDecoration(labelText: 'Shipping'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _paymentController,
                    decoration: const InputDecoration(labelText: 'Payment'),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveOrder,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
    );
  }
}