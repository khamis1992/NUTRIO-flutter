import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutrio_wellness/core/theme/app_colors.dart';
import 'package:nutrio_wellness/features/fitness/data/models/fitness_data_model.dart';

class WeeklyChart extends StatelessWidget {
  final List<DailyFitnessSummary> summaries;
  final String dataType;
  final Color color;

  const WeeklyChart({
    Key? key,
    required this.summaries,
    required this.dataType,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sort summaries by date
    final sortedSummaries = List<DailyFitnessSummary>.from(summaries)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    // Get max value for scaling
    double maxValue = 1.0; // Default to avoid division by zero
    
    switch (dataType) {
      case 'steps':
        maxValue = sortedSummaries.fold(0, (max, summary) => summary.steps > max ? summary.steps : max).toDouble();
        break;
      case 'distance':
        maxValue = sortedSummaries.fold(0.0, (max, summary) => summary.distance > max ? summary.distance : max);
        break;
      case 'calories':
        maxValue = sortedSummaries.fold(0, (max, summary) => summary.caloriesBurned > max ? summary.caloriesBurned : max).toDouble();
        break;
      case 'activeMinutes':
        maxValue = sortedSummaries.fold(0, (max, summary) => summary.activeMinutes > max ? summary.activeMinutes : max).toDouble();
        break;
    }
    
    // Add 10% padding to max value
    maxValue *= 1.1;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Y-axis labels
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatValue(maxValue, dataType),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _formatValue(maxValue * 0.75, dataType),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _formatValue(maxValue * 0.5, dataType),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _formatValue(maxValue * 0.25, dataType),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Text(
                        '0',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  
                  // Chart bars
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: sortedSummaries.map((summary) {
                        double value = 0;
                        
                        switch (dataType) {
                          case 'steps':
                            value = summary.steps.toDouble();
                            break;
                          case 'distance':
                            value = summary.distance;
                            break;
                          case 'calories':
                            value = summary.caloriesBurned.toDouble();
                            break;
                          case 'activeMinutes':
                            value = summary.activeMinutes.toDouble();
                            break;
                        }
                        
                        // Calculate height percentage
                        final heightPercentage = value / maxValue;
                        
                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: 180 * heightPercentage,
                                width: 24,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('E').format(summary.date),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Average: ${_calculateAverage()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Total: ${_calculateTotal()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatValue(double value, String type) {
    switch (type) {
      case 'steps':
        return value.round().toString();
      case 'distance':
        return '${value.toStringAsFixed(1)} km';
      case 'calories':
        return '${value.round()} kcal';
      case 'activeMinutes':
        return '${value.round()} min';
      default:
        return value.toString();
    }
  }

  String _calculateAverage() {
    if (summaries.isEmpty) return '0';
    
    switch (dataType) {
      case 'steps':
        final avg = summaries.fold(0, (sum, item) => sum + item.steps) / summaries.length;
        return avg.round().toString();
      case 'distance':
        final avg = summaries.fold(0.0, (sum, item) => sum + item.distance) / summaries.length;
        return '${avg.toStringAsFixed(1)} km';
      case 'calories':
        final avg = summaries.fold(0, (sum, item) => sum + item.caloriesBurned) / summaries.length;
        return '${avg.round()} kcal';
      case 'activeMinutes':
        final avg = summaries.fold(0, (sum, item) => sum + item.activeMinutes) / summaries.length;
        return '${avg.round()} min';
      default:
        return '0';
    }
  }

  String _calculateTotal() {
    if (summaries.isEmpty) return '0';
    
    switch (dataType) {
      case 'steps':
        final total = summaries.fold(0, (sum, item) => sum + item.steps);
        return total.toString();
      case 'distance':
        final total = summaries.fold(0.0, (sum, item) => sum + item.distance);
        return '${total.toStringAsFixed(1)} km';
      case 'calories':
        final total = summaries.fold(0, (sum, item) => sum + item.caloriesBurned);
        return '${total} kcal';
      case 'activeMinutes':
        final total = summaries.fold(0, (sum, item) => sum + item.activeMinutes);
        return '${total} min';
      default:
        return '0';
    }
  }
}
