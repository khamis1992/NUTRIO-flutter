import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutrio_wellness/core/theme/app_colors.dart';
import 'package:nutrio_wellness/features/order_tracking/data/models/order_model.dart';

class OrderStatusTimeline extends StatelessWidget {
  final List<OrderStatusUpdate> statusUpdates;
  final OrderStatus currentStatus;

  const OrderStatusTimeline({
    Key? key,
    required this.statusUpdates,
    required this.currentStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sort status updates by timestamp
    final sortedUpdates = List<OrderStatusUpdate>.from(statusUpdates)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    // Define all possible statuses in order
    final allStatuses = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.readyForPickup,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];
    
    // Filter out cancelled status if not current
    if (currentStatus != OrderStatus.cancelled) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < allStatuses.length; i++)
            _buildStatusStep(
              context,
              allStatuses[i],
              i == allStatuses.length - 1,
              sortedUpdates,
            ),
        ],
      );
    } else {
      // Show only statuses that occurred before cancellation
      final statusesBeforeCancellation = <OrderStatus>[];
      for (final update in sortedUpdates) {
        if (update.status == OrderStatus.cancelled) break;
        statusesBeforeCancellation.add(update.status);
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < statusesBeforeCancellation.length; i++)
            _buildStatusStep(
              context,
              statusesBeforeCancellation[i],
              i == statusesBeforeCancellation.length - 1,
              sortedUpdates,
            ),
          _buildStatusStep(
            context,
            OrderStatus.cancelled,
            true,
            sortedUpdates,
          ),
        ],
      );
    }
  }
  
  Widget _buildStatusStep(
    BuildContext context,
    OrderStatus status,
    bool isLast,
    List<OrderStatusUpdate> updates,
  ) {
    // Find the update for this status
    final update = updates.lastWhere(
      (u) => u.status == status,
      orElse: () => OrderStatusUpdate(
        status: status,
        timestamp: DateTime(1970), // Placeholder date
      ),
    );
    
    final bool isCompleted = updates.any((u) => u.status == status);
    final bool isCurrent = currentStatus == status;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status indicator and line
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? (status == OrderStatus.cancelled ? AppColors.error : AppColors.primary)
                    : Colors.grey[300],
                border: isCurrent
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: isCompleted
                  ? Icon(
                      status == OrderStatus.cancelled ? Icons.close : Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? AppColors.primary : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        
        // Status details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getStatusLabel(status),
                style: TextStyle(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                  color: isCompleted
                      ? (status == OrderStatus.cancelled ? AppColors.error : AppColors.textPrimary)
                      : Colors.grey,
                ),
              ),
              if (isCompleted) ...[
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, h:mm a').format(update.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: status == OrderStatus.cancelled
                        ? AppColors.error.withOpacity(0.7)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
              if (update.message != null) ...[
                const SizedBox(height: 4),
                Text(
                  update.message!,
                  style: TextStyle(
                    fontSize: 14,
                    color: status == OrderStatus.cancelled
                        ? AppColors.error.withOpacity(0.7)
                        : AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              if (!isLast) const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
  
  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Order Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.readyForPickup:
        return 'Ready for Pickup';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}
