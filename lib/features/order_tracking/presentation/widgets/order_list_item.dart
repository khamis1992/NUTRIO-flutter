import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutrio_wellness/core/theme/app_colors.dart';
import 'package:nutrio_wellness/features/order_tracking/data/models/order_model.dart';

class OrderListItem extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderListItem({
    Key? key,
    required this.order,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(order.orderTime),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Order items summary
              Text(
                _formatOrderItems(order.items),
                style: const TextStyle(
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // Status and total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusChip(order.status),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              
              // Delivery time for active orders
              if (order.status != OrderStatus.delivered && 
                  order.status != OrderStatus.cancelled &&
                  order.estimatedDeliveryTime != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Estimated delivery: ${DateFormat('h:mm a').format(order.estimatedDeliveryTime!)}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatOrderItems(List<OrderItem> items) {
    if (items.isEmpty) return 'No items';
    
    if (items.length == 1) {
      return '${items[0].quantity}x ${items[0].meal.name}';
    } else {
      return '${items[0].quantity}x ${items[0].meal.name} and ${items.length - 1} more item${items.length > 2 ? 's' : ''}';
    }
  }
  
  Widget _buildStatusChip(OrderStatus status) {
    Color backgroundColor;
    Color textColor;
    String label;
    
    switch (status) {
      case OrderStatus.pending:
        backgroundColor = Colors.grey[300]!;
        textColor = Colors.black87;
        label = 'Pending';
        break;
      case OrderStatus.confirmed:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        label = 'Confirmed';
        break;
      case OrderStatus.preparing:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        label = 'Preparing';
        break;
      case OrderStatus.readyForPickup:
        backgroundColor = Colors.amber[100]!;
        textColor = Colors.amber[800]!;
        label = 'Ready for Pickup';
        break;
      case OrderStatus.outForDelivery:
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[800]!;
        label = 'Out for Delivery';
        break;
      case OrderStatus.delivered:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        label = 'Delivered';
        break;
      case OrderStatus.cancelled:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        label = 'Cancelled';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
