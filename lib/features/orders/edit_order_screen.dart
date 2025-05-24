import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _status = widget.order.status;
    _shippingController = TextEditingController(
        text: widget.order.shipping != null
            ? widget.order.shipping.toString()
            : '');
    _paymentController = TextEditingController(
        text: widget.order.payment != null
            ? widget.order.payment.toString()
            : '');
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
      final currentVendorId = FirebaseAuth.instance.currentUser?.uid;
      final orderRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.id);

      // Get the current order data
      final orderDoc = await orderRef.get();
      final data = orderDoc.data() as Map<String, dynamic>;
      final List<dynamic> items = List.from(data['items'] ?? []);

      // Update status for all items belonging to the current vendor
      for (int i = 0; i < items.length; i++) {
        if (items[i]['vendorId'] == currentVendorId) {
          items[i]['status'] = _status;
        }
      }

      // Update the order document
      await orderRef.update({
        'items': items,
        'shipping': _shippingController.text.isNotEmpty
            ? _shippingController.text
            : null,
        'payment': _paymentController.text.isNotEmpty
            ? _paymentController.text
            : null,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          _hasUnsavedChanges = false;
        });
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update order: $e')),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      final shouldLeave = await _showUnsavedChangesDialog();
      return shouldLeave ?? false;
    }
    return true;
  }

  Future<bool?> _showUnsavedChangesDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
              'You have unsaved changes. Do you want to save them before leaving?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () async {
                await _saveOrder();
                Navigator.of(context).pop(true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
                        DropdownMenuItem(
                            value: 'Pending', child: Text('Pending')),
                        DropdownMenuItem(
                            value: 'on the way', child: Text('On the Way')),
                        DropdownMenuItem(
                            value: 'Completed', child: Text('Completed')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _status = value;
                            _hasUnsavedChanges = true;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _shippingController,
                      decoration:
                          const InputDecoration(labelText: 'Shipping'),
                      onChanged: (_) {
                        setState(() {
                          _hasUnsavedChanges = true;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _paymentController,
                      decoration:
                          const InputDecoration(labelText: 'Payment'),
                      onChanged: (_) {
                        setState(() {
                          _hasUnsavedChanges = true;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveOrder,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}