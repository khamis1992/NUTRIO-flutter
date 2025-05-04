import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrio_wellness/core/services/service_locator.dart';
import 'package:nutrio_wellness/features/auth/data/repositories/auth_repository.dart';
import 'package:nutrio_wellness/features/fitness/data/repositories/fitness_repository.dart';
import 'package:nutrio_wellness/features/meal_planner/data/models/meal_model.dart';
import 'package:nutrio_wellness/features/meal_planner/data/repositories/meal_repository.dart';

// Events
abstract class MealPlannerEvent extends Equatable {
  const MealPlannerEvent();

  @override
  List<Object?> get props => [];
}

class LoadMeals extends MealPlannerEvent {
  final List<DietaryType>? dietaryTypes;
  final MealType? mealType;
  final int? maxCalories;
  final int? maxPreparationTime;

  const LoadMeals({
    this.dietaryTypes,
    this.mealType,
    this.maxCalories,
    this.maxPreparationTime,
  });

  @override
  List<Object?> get props => [dietaryTypes, mealType, maxCalories, maxPreparationTime];
}

class LoadMealDetails extends MealPlannerEvent {
  final String mealId;

  const LoadMealDetails(this.mealId);

  @override
  List<Object?> get props => [mealId];
}

class LoadRecommendedMeals extends MealPlannerEvent {}

class ToggleFavoriteMeal extends MealPlannerEvent {
  final String mealId;

  const ToggleFavoriteMeal(this.mealId);

  @override
  List<Object?> get props => [mealId];
}

class LoadFavoriteMeals extends MealPlannerEvent {}

class RateMeal extends MealPlannerEvent {
  final String mealId;
  final double rating;

  const RateMeal({
    required this.mealId,
    required this.rating,
  });

  @override
  List<Object?> get props => [mealId, rating];
}

// States
abstract class MealPlannerState extends Equatable {
  const MealPlannerState();

  @override
  List<Object?> get props => [];
}

class MealPlannerInitial extends MealPlannerState {}

class MealPlannerLoading extends MealPlannerState {}

class MealPlannerError extends MealPlannerState {
  final String message;

  const MealPlannerError(this.message);

  @override
  List<Object?> get props => [message];
}

class MealsLoaded extends MealPlannerState {
  final List<MealModel> meals;

  const MealsLoaded(this.meals);

  @override
  List<Object?> get props => [meals];
}

class MealDetailsLoaded extends MealPlannerState {
  final MealModel meal;

  const MealDetailsLoaded(this.meal);

  @override
  List<Object?> get props => [meal];
}

class RecommendedMealsLoaded extends MealPlannerState {
  final List<MealModel> meals;

  const RecommendedMealsLoaded(this.meals);

  @override
  List<Object?> get props => [meals];
}

class FavoriteMealsLoaded extends MealPlannerState {
  final List<MealModel> meals;

  const FavoriteMealsLoaded(this.meals);

  @override
  List<Object?> get props => [meals];
}

// Bloc
class MealPlannerBloc extends Bloc<MealPlannerEvent, MealPlannerState> {
  final MealRepository _mealRepository = getIt<MealRepository>();
  final AuthRepository _authRepository = getIt<AuthRepository>();
  final FitnessRepository _fitnessRepository = getIt<FitnessRepository>();

  MealPlannerBloc() : super(MealPlannerInitial()) {
    on<LoadMeals>(_onLoadMeals);
    on<LoadMealDetails>(_onLoadMealDetails);
    on<LoadRecommendedMeals>(_onLoadRecommendedMeals);
    on<ToggleFavoriteMeal>(_onToggleFavoriteMeal);
    on<LoadFavoriteMeals>(_onLoadFavoriteMeals);
    on<RateMeal>(_onRateMeal);
  }

  Future<void> _onLoadMeals(
    LoadMeals event,
    Emitter<MealPlannerState> emit,
  ) async {
    emit(MealPlannerLoading());
    try {
      final meals = await _mealRepository.getMeals(
        dietaryTypes: event.dietaryTypes,
        mealType: event.mealType,
        maxCalories: event.maxCalories,
        maxPreparationTime: event.maxPreparationTime,
      );
      emit(MealsLoaded(meals));
    } catch (e) {
      emit(MealPlannerError(e.toString()));
    }
  }

  Future<void> _onLoadMealDetails(
    LoadMealDetails event,
    Emitter<MealPlannerState> emit,
  ) async {
    emit(MealPlannerLoading());
    try {
      final meal = await _mealRepository.getMealById(event.mealId);
      emit(MealDetailsLoaded(meal));
    } catch (e) {
      emit(MealPlannerError(e.toString()));
    }
  }

  Future<void> _onLoadRecommendedMeals(
    LoadRecommendedMeals event,
    Emitter<MealPlannerState> emit,
  ) async {
    emit(MealPlannerLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      
      if (user == null) {
        emit(const MealPlannerError('User not authenticated'));
        return;
      }
      
      final userPreferences = user.preferences ?? {};
      final fitnessData = await _fitnessRepository.getLatestFitnessData();
      
      final meals = await _mealRepository.getRecommendedMeals(
        userPreferences: userPreferences,
        fitnessData: fitnessData,
      );
      
      emit(RecommendedMealsLoaded(meals));
    } catch (e) {
      emit(MealPlannerError(e.toString()));
    }
  }

  Future<void> _onToggleFavoriteMeal(
    ToggleFavoriteMeal event,
    Emitter<MealPlannerState> emit,
  ) async {
    try {
      await _mealRepository.toggleFavorite(event.mealId);
      
      // Refresh current state with updated favorite status
      if (state is MealDetailsLoaded) {
        final currentMeal = (state as MealDetailsLoaded).meal;
        if (currentMeal.id == event.mealId) {
          final updatedMeal = await _mealRepository.getMealById(event.mealId);
          emit(MealDetailsLoaded(updatedMeal));
        }
      } else if (state is MealsLoaded) {
        add(const LoadMeals());
      } else if (state is FavoriteMealsLoaded) {
        add(LoadFavoriteMeals());
      } else if (state is RecommendedMealsLoaded) {
        add(LoadRecommendedMeals());
      }
    } catch (e) {
      emit(MealPlannerError(e.toString()));
    }
  }

  Future<void> _onLoadFavoriteMeals(
    LoadFavoriteMeals event,
    Emitter<MealPlannerState> emit,
  ) async {
    emit(MealPlannerLoading());
    try {
      final meals = await _mealRepository.getFavoriteMeals();
      emit(FavoriteMealsLoaded(meals));
    } catch (e) {
      emit(MealPlannerError(e.toString()));
    }
  }

  Future<void> _onRateMeal(
    RateMeal event,
    Emitter<MealPlannerState> emit,
  ) async {
    try {
      await _mealRepository.rateMeal(event.mealId, event.rating);
      
      // Refresh meal details if we're on the details screen
      if (state is MealDetailsLoaded) {
        final currentMeal = (state as MealDetailsLoaded).meal;
        if (currentMeal.id == event.mealId) {
          final updatedMeal = await _mealRepository.getMealById(event.mealId);
          emit(MealDetailsLoaded(updatedMeal));
        }
      }
    } catch (e) {
      emit(MealPlannerError(e.toString()));
    }
  }
}
