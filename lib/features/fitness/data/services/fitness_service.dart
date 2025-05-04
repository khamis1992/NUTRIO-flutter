import 'package:nutrio_wellness/features/fitness/data/models/fitness_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FitnessService {
  Future<List<FitnessDataModel>> getFitnessData({
    required DateTime startDate,
    required DateTime endDate,
    FitnessDataType? type,
  });
  
  Future<DailyFitnessSummary> getDailySummary(DateTime date);
  
  Future<List<DailyFitnessSummary>> getWeeklySummary(DateTime startDate);
  
  Future<Map<String, dynamic>> getLatestFitnessData();
  
  Future<void> syncFitnessData(String provider);
  
  Future<void> addManualFitnessData(FitnessDataModel data);
  
  Future<List<WorkoutSession>> getWorkoutSessions({
    required DateTime startDate,
    required DateTime endDate,
  });
  
  Future<void> addWorkoutSession(WorkoutSession session);
}

class FitnessServiceImpl implements FitnessService {
  // This is a mock implementation for demonstration purposes
  // In a real app, you would integrate with health platforms like Apple Health, Google Fit, etc.
  
  static const String _workoutSessionsKey = 'workout_sessions';
  
  // Mock fitness data
  final List<DailyFitnessSummary> _mockDailySummaries = [
    DailyFitnessSummary(
      date: DateTime.now().subtract(const Duration(days: 6)),
      steps: 7823,
      distance: 5.2,
      caloriesBurned: 320,
      activeMinutes: 45,
      averageHeartRate: 72,
      sleepDuration: 420, // 7 hours
      waterIntake: 1800,
      workouts: [
        WorkoutSession(
          id: '1',
          type: 'running',
          startTime: DateTime.now().subtract(const Duration(days: 6, hours: 10)),
          endTime: DateTime.now().subtract(const Duration(days: 6, hours: 9)),
          duration: 3600,
          caloriesBurned: 320,
          distance: 5.2,
          details: {
            'pace': 6.9,
            'elevationGain': 45,
          },
        ),
      ],
    ),
    DailyFitnessSummary(
      date: DateTime.now().subtract(const Duration(days: 5)),
      steps: 5421,
      distance: 3.8,
      caloriesBurned: 250,
      activeMinutes: 35,
      averageHeartRate: 68,
      sleepDuration: 450, // 7.5 hours
      waterIntake: 2000,
      workouts: [],
    ),
    DailyFitnessSummary(
      date: DateTime.now().subtract(const Duration(days: 4)),
      steps: 10234,
      distance: 7.1,
      caloriesBurned: 420,
      activeMinutes: 65,
      averageHeartRate: 75,
      sleepDuration: 390, // 6.5 hours
      waterIntake: 2200,
      workouts: [
        WorkoutSession(
          id: '2',
          type: 'cycling',
          startTime: DateTime.now().subtract(const Duration(days: 4, hours: 18)),
          endTime: DateTime.now().subtract(const Duration(days: 4, hours: 17)),
          duration: 3600,
          caloriesBurned: 350,
          distance: 15.0,
          details: {
            'speed': 15.0,
            'elevationGain': 120,
          },
        ),
      ],
    ),
    DailyFitnessSummary(
      date: DateTime.now().subtract(const Duration(days: 3)),
      steps: 8765,
      distance: 6.0,
      caloriesBurned: 380,
      activeMinutes: 55,
      averageHeartRate: 73,
      sleepDuration: 420, // 7 hours
      waterIntake: 1900,
      workouts: [],
    ),
    DailyFitnessSummary(
      date: DateTime.now().subtract(const Duration(days: 2)),
      steps: 6543,
      distance: 4.5,
      caloriesBurned: 290,
      activeMinutes: 40,
      averageHeartRate: 70,
      sleepDuration: 480, // 8 hours
      waterIntake: 2100,
      workouts: [
        WorkoutSession(
          id: '3',
          type: 'strength',
          startTime: DateTime.now().subtract(const Duration(days: 2, hours: 20)),
          endTime: DateTime.now().subtract(const Duration(days: 2, hours: 19)),
          duration: 3600,
          caloriesBurned: 280,
          details: {
            'sets': 15,
            'reps': 180,
          },
        ),
      ],
    ),
    DailyFitnessSummary(
      date: DateTime.now().subtract(const Duration(days: 1)),
      steps: 9876,
      distance: 6.8,
      caloriesBurned: 400,
      activeMinutes: 60,
      averageHeartRate: 74,
      sleepDuration: 435, // 7.25 hours
      waterIntake: 2300,
      workouts: [],
    ),
    DailyFitnessSummary(
      date: DateTime.now(),
      steps: 4532,
      distance: 3.1,
      caloriesBurned: 220,
      activeMinutes: 30,
      averageHeartRate: 69,
      sleepDuration: 450, // 7.5 hours
      waterIntake: 1500,
      workouts: [],
    ),
  ];

  @override
  Future<List<FitnessDataModel>> getFitnessData({
    required DateTime startDate,
    required DateTime endDate,
    FitnessDataType? type,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock implementation - in a real app, this would fetch from health platforms
    List<FitnessDataModel> fitnessData = [];
    
    // Generate mock data for each day in the range
    for (DateTime date = startDate;
        date.isBefore(endDate.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      
      // Find the daily summary for this date
      final summary = _mockDailySummaries.firstWhere(
        (s) => s.date.year == date.year && s.date.month == date.month && s.date.day == date.day,
        orElse: () => DailyFitnessSummary(
          date: date,
          steps: 0,
          distance: 0,
          caloriesBurned: 0,
          activeMinutes: 0,
          waterIntake: 0,
        ),
      );
      
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

  @override
  Future<DailyFitnessSummary> getDailySummary(DateTime date) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Find the daily summary for this date
    return _mockDailySummaries.firstWhere(
      (s) => s.date.year == date.year && s.date.month == date.month && s.date.day == date.day,
      orElse: () => DailyFitnessSummary(
        date: date,
        steps: 0,
        distance: 0,
        caloriesBurned: 0,
        activeMinutes: 0,
        waterIntake: 0,
      ),
    );
  }

  @override
  Future<List<DailyFitnessSummary>> getWeeklySummary(DateTime startDate) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Calculate the end date (7 days from start)
    final endDate = startDate.add(const Duration(days: 6));
    
    // Filter summaries within the date range
    return _mockDailySummaries.where((summary) {
      return summary.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          summary.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> getLatestFitnessData() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Get today's summary
    final today = DateTime.now();
    final todaySummary = await getDailySummary(today);
    
    // Convert to a map for easier consumption by other services
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
  }

  @override
  Future<void> syncFitnessData(String provider) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));
    
    // In a real app, this would trigger a sync with the specified health platform
    // For this mock implementation, we don't do anything
  }

  @override
  Future<void> addManualFitnessData(FitnessDataModel data) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // In a real app, this would add the data to the local database and sync with health platforms
    // For this mock implementation, we don't do anything
  }

  @override
  Future<List<WorkoutSession>> getWorkoutSessions({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Get workouts from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final workoutJsonList = prefs.getStringList(_workoutSessionsKey) ?? [];
    
    // Parse stored workouts
    List<WorkoutSession> storedWorkouts = [];
    for (final json in workoutJsonList) {
      try {
        final workout = WorkoutSession.fromJson(json as Map<String, dynamic>);
        storedWorkouts.add(workout);
      } catch (e) {
        // Skip invalid entries
      }
    }
    
    // Combine mock and stored workouts
    List<WorkoutSession> allWorkouts = [];
    
    // Add workouts from mock daily summaries
    for (final summary in _mockDailySummaries) {
      if (summary.workouts != null && summary.workouts!.isNotEmpty) {
        allWorkouts.addAll(summary.workouts!);
      }
    }
    
    // Add stored workouts
    allWorkouts.addAll(storedWorkouts);
    
    // Filter by date range
    return allWorkouts.where((workout) {
      return workout.startTime.isAfter(startDate.subtract(const Duration(days: 1))) &&
          workout.startTime.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<void> addWorkoutSession(WorkoutSession session) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // In a real app, this would add the workout to the local database and sync with health platforms
    // For this mock implementation, we'll store it in SharedPreferences
    
    final prefs = await SharedPreferences.getInstance();
    final workoutJsonList = prefs.getStringList(_workoutSessionsKey) ?? [];
    
    workoutJsonList.add(session.toJson().toString());
    
    await prefs.setStringList(_workoutSessionsKey, workoutJsonList);
  }
}
