import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../analytics/analytics_service.dart';

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
  final AnalyticsService _analytics = AnalyticsService();
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _analytics.logScreenView('order_details_screen');
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'processing':
        color = Colors.blue;
        break;
      case 'shipped':
        color = Colors.green;
        break;
      case 'delivered':
        color = Colors.purple;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(color: color),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final order = widget.order;
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/edit-order',
                arguments: order,
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.status,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            _buildStatusBadge(order.status),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Customer Information Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customer Information',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow('Customer ID', order.customerId),
                            _buildInfoRow('Name', order.customerName),
                            _buildInfoRow('Email', order.customerEmail),
                            _buildInfoRow('Phone', order.customerPhone),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Order Details Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Details',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              'Order Date',
                              DateFormat.yMMMd().format(order.date),
                            ),
                            _buildInfoRow(
                              'Total',
                              currencyFormat.format(order.total),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Items Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Items',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: order.items.length,
                              itemBuilder: (context, index) {
                                final item = order.items[index];
                                return ListTile(
                                  leading: item.imageUrl != null
                                      ? Image.network(
                                          item.imageUrl!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  title: Text(item.productName),
                                  subtitle: Text('${item.quantity}x @ ${currencyFormat.format(item.price)}'),
                                  trailing: Text(currencyFormat.format(item.total)),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Shipping Information Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shipping Information',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow('Name', order.shipping.name),
                            _buildInfoRow('Address', order.shipping.address),
                            _buildInfoRow('City', order.shipping.city),
                            _buildInfoRow('State', order.shipping.state),
                            _buildInfoRow('Postal Code', order.shipping.postalCode),
                            _buildInfoRow('Country', order.shipping.country),
                            if (order.shipping.trackingNumber != null)
                              _buildInfoRow('Tracking', order.shipping.trackingNumber!),
                            if (order.shipping.carrier != null)
                              _buildInfoRow('Carrier', order.shipping.carrier!),
                            if (order.shipping.shippedDate != null)
                              _buildInfoRow(
                                'Shipped Date',
                                DateFormat.yMMMd().format(order.shipping.shippedDate!),
                              ),
                            if (order.shipping.estimatedDelivery != null)
                              _buildInfoRow(
                                'Estimated Delivery',
                                DateFormat.yMMMd().format(order.shipping.estimatedDelivery!),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Payment Information Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Information',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow('Method', order.payment.method),
                            _buildInfoRow('Status', order.payment.status),
                            if (order.payment.transactionId != null)
                              _buildInfoRow('Transaction ID', order.payment.transactionId!),
                            if (order.payment.paidAt != null)
                              _buildInfoRow(
                                'Paid At',
                                DateFormat.yMMMd().format(order.payment.paidAt!),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}