import 'package:nutrio_wellness/features/fitness/data/models/fitness_data_model.dart';
import 'package:nutrio_wellness/features/fitness/data/services/fitness_service.dart';

abstract class FitnessRepository {
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

class FitnessRepositoryImpl implements FitnessRepository {
  final FitnessService _fitnessService;

  FitnessRepositoryImpl(this._fitnessService);

  @override
  Future<List<FitnessDataModel>> getFitnessData({
    required DateTime startDate,
    required DateTime endDate,
    FitnessDataType? type,
  }) async {
    try {
      return await _fitnessService.getFitnessData(
        startDate: startDate,
        endDate: endDate,
        type: type,
      );
    } catch (e) {
      throw Exception('Failed to get fitness data: ${e.toString()}');
    }
  }

  @override
  Future<DailyFitnessSummary> getDailySummary(DateTime date) async {
    try {
      return await _fitnessService.getDailySummary(date);
    } catch (e) {
      throw Exception('Failed to get daily summary: ${e.toString()}');
    }
  }

  @override
  Future<List<DailyFitnessSummary>> getWeeklySummary(DateTime startDate) async {
    try {
      return await _fitnessService.getWeeklySummary(startDate);
    } catch (e) {
      throw Exception('Failed to get weekly summary: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getLatestFitnessData() async {
    try {
      return await _fitnessService.getLatestFitnessData();
    } catch (e) {
      throw Exception('Failed to get latest fitness data: ${e.toString()}');
    }
  }

  @override
  Future<void> syncFitnessData(String provider) async {
    try {
      await _fitnessService.syncFitnessData(provider);
    } catch (e) {
      throw Exception('Failed to sync fitness data: ${e.toString()}');
    }
  }

  @override
  Future<void> addManualFitnessData(FitnessDataModel data) async {
    try {
      await _fitnessService.addManualFitnessData(data);
    } catch (e) {
      throw Exception('Failed to add manual fitness data: ${e.toString()}');
    }
  }

  @override
  Future<List<WorkoutSession>> getWorkoutSessions({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _fitnessService.getWorkoutSessions(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to get workout sessions: ${e.toString()}');
    }
  }

  @override
  Future<void> addWorkoutSession(WorkoutSession session) async {
    try {
      await _fitnessService.addWorkoutSession(session);
    } catch (e) {
      throw Exception('Failed to add workout session: ${e.toString()}');
    }
  }
}
