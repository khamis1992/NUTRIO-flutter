import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meal_model.g.dart';

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack
}

enum DietaryType {
  regular,
  vegetarian,
  vegan,
  keto,
  paleo,
  glutenFree,
  dairyFree,
  nutFree
}

@JsonSerializable()
class MealModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int calories;
  final int preparationTime; // in minutes
  final List<String> ingredients;
  final List<String> instructions;
  final Map<String, double> nutritionFacts; // protein, carbs, fat, etc.
  final MealType mealType;
  final List<DietaryType> dietaryTypes;
  final double rating;
  final int reviewCount;
  final bool isFavorite;

  const MealModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.calories,
    required this.preparationTime,
    required this.ingredients,
    required this.instructions,
    required this.nutritionFacts,
    required this.mealType,
    required this.dietaryTypes,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isFavorite = false,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) => _$MealModelFromJson(json);

  Map<String, dynamic> toJson() => _$MealModelToJson(this);

  MealModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    int? calories,
    int? preparationTime,
    List<String>? ingredients,
    List<String>? instructions,
    Map<String, double>? nutritionFacts,
    MealType? mealType,
    List<DietaryType>? dietaryTypes,
    double? rating,
    int? reviewCount,
    bool? isFavorite,
  }) {
    return MealModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      calories: calories ?? this.calories,
      preparationTime: preparationTime ?? this.preparationTime,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      nutritionFacts: nutritionFacts ?? this.nutritionFacts,
      mealType: mealType ?? this.mealType,
      dietaryTypes: dietaryTypes ?? this.dietaryTypes,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        calories,
        preparationTime,
        ingredients,
        instructions,
        nutritionFacts,
        mealType,
        dietaryTypes,
        rating,
        reviewCount,
        isFavorite,
      ];
}
