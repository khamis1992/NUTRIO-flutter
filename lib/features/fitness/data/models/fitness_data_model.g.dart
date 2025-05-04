// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fitness_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FitnessDataModel _$FitnessDataModelFromJson(Map<String, dynamic> json) =>
    FitnessDataModel(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: $enumDecode(_$FitnessDataTypeEnumMap, json['type']),
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      source: json['source'] as String,
    );

Map<String, dynamic> _$FitnessDataModelToJson(FitnessDataModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'type': _$FitnessDataTypeEnumMap[instance.type]!,
      'value': instance.value,
      'unit': instance.unit,
      'metadata': instance.metadata,
      'source': instance.source,
    };

const _$FitnessDataTypeEnumMap = {
  FitnessDataType.steps: 'steps',
  FitnessDataType.distance: 'distance',
  FitnessDataType.calories: 'calories',
  FitnessDataType.heartRate: 'heartRate',
  FitnessDataType.sleep: 'sleep',
  FitnessDataType.workout: 'workout',
  FitnessDataType.water: 'water',
};

DailyFitnessSummary _$DailyFitnessSummaryFromJson(Map<String, dynamic> json) =>
    DailyFitnessSummary(
      date: DateTime.parse(json['date'] as String),
      steps: json['steps'] as int,
      distance: (json['distance'] as num).toDouble(),
      caloriesBurned: json['caloriesBurned'] as int,
      activeMinutes: json['activeMinutes'] as int,
      averageHeartRate: (json['averageHeartRate'] as num?)?.toDouble(),
      sleepDuration: json['sleepDuration'] as int?,
      waterIntake: json['waterIntake'] as int,
      workouts: (json['workouts'] as List<dynamic>?)
          ?.map((e) => WorkoutSession.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DailyFitnessSummaryToJson(
        DailyFitnessSummary instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'steps': instance.steps,
      'distance': instance.distance,
      'caloriesBurned': instance.caloriesBurned,
      'activeMinutes': instance.activeMinutes,
      'averageHeartRate': instance.averageHeartRate,
      'sleepDuration': instance.sleepDuration,
      'waterIntake': instance.waterIntake,
      'workouts': instance.workouts,
    };

WorkoutSession _$WorkoutSessionFromJson(Map<String, dynamic> json) =>
    WorkoutSession(
      id: json['id'] as String,
      type: json['type'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      duration: json['duration'] as int,
      caloriesBurned: json['caloriesBurned'] as int,
      distance: (json['distance'] as num?)?.toDouble(),
      details: json['details'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$WorkoutSessionToJson(WorkoutSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'duration': instance.duration,
      'caloriesBurned': instance.caloriesBurned,
      'distance': instance.distance,
      'details': instance.details,
    };
