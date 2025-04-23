import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';

class OrderItemWidget extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback? onLongPress;

  const OrderItemWidget({
    super.key,
    required this.order,
    required this.onView,
    required this.onEdit,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    
    return InkWell(
      onLongPress: onLongPress,
      child: Card(
        child: ListTile(
          title: Row(
            children: [
              Text('Order #${order.id}'),
              const SizedBox(width: 8),
              _buildStatusChip(order.status),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.customerName),
              Text(
                '${DateFormat.yMMMd().format(order.date)} - ${currencyFormat.format(order.total)}',
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: onView,
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
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
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}
