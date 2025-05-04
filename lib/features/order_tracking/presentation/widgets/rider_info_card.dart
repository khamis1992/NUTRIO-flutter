import 'package:flutter/material.dart';
import 'package:nutrio_wellness/core/theme/app_colors.dart';
import 'package:nutrio_wellness/features/order_tracking/data/models/order_model.dart';

class RiderInfoCard extends StatelessWidget {
  final DeliveryRider rider;
  final VoidCallback onChatPressed;
  final VoidCallback onCallPressed;

  const RiderInfoCard({
    Key? key,
    required this.rider,
    required this.onChatPressed,
    required this.onCallPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.delivery_dining, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Delivery Rider',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Rider photo
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  backgroundImage: rider.photoUrl != null
                      ? NetworkImage(rider.photoUrl!)
                      : null,
                  child: rider.photoUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 30,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                
                // Rider info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rider.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (rider.rating != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rider.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Action buttons
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: IconButton(
                        icon: const Icon(Icons.phone, color: Colors.green),
                        onPressed: onCallPressed,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: IconButton(
                        icon: const Icon(Icons.chat, color: AppColors.primary),
                        onPressed: onChatPressed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
