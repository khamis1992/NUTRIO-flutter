import 'package:flutter/material.dart';
import 'package:nutrio_wellness/core/theme/app_colors.dart';

class ActivitySummaryCard extends StatelessWidget {
  final int steps;
  final double distance;
  final int calories;
  final int activeMinutes;

  const ActivitySummaryCard({
    Key? key,
    required this.steps,
    required this.distance,
    required this.calories,
    required this.activeMinutes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              Color(0xFF2E7D32),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.directions_run,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Today\'s Activity',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActivityMetric(
                  context,
                  Icons.directions_walk,
                  steps.toString(),
                  'Steps',
                ),
                _buildActivityMetric(
                  context,
                  Icons.place,
                  '${distance.toStringAsFixed(1)} km',
                  'Distance',
                ),
                _buildActivityMetric(
                  context,
                  Icons.local_fire_department,
                  '$calories',
                  'Calories',
                ),
                _buildActivityMetric(
                  context,
                  Icons.timer,
                  '$activeMinutes min',
                  'Active',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityMetric(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
