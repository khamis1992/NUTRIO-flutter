// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealModel _$MealModelFromJson(Map<String, dynamic> json) => MealModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      calories: json['calories'] as int,
      preparationTime: json['preparationTime'] as int,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      instructions: (json['instructions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      nutritionFacts: (json['nutritionFacts'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      mealType: $enumDecode(_$MealTypeEnumMap, json['mealType']),
      dietaryTypes: (json['dietaryTypes'] as List<dynamic>)
          .map((e) => $enumDecode(_$DietaryTypeEnumMap, e))
          .toList(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );

Map<String, dynamic> _$MealModelToJson(MealModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'calories': instance.calories,
      'preparationTime': instance.preparationTime,
      'ingredients': instance.ingredients,
      'instructions': instance.instructions,
      'nutritionFacts': instance.nutritionFacts,
      'mealType': _$MealTypeEnumMap[instance.mealType]!,
      'dietaryTypes': instance.dietaryTypes
          .map((e) => _$DietaryTypeEnumMap[e]!)
          .toList(),
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'isFavorite': instance.isFavorite,
    };

const _$MealTypeEnumMap = {
  MealType.breakfast: 'breakfast',
  MealType.lunch: 'lunch',
  MealType.dinner: 'dinner',
  MealType.snack: 'snack',
};

const _$DietaryTypeEnumMap = {
  DietaryType.regular: 'regular',
  DietaryType.vegetarian: 'vegetarian',
  DietaryType.vegan: 'vegan',
  DietaryType.keto: 'keto',
  DietaryType.paleo: 'paleo',
  DietaryType.glutenFree: 'glutenFree',
  DietaryType.dairyFree: 'dairyFree',
  DietaryType.nutFree: 'nutFree',
};
