import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'fitness_data_model.g.dart';

enum FitnessDataType {
  steps,
  distance,
  calories,
  heartRate,
  sleep,
  workout,
  water
}

@JsonSerializable()
class FitnessDataModel extends Equatable {
  final String id;
  final DateTime timestamp;
  final FitnessDataType type;
  final double value;
  final String? unit;
  final Map<String, dynamic>? metadata;
  final String source; // e.g., 'fitbit', 'apple_health', 'google_fit', 'manual'

  const FitnessDataModel({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.value,
    this.unit,
    this.metadata,
    required this.source,
  });

  factory FitnessDataModel.fromJson(Map<String, dynamic> json) => _$FitnessDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$FitnessDataModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        timestamp,
        type,
        value,
        unit,
        metadata,
        source,
      ];
}

@JsonSerializable()
class DailyFitnessSummary extends Equatable {
  final DateTime date;
  final int steps;
  final double distance; // in kilometers
  final int caloriesBurned;
  final int activeMinutes;
  final double? averageHeartRate;
  final int? sleepDuration; // in minutes
  final int waterIntake; // in milliliters
  final List<WorkoutSession>? workouts;

  const DailyFitnessSummary({
    required this.date,
    required this.steps,
    required this.distance,
    required this.caloriesBurned,
    required this.activeMinutes,
    this.averageHeartRate,
    this.sleepDuration,
    required this.waterIntake,
    this.workouts,
  });

  factory DailyFitnessSummary.fromJson(Map<String, dynamic> json) => _$DailyFitnessSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$DailyFitnessSummaryToJson(this);

  @override
  List<Object?> get props => [
        date,
        steps,
        distance,
        caloriesBurned,
        activeMinutes,
        averageHeartRate,
        sleepDuration,
        waterIntake,
        workouts,
      ];
}

@JsonSerializable()
class WorkoutSession extends Equatable {
  final String id;
  final String type; // e.g., 'running', 'cycling', 'swimming', etc.
  final DateTime startTime;
  final DateTime endTime;
  final int duration; // in seconds
  final int caloriesBurned;
  final double? distance; // in kilometers
  final Map<String, dynamic>? details;

  const WorkoutSession({
    required this.id,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.caloriesBurned,
    this.distance,
    this.details,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => _$WorkoutSessionFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutSessionToJson(this);

  @override
  List<Object?> get props => [
        id,
        type,
        startTime,
        endTime,
        duration,
        caloriesBurned,
        distance,
        details,
      ];
}
