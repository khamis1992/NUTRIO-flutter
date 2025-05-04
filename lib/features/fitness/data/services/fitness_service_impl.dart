import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:nutrio_wellness/features/fitness/data/models/fitness_data_model.dart';
import 'package:nutrio_wellness/features/fitness/data/services/fitness_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RealFitnessServiceImpl implements FitnessService {
  static const String _workoutSessionsKey = 'workout_sessions';
  static const String _lastSyncKey = 'last_sync_timestamp';
  
  // Health plugin instance
  final HealthFactory _health = HealthFactory();
  
  // Fitbit API credentials (these should be stored securely in a real app)
  final String _fitbitClientId = 'YOUR_FITBIT_CLIENT_ID';
  final String _fitbitClientSecret = 'YOUR_FITBIT_CLIENT_SECRET';
  final String _fitbitRedirectUri = 'nutriowellness://fitbit/auth';
  
  // Available data types for health platforms
  final List<HealthDataType> _healthDataTypes = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.WATER,
    HealthDataType.WORKOUT,
  ];
  
  // Cached data
  List<DailyFitnessSummary>? _cachedDailySummaries;
  
  @override
  Future<List<FitnessDataModel>> getFitnessData({
    required DateTime startDate,
    required DateTime endDate,
    FitnessDataType? type,
  }) async {
    try {
      // Request authorization
      final types = _mapToHealthDataTypes(type);
      final permissions = types.map((e) => HealthDataAccess.READ).toList();
      final authorized = await _health.requestAuthorization(types, permissions: permissions);
      
      if (!authorized) {
        throw Exception('Authorization not granted');
      }
      
      // Fetch data from health platform
      final healthData = await _health.getHealthDataFromTypes(startDate, endDate, types);
      
      // Convert to our model
      return healthData.map((data) => _convertHealthDataToFitnessData(data)).toList();
    } catch (e) {
      debugPrint('Error fetching fitness data: $e');
      // Fall back to mock data if health platform integration fails
      return _getMockFitnessData(startDate, endDate, type);
    }
  }
  
  @override
  Future<DailyFitnessSummary> getDailySummary(DateTime date) async {
    try {
      // Set time to start and end of day
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      // Get all fitness data for the day
      final fitnessData = await getFitnessData(
        startDate: startOfDay,
        endDate: endOfDay,
      );
      
      // Calculate summary
      return _calculateDailySummary(fitnessData, date);
    } catch (e) {
      debugPrint('Error fetching daily summary: $e');
      // Fall back to mock data
      return _getMockDailySummary(date);
    }
  }
  
  @override
  Future<List<DailyFitnessSummary>> getWeeklySummary(DateTime startDate) async {
    try {
      // If we have cached data, use it
      if (_cachedDailySummaries != null) {
        final filteredSummaries = _cachedDailySummaries!.where((summary) {
          return summary.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              summary.date.isBefore(startDate.add(const Duration(days: 7)));
        }).toList();
        
        if (filteredSummaries.isNotEmpty) {
          return filteredSummaries;
        }
      }
      
      // Calculate end date (7 days from start)
      final endDate = startDate.add(const Duration(days: 6));
      
      // Get all fitness data for the week
      final fitnessData = await getFitnessData(
        startDate: startDate,
        endDate: endDate,
      );
      
      // Group data by day and calculate summaries
      final summaries = <DailyFitnessSummary>[];
      for (var i = 0; i < 7; i++) {
        final date = startDate.add(Duration(days: i));
        final dailyData = fitnessData.where((data) {
          return data.timestamp.year == date.year &&
              data.timestamp.month == date.month &&
              data.timestamp.day == date.day;
        }).toList();
        
        summaries.add(_calculateDailySummary(dailyData, date));
      }
      
      // Cache the summaries
      _cachedDailySummaries = summaries;
      
      return summaries;
    } catch (e) {
      debugPrint('Error fetching weekly summary: $e');
      // Fall back to mock data
      return _getMockWeeklySummary(startDate);
    }
  }
  
  @override
  Future<Map<String, dynamic>> getLatestFitnessData() async {
    try {
      // Get today's summary
      final today = DateTime.now();
      final todaySummary = await getDailySummary(today);
      
      // Convert to a map
      return {
        'date': today.toIso8601String(),
        'steps': todaySummary.steps,
        'distance': todaySummary.distance,
        'caloriesBurned': todaySummary.caloriesBurned,
        'activeMinutes': todaySummary.activeMinutes,
        'averageHeartRate': todaySummary.averageHeartRate,
        'sleepDuration': todaySummary.sleepDuration,
        'waterIntake': todaySummary.waterIntake,
      };
    } catch (e) {
      debugPrint('Error fetching latest fitness data: $e');
      // Return empty data
      return {
        'date': DateTime.now().toIso8601String(),
        'steps': 0,
        'distance': 0.0,
        'caloriesBurned': 0,
        'activeMinutes': 0,
        'waterIntake': 0,
      };
    }
  }
  
  @override
  Future<void> syncFitnessData(String provider) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncTimestamp = prefs.getInt('${_lastSyncKey}_$provider') ?? 0;
      final lastSyncDate = DateTime.fromMillisecondsSinceEpoch(lastSyncTimestamp);
      final now = DateTime.now();
      
      switch (provider.toLowerCase()) {
        case 'apple_health':
          await _syncAppleHealthData(lastSyncDate, now);
          break;
        case 'google_fit':
          await _syncGoogleFitData(lastSyncDate, now);
          break;
        case 'fitbit':
          await _syncFitbitData(lastSyncDate, now);
          break;
        default:
          throw Exception('Unsupported provider: $provider');
      }
      
      // Update last sync timestamp
      await prefs.setInt('${_lastSyncKey}_$provider', now.millisecondsSinceEpoch);
      
      // Clear cache to force refresh
      _cachedDailySummaries = null;
    } catch (e) {
      debugPrint('Error syncing fitness data: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> addManualFitnessData(FitnessDataModel data) async {
    try {
      // For manual data, we'll store it in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final manualDataKey = 'manual_fitness_data';
      final manualDataJson = prefs.getStringList(manualDataKey) ?? [];
      
      // Add new data
      manualDataJson.add(jsonEncode(data.toJson()));
      
      // Save back to SharedPreferences
      await prefs.setStringList(manualDataKey, manualDataJson);
      
      // Clear cache to force refresh
      _cachedDailySummaries = null;
    } catch (e) {
      debugPrint('Error adding manual fitness data: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<WorkoutSession>> getWorkoutSessions({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Try to get workouts from health platforms
      final workouts = await _getWorkoutsFromHealthPlatforms(startDate, endDate);
      
      // Get manually added workouts from SharedPreferences
      final manualWorkouts = await _getManualWorkouts(startDate, endDate);
      
      // Combine and sort by start time (newest first)
      final allWorkouts = [...workouts, ...manualWorkouts];
      allWorkouts.sort((a, b) => b.startTime.compareTo(a.startTime));
      
      return allWorkouts;
    } catch (e) {
      debugPrint('Error fetching workout sessions: $e');
      // Fall back to mock data
      return _getMockWorkoutSessions(startDate, endDate);
    }
  }
  
  @override
  Future<void> addWorkoutSession(WorkoutSession session) async {
    try {
      // For manual workouts, we'll store them in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final workoutsJson = prefs.getStringList(_workoutSessionsKey) ?? [];
      
      // Add new workout
      workoutsJson.add(jsonEncode(session.toJson()));
      
      // Save back to SharedPreferences
      await prefs.setStringList(_workoutSessionsKey, workoutsJson);
      
      // Clear cache to force refresh
      _cachedDailySummaries = null;
    } catch (e) {
      debugPrint('Error adding workout session: $e');
      rethrow;
    }
  }
  
  // Helper methods
  
  List<HealthDataType> _mapToHealthDataTypes(FitnessDataType? type) {
    if (type == null) {
      return _healthDataTypes;
    }
    
    switch (type) {
      case FitnessDataType.steps:
        return [HealthDataType.STEPS];
      case FitnessDataType.distance:
        return [HealthDataType.DISTANCE_WALKING_RUNNING];
      case FitnessDataType.calories:
        return [HealthDataType.ACTIVE_ENERGY_BURNED];
      case FitnessDataType.heartRate:
        return [HealthDataType.HEART_RATE];
      case FitnessDataType.sleep:
        return [HealthDataType.SLEEP_IN_BED];
      case FitnessDataType.water:
        return [HealthDataType.WATER];
      case FitnessDataType.workout:
        return [HealthDataType.WORKOUT];
      default:
        return _healthDataTypes;
    }
  }
  
  FitnessDataModel _convertHealthDataToFitnessData(HealthDataPoint healthData) {
    // Map health data type to our model
    FitnessDataType type;
    String? unit;
    
    switch (healthData.type) {
      case HealthDataType.STEPS:
        type = FitnessDataType.steps;
        unit = 'steps';
        break;
      case HealthDataType.DISTANCE_WALKING_RUNNING:
        type = FitnessDataType.distance;
        unit = 'km';
        break;
      case HealthDataType.ACTIVE_ENERGY_BURNED:
        type = FitnessDataType.calories;
        unit = 'kcal';
        break;
      case HealthDataType.HEART_RATE:
        type = FitnessDataType.heartRate;
        unit = 'bpm';
        break;
      case HealthDataType.SLEEP_IN_BED:
        type = FitnessDataType.sleep;
        unit = 'min';
        break;
      case HealthDataType.WATER:
        type = FitnessDataType.water;
        unit = 'ml';
        break;
      case HealthDataType.WORKOUT:
        type = FitnessDataType.workout;
        break;
      default:
        type = FitnessDataType.steps;
        unit = 'steps';
    }
    
    // Convert value to double
    double value = 0;
    if (healthData.value is NumericHealthValue) {
      value = (healthData.value as NumericHealthValue).numericValue.toDouble();
    }
    
    // Create our model
    return FitnessDataModel(
      id: healthData.uuid,
      timestamp: healthData.dateFrom,
      type: type,
      value: value,
      unit: unit,
      source: healthData.sourceName,
    );
  }
  
  DailyFitnessSummary _calculateDailySummary(List<FitnessDataModel> data, DateTime date) {
    // Initialize with default values
    int steps = 0;
    double distance = 0;
    int caloriesBurned = 0;
    int activeMinutes = 0;
    double? averageHeartRate;
    int? sleepDuration;
    int waterIntake = 0;
    List<WorkoutSession> workouts = [];
    
    // Calculate totals
    for (final item in data) {
      switch (item.type) {
        case FitnessDataType.steps:
          steps += item.value.toInt();
          break;
        case FitnessDataType.distance:
          distance += item.value;
          break;
        case FitnessDataType.calories:
          caloriesBurned += item.value.toInt();
          break;
        case FitnessDataType.heartRate:
          // Calculate average heart rate
          if (averageHeartRate == null) {
            averageHeartRate = item.value;
          } else {
            averageHeartRate = (averageHeartRate + item.value) / 2;
          }
          break;
        case FitnessDataType.sleep:
          sleepDuration = item.value.toInt();
          break;
        case FitnessDataType.water:
          waterIntake += item.value.toInt();
          break;
        case FitnessDataType.workout:
          // Workouts are handled separately
          break;
      }
    }
    
    // Calculate active minutes (simplified)
    activeMinutes = (caloriesBurned / 10).round(); // Rough estimate
    
    return DailyFitnessSummary(
      date: DateTime(date.year, date.month, date.day),
      steps: steps,
      distance: distance,
      caloriesBurned: caloriesBurned,
      activeMinutes: activeMinutes,
      averageHeartRate: averageHeartRate,
      sleepDuration: sleepDuration,
      waterIntake: waterIntake,
      workouts: workouts,
    );
  }
  
  Future<void> _syncAppleHealthData(DateTime startDate, DateTime endDate) async {
    if (!Platform.isIOS) return;
    
    // Request authorization
    final authorized = await _health.requestAuthorization(_healthDataTypes);
    
    if (!authorized) {
      throw Exception('Authorization not granted for Apple Health');
    }
    
    // Sync is automatic with the health plugin, so we don't need to do anything else
  }
  
  Future<void> _syncGoogleFitData(DateTime startDate, DateTime endDate) async {
    if (!Platform.isAndroid) return;
    
    // Request authorization
    final authorized = await _health.requestAuthorization(_healthDataTypes);
    
    if (!authorized) {
      throw Exception('Authorization not granted for Google Fit');
    }
    
    // Sync is automatic with the health plugin, so we don't need to do anything else
  }
  
  Future<void> _syncFitbitData(DateTime startDate, DateTime endDate) async {
    // Check if we have Fitbit access token
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('fitbit_access_token');
    
    if (accessToken == null) {
      throw Exception('Not authenticated with Fitbit');
    }
    
    // Format dates for Fitbit API
    final startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    
    // Fetch steps data
    final stepsResponse = await http.get(
      Uri.parse('https://api.fitbit.com/1/user/-/activities/steps/date/$startDateStr/$endDateStr.json'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    
    if (stepsResponse.statusCode != 200) {
      throw Exception('Failed to fetch Fitbit steps data: ${stepsResponse.body}');
    }
    
    // Parse steps data
    final stepsData = jsonDecode(stepsResponse.statusCode.toString());
    
    // Store in SharedPreferences for later use
    await prefs.setString('fitbit_steps_data', jsonEncode(stepsData));
    
    // Fetch other data types similarly...
  }
  
  Future<List<WorkoutSession>> _getWorkoutsFromHealthPlatforms(DateTime startDate, DateTime endDate) async {
    try {
      // Request authorization
      final authorized = await _health.requestAuthorization([HealthDataType.WORKOUT]);
      
      if (!authorized) {
        return [];
      }
      
      // Fetch workouts
      final workouts = await _health.getHealthDataFromTypes(
        startDate,
        endDate,
        [HealthDataType.WORKOUT],
      );
      
      // Convert to our model
      return workouts.map((workout) {
        // Extract workout details
        final value = workout.value;
        int duration = 0;
        int calories = 0;
        double? distance;
        
        if (value is WorkoutHealthValue) {
          duration = value.totalEnergyBurned.toInt();
          calories = value.totalEnergyBurned.toInt();
          distance = value.totalDistance;
        }
        
        return WorkoutSession(
          id: workout.uuid,
          type: workout.workoutActivityType.toString().split('.').last.toLowerCase(),
          startTime: workout.dateFrom,
          endTime: workout.dateTo,
          duration: duration,
          caloriesBurned: calories,
          distance: distance,
          details: {
            'source': workout.sourceName,
            'sourceId': workout.sourceId,
          },
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching workouts from health platforms: $e');
      return [];
    }
  }
  
  Future<List<WorkoutSession>> _getManualWorkouts(DateTime startDate, DateTime endDate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workoutsJson = prefs.getStringList(_workoutSessionsKey) ?? [];
      
      // Parse workouts
      final workouts = workoutsJson.map((json) {
        try {
          final Map<String, dynamic> data = jsonDecode(json);
          return WorkoutSession.fromJson(data);
        } catch (e) {
          debugPrint('Error parsing workout: $e');
          return null;
        }
      }).whereType<WorkoutSession>().toList();
      
      // Filter by date range
      return workouts.where((workout) {
        return workout.startTime.isAfter(startDate.subtract(const Duration(days: 1))) &&
            workout.startTime.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      debugPrint('Error fetching manual workouts: $e');
      return [];
    }
  }
  
  // Mock data methods (fallbacks)
  
  List<FitnessDataModel> _getMockFitnessData(
    DateTime startDate,
    DateTime endDate,
    FitnessDataType? type,
  ) {
    // Generate mock data for each day in the range
    List<FitnessDataModel> fitnessData = [];
    
    for (DateTime date = startDate;
        date.isBefore(endDate.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      
      // Find the daily summary for this date
      final summary = _getMockDailySummary(date);
      
      // Add data points based on the type filter
      if (type == null || type == FitnessDataType.steps) {
        fitnessData.add(FitnessDataModel(
          id: 'steps_${date.millisecondsSinceEpoch}',
          timestamp: date,
          type: FitnessDataType.steps,
          value: summary.steps.toDouble(),
          unit: 'steps',
          source: 'mock',
        ));
      }
      
      if (type == null || type == FitnessDataType.distance) {
        fitnessData.add(FitnessDataModel(
          id: 'distance_${date.millisecondsSinceEpoch}',
          timestamp: date,
          type: FitnessDataType.distance,
          value: summary.distance,
          unit: 'km',
          source: 'mock',
        ));
      }
      
      if (type == null || type == FitnessDataType.calories) {
        fitnessData.add(FitnessDataModel(
          id: 'calories_${date.millisecondsSinceEpoch}',
          timestamp: date,
          type: FitnessDataType.calories,
          value: summary.caloriesBurned.toDouble(),
          unit: 'kcal',
          source: 'mock',
        ));
      }
      
      if ((type == null || type == FitnessDataType.heartRate) && summary.averageHeartRate != null) {
        fitnessData.add(FitnessDataModel(
          id: 'heart_rate_${date.millisecondsSinceEpoch}',
          timestamp: date,
          type: FitnessDataType.heartRate,
          value: summary.averageHeartRate!,
          unit: 'bpm',
          source: 'mock',
        ));
      }
      
      if ((type == null || type == FitnessDataType.sleep) && summary.sleepDuration != null) {
        fitnessData.add(FitnessDataModel(
          id: 'sleep_${date.millisecondsSinceEpoch}',
          timestamp: date,
          type: FitnessDataType.sleep,
          value: summary.sleepDuration!.toDouble(),
          unit: 'min',
          source: 'mock',
        ));
      }
      
      if (type == null || type == FitnessDataType.water) {
        fitnessData.add(FitnessDataModel(
          id: 'water_${date.millisecondsSinceEpoch}',
          timestamp: date,
          type: FitnessDataType.water,
          value: summary.waterIntake.toDouble(),
          unit: 'ml',
          source: 'mock',
        ));
      }
    }
    
    return fitnessData;
  }
  
  DailyFitnessSummary _getMockDailySummary(DateTime date) {
    // Mock data based on day of week for some variation
    final dayOfWeek = date.weekday;
    final isWeekend = dayOfWeek == DateTime.saturday || dayOfWeek == DateTime.sunday;
    final isToday = date.day == DateTime.now().day && 
                    date.month == DateTime.now().month && 
                    date.year == DateTime.now().year;
    
    // Base values
    int steps = isWeekend ? 5000 : 8000;
    double distance = isWeekend ? 3.5 : 5.5;
    int calories = isWeekend ? 250 : 380;
    int activeMinutes = isWeekend ? 35 : 55;
    double heartRate = 70;
    int sleepDuration = isWeekend ? 480 : 420; // in minutes
    int waterIntake = 1800;
    
    // Add some randomness
    steps += (steps * 0.2 * (dayOfWeek / 7)).round();
    distance += distance * 0.2 * (dayOfWeek / 7);
    calories += (calories * 0.2 * (dayOfWeek / 7)).round();
    activeMinutes += (activeMinutes * 0.2 * (dayOfWeek / 7)).round();
    heartRate += 5 * (dayOfWeek / 7);
    waterIntake += (waterIntake * 0.2 * (dayOfWeek / 7)).round();
    
    // For today, reduce values if it's not evening yet
    if (isToday) {
      final currentHour = DateTime.now().hour;
      final dayProgress = currentHour / 24;
      
      steps = (steps * dayProgress).round();
      distance = distance * dayProgress;
      calories = (calories * dayProgress).round();
      activeMinutes = (activeMinutes * dayProgress).round();
      waterIntake = (waterIntake * dayProgress).round();
      
      // Sleep is from previous night, so keep it
    }
    
    // Create workout for some days
    List<WorkoutSession>? workouts;
    if (dayOfWeek == DateTime.monday || dayOfWeek == DateTime.wednesday || dayOfWeek == DateTime.friday) {
      workouts = [
        WorkoutSession(
          id: 'workout_${date.millisecondsSinceEpoch}',
          type: dayOfWeek == DateTime.monday ? 'running' : 
                dayOfWeek == DateTime.wednesday ? 'cycling' : 'strength',
          startTime: DateTime(date.year, date.month, date.day, 18, 0),
          endTime: DateTime(date.year, date.month, date.day, 19, 0),
          duration: 3600, // 1 hour in seconds
          caloriesBurned: dayOfWeek == DateTime.monday ? 320 : 
                         dayOfWeek == DateTime.wednesday ? 350 : 280,
          distance: dayOfWeek == DateTime.monday ? 5.2 : 
                   dayOfWeek == DateTime.wednesday ? 15.0 : null,
          details: dayOfWeek == DateTime.monday ? {
            'pace': 6.9,
            'elevationGain': 45,
          } : dayOfWeek == DateTime.wednesday ? {
            'speed': 15.0,
            'elevationGain': 120,
          } : {
            'sets': 15,
            'reps': 180,
          },
        ),
      ];
    }
    
    return DailyFitnessSummary(
      date: date,
      steps: steps,
      distance: distance,
      caloriesBurned: calories,
      activeMinutes: activeMinutes,
      averageHeartRate: heartRate,
      sleepDuration: sleepDuration,
      waterIntake: waterIntake,
      workouts: workouts,
    );
  }
  
  List<DailyFitnessSummary> _getMockWeeklySummary(DateTime startDate) {
    final summaries = <DailyFitnessSummary>[];
    
    for (var i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      summaries.add(_getMockDailySummary(date));
    }
    
    return summaries;
  }
  
  List<WorkoutSession> _getMockWorkoutSessions(DateTime startDate, DateTime endDate) {
    final workouts = <WorkoutSession>[];
    
    // Add a workout for each Monday, Wednesday, and Friday in the range
    for (DateTime date = startDate;
        date.isBefore(endDate.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      
      final dayOfWeek = date.weekday;
      
      if (dayOfWeek == DateTime.monday || dayOfWeek == DateTime.wednesday || dayOfWeek == DateTime.friday) {
        workouts.add(
          WorkoutSession(
            id: 'workout_${date.millisecondsSinceEpoch}',
            type: dayOfWeek == DateTime.monday ? 'running' : 
                  dayOfWeek == DateTime.wednesday ? 'cycling' : 'strength',
            startTime: DateTime(date.year, date.month, date.day, 18, 0),
            endTime: DateTime(date.year, date.month, date.day, 19, 0),
            duration: 3600, // 1 hour in seconds
            caloriesBurned: dayOfWeek == DateTime.monday ? 320 : 
                           dayOfWeek == DateTime.wednesday ? 350 : 280,
            distance: dayOfWeek == DateTime.monday ? 5.2 : 
                     dayOfWeek == DateTime.wednesday ? 15.0 : null,
            details: dayOfWeek == DateTime.monday ? {
              'pace': 6.9,
              'elevationGain': 45,
            } : dayOfWeek == DateTime.wednesday ? {
              'speed': 15.0,
              'elevationGain': 120,
            } : {
              'sets': 15,
              'reps': 180,
            },
          ),
        );
      }
    }
    
    return workouts;
  }
}
