import 'package:nutrio_wellness/features/meal_planner/data/models/meal_model.dart';
import 'package:nutrio_wellness/features/meal_planner/data/services/meal_service.dart';

abstract class MealRepository {
  Future<List<MealModel>> getMeals({
    List<DietaryType>? dietaryTypes,
    MealType? mealType,
    int? maxCalories,
    int? maxPreparationTime,
  });
  
  Future<MealModel> getMealById(String id);
  
  Future<List<MealModel>> getRecommendedMeals({
    required Map<String, dynamic> userPreferences,
    required Map<String, dynamic> fitnessData,
  });
  
  Future<void> toggleFavorite(String mealId);
  
  Future<List<MealModel>> getFavoriteMeals();
  
  Future<void> rateMeal(String mealId, double rating);
}

class MealRepositoryImpl implements MealRepository {
  final MealService _mealService;

  MealRepositoryImpl(this._mealService);

  @override
  Future<List<MealModel>> getMeals({
    List<DietaryType>? dietaryTypes,
    MealType? mealType,
    int? maxCalories,
    int? maxPreparationTime,
  }) async {
    try {
      return await _mealService.getMeals(
        dietaryTypes: dietaryTypes,
        mealType: mealType,
        maxCalories: maxCalories,
        maxPreparationTime: maxPreparationTime,
      );
    } catch (e) {
      throw Exception('Failed to get meals: ${e.toString()}');
    }
  }

  @override
  Future<MealModel> getMealById(String id) async {
    try {
      return await _mealService.getMealById(id);
    } catch (e) {
      throw Exception('Failed to get meal: ${e.toString()}');
    }
  }

  @override
  Future<List<MealModel>> getRecommendedMeals({
    required Map<String, dynamic> userPreferences,
    required Map<String, dynamic> fitnessData,
  }) async {
    try {
      return await _mealService.getRecommendedMeals(
        userPreferences: userPreferences,
        fitnessData: fitnessData,
      );
    } catch (e) {
      throw Exception('Failed to get recommended meals: ${e.toString()}');
    }
  }

  @override
  Future<void> toggleFavorite(String mealId) async {
    try {
      await _mealService.toggleFavorite(mealId);
    } catch (e) {
      throw Exception('Failed to toggle favorite: ${e.toString()}');
    }
  }

  @override
  Future<List<MealModel>> getFavoriteMeals() async {
    try {
      return await _mealService.getFavoriteMeals();
    } catch (e) {
      throw Exception('Failed to get favorite meals: ${e.toString()}');
    }
  }

  @override
  Future<void> rateMeal(String mealId, double rating) async {
    try {
      await _mealService.rateMeal(mealId, rating);
    } catch (e) {
      throw Exception('Failed to rate meal: ${e.toString()}');
    }
  }
}
