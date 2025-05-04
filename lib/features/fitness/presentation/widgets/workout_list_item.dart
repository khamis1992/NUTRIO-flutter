import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutrio_wellness/core/theme/app_colors.dart';
import 'package:nutrio_wellness/features/fitness/data/models/fitness_data_model.dart';

class WorkoutListItem extends StatelessWidget {
  final WorkoutSession session;
  final VoidCallback onTap;

  const WorkoutListItem({
    Key? key,
    required this.session,
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getWorkoutColor().withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getWorkoutIcon(),
                      color: _getWorkoutColor(),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _capitalizeWorkoutType(session.type),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy • h:mm a').format(session.startTime),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildWorkoutStat(
                    context,
                    Icons.timer,
                    _formatDuration(session.duration),
                    'Duration',
                  ),
                  _buildWorkoutStat(
                    context,
                    Icons.local_fire_department,
                    '${session.caloriesBurned}',
                    'Calories',
                  ),
                  if (session.distance != null)
                    _buildWorkoutStat(
                      context,
                      Icons.place,
                      '${session.distance!.toStringAsFixed(1)} km',
                      'Distance',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutStat(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.textSecondary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  IconData _getWorkoutIcon() {
    switch (session.type.toLowerCase()) {
      case 'running':
        return Icons.directions_run;
      case 'cycling':
        return Icons.directions_bike;
      case 'swimming':
        return Icons.pool;
      case 'walking':
        return Icons.directions_walk;
      case 'hiking':
        return Icons.terrain;
      case 'strength':
        return Icons.fitness_center;
      case 'yoga':
        return Icons.self_improvement;
      case 'pilates':
        return Icons.accessibility_new;
      default:
        return Icons.fitness_center;
    }
  }

  Color _getWorkoutColor() {
    switch (session.type.toLowerCase()) {
      case 'running':
        return Colors.orange;
      case 'cycling':
        return Colors.green;
      case 'swimming':
        return Colors.blue;
      case 'walking':
        return Colors.teal;
      case 'hiking':
        return Colors.brown;
      case 'strength':
        return Colors.purple;
      case 'yoga':
        return Colors.indigo;
      case 'pilates':
        return Colors.pink;
      default:
        return AppColors.primary;
    }
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '$hours h ${minutes.toString().padLeft(2, '0')} m';
    } else {
      return '$minutes min';
    }
  }

  String _capitalizeWorkoutType(String type) {
    if (type.isEmpty) return '';
    return type[0].toUpperCase() + type.substring(1);
  }
}
