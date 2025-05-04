import 'package:nutrio_wellness/features/meal_planner/data/models/meal_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class MealService {
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

class MealServiceImpl implements MealService {
  // This is a mock implementation for demonstration purposes
  // In a real app, you would use a real API service
  
  static const String _favoritesKey = 'favorite_meals';
  
  // Mock meal data
  final List<MealModel> _mockMeals = [
    MealModel(
      id: '1',
      name: 'Avocado Toast with Poached Eggs',
      description: 'A nutritious breakfast with creamy avocado and perfectly poached eggs on whole grain toast.',
      imageUrl: 'https://example.com/avocado_toast.jpg',
      calories: 350,
      preparationTime: 15,
      ingredients: [
        '2 slices whole grain bread',
        '1 ripe avocado',
        '2 eggs',
        '1 tbsp lemon juice',
        'Salt and pepper to taste',
        'Red pepper flakes (optional)',
      ],
      instructions: [
        'Toast the bread until golden and firm.',
        'While the bread is toasting, halve the avocado and remove the pit.',
        'Scoop the avocado flesh into a bowl and mash with a fork. Add lemon juice, salt, and pepper to taste.',
        'Bring a pot of water to a simmer. Add a splash of vinegar. Create a gentle whirlpool and crack an egg into the center. Cook for 3-4 minutes. Repeat with second egg.',
        'Spread the mashed avocado on the toast and top each with a poached egg.',
        'Season with salt, pepper, and red pepper flakes if desired.',
      ],
      nutritionFacts: {
        'protein': 14.0,
        'carbs': 30.0,
        'fat': 22.0,
        'fiber': 8.0,
      },
      mealType: MealType.breakfast,
      dietaryTypes: [DietaryType.vegetarian],
      rating: 4.7,
      reviewCount: 128,
    ),
    MealModel(
      id: '2',
      name: 'Grilled Chicken Salad with Avocado',
      description: 'A protein-packed salad with grilled chicken, fresh vegetables, and creamy avocado.',
      imageUrl: 'https://example.com/chicken_salad.jpg',
      calories: 420,
      preparationTime: 25,
      ingredients: [
        '6 oz grilled chicken breast',
        '2 cups mixed greens',
        '1 avocado, sliced',
        '1 cup cherry tomatoes, halved',
        '1/4 red onion, thinly sliced',
        '2 tbsp olive oil',
        '1 tbsp balsamic vinegar',
        'Salt and pepper to taste',
      ],
      instructions: [
        'Season chicken breast with salt and pepper. Grill until fully cooked, about 6-7 minutes per side.',
        'Let chicken rest for 5 minutes, then slice into strips.',
        'In a large bowl, combine mixed greens, cherry tomatoes, and red onion.',
        'Whisk together olive oil, balsamic vinegar, salt, and pepper to make the dressing.',
        'Add sliced chicken and avocado to the salad.',
        'Drizzle with dressing and serve immediately.',
      ],
      nutritionFacts: {
        'protein': 35.0,
        'carbs': 15.0,
        'fat': 28.0,
        'fiber': 9.0,
      },
      mealType: MealType.lunch,
      dietaryTypes: [DietaryType.glutenFree],
      rating: 4.5,
      reviewCount: 95,
    ),
    MealModel(
      id: '3',
      name: 'Vegan Buddha Bowl',
      description: 'A colorful and nutritious bowl filled with roasted vegetables, quinoa, and tahini dressing.',
      imageUrl: 'https://example.com/buddha_bowl.jpg',
      calories: 380,
      preparationTime: 35,
      ingredients: [
        '1 cup cooked quinoa',
        '1 sweet potato, diced and roasted',
        '1 cup chickpeas, roasted',
        '1 cup kale, massaged',
        '1/2 avocado, sliced',
        '1/4 cup red cabbage, shredded',
        '2 tbsp tahini',
        '1 tbsp lemon juice',
        '1 tbsp maple syrup',
        'Salt and pepper to taste',
      ],
      instructions: [
        'Preheat oven to 400°F (200°C).',
        'Toss diced sweet potato and chickpeas with olive oil, salt, and pepper. Roast for 25-30 minutes.',
        'Cook quinoa according to package instructions.',
        'Massage kale with a bit of olive oil and salt until softened.',
        'Whisk together tahini, lemon juice, maple syrup, and 2-3 tbsp water to make the dressing.',
        'Assemble the bowl with quinoa, roasted vegetables, kale, avocado, and cabbage.',
        'Drizzle with tahini dressing and serve.',
      ],
      nutritionFacts: {
        'protein': 15.0,
        'carbs': 55.0,
        'fat': 16.0,
        'fiber': 14.0,
      },
      mealType: MealType.dinner,
      dietaryTypes: [DietaryType.vegan, DietaryType.glutenFree],
      rating: 4.8,
      reviewCount: 112,
    ),
    MealModel(
      id: '4',
      name: 'Keto Bacon and Egg Cups',
      description: 'Easy and portable breakfast cups made with eggs, bacon, and cheese.',
      imageUrl: 'https://example.com/egg_cups.jpg',
      calories: 310,
      preparationTime: 25,
      ingredients: [
        '6 slices bacon',
        '6 large eggs',
        '1/4 cup shredded cheddar cheese',
        '2 tbsp heavy cream',
        '1 tbsp chopped chives',
        'Salt and pepper to taste',
      ],
      instructions: [
        'Preheat oven to 375°F (190°C).',
        'Line each cup of a muffin tin with a slice of bacon, creating a circle.',
        'Whisk together eggs, heavy cream, salt, and pepper.',
        'Pour egg mixture into each bacon-lined cup, filling about 3/4 full.',
        'Sprinkle cheese and chives on top.',
        'Bake for 15-18 minutes until eggs are set.',
        'Let cool slightly before removing from the tin.',
      ],
      nutritionFacts: {
        'protein': 19.0,
        'carbs': 1.0,
        'fat': 25.0,
        'fiber': 0.0,
      },
      mealType: MealType.breakfast,
      dietaryTypes: [DietaryType.keto, DietaryType.glutenFree],
      rating: 4.6,
      reviewCount: 87,
    ),
    MealModel(
      id: '5',
      name: 'Salmon with Roasted Vegetables',
      description: 'Perfectly cooked salmon fillet with a colorful medley of roasted vegetables.',
      imageUrl: 'https://example.com/salmon.jpg',
      calories: 450,
      preparationTime: 30,
      ingredients: [
        '6 oz salmon fillet',
        '1 cup broccoli florets',
        '1 cup cauliflower florets',
        '1 bell pepper, sliced',
        '1 tbsp olive oil',
        '1 lemon, sliced',
        '2 cloves garlic, minced',
        'Fresh dill',
        'Salt and pepper to taste',
      ],
      instructions: [
        'Preheat oven to 425°F (220°C).',
        'Toss vegetables with olive oil, garlic, salt, and pepper. Spread on a baking sheet.',
        'Roast vegetables for 15 minutes.',
        'Season salmon with salt and pepper. Place on top of vegetables.',
        'Top salmon with lemon slices and dill.',
        'Roast for an additional 12-15 minutes until salmon is cooked through.',
        'Serve immediately.',
      ],
      nutritionFacts: {
        'protein': 34.0,
        'carbs': 12.0,
        'fat': 28.0,
        'fiber': 5.0,
      },
      mealType: MealType.dinner,
      dietaryTypes: [DietaryType.paleo, DietaryType.glutenFree, DietaryType.dairyFree],
      rating: 4.9,
      reviewCount: 156,
    ),
  ];

  @override
  Future<List<MealModel>> getMeals({
    List<DietaryType>? dietaryTypes,
    MealType? mealType,
    int? maxCalories,
    int? maxPreparationTime,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Filter meals based on criteria
    return _mockMeals.where((meal) {
      bool matchesDietaryTypes = dietaryTypes == null || 
          dietaryTypes.isEmpty || 
          dietaryTypes.any((type) => meal.dietaryTypes.contains(type));
      
      bool matchesMealType = mealType == null || meal.mealType == mealType;
      
      bool matchesCalories = maxCalories == null || meal.calories <= maxCalories;
      
      bool matchesPreparationTime = maxPreparationTime == null || 
          meal.preparationTime <= maxPreparationTime;
      
      return matchesDietaryTypes && matchesMealType && matchesCalories && matchesPreparationTime;
    }).toList();
  }

  @override
  Future<MealModel> getMealById(String id) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Find meal by ID
    final meal = _mockMeals.firstWhere(
      (meal) => meal.id == id,
      orElse: () => throw Exception('Meal not found'),
    );
    
    // Check if meal is favorite
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    
    return meal.copyWith(isFavorite: favorites.contains(meal.id));
  }

  @override
  Future<List<MealModel>> getRecommendedMeals({
    required Map<String, dynamic> userPreferences,
    required Map<String, dynamic> fitnessData,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, this would use a recommendation algorithm based on user preferences and fitness data
    // For now, we'll just return a subset of meals that might match dietary preferences
    
    List<DietaryType> preferredDietaryTypes = [];
    
    if (userPreferences.containsKey('dietaryPreferences')) {
      final preferences = userPreferences['dietaryPreferences'] as List<dynamic>;
      
      if (preferences.contains('vegetarian')) {
        preferredDietaryTypes.add(DietaryType.vegetarian);
      }
      
      if (preferences.contains('vegan')) {
        preferredDietaryTypes.add(DietaryType.vegan);
      }
      
      if (preferences.contains('keto')) {
        preferredDietaryTypes.add(DietaryType.keto);
      }
      
      if (preferences.contains('paleo')) {
        preferredDietaryTypes.add(DietaryType.paleo);
      }
    }
    
    // Calculate recommended calorie intake based on fitness data
    int recommendedCalories = 2000; // Default value
    
    if (fitnessData.containsKey('caloriesBurned')) {
      final caloriesBurned = fitnessData['caloriesBurned'] as int;
      recommendedCalories += (caloriesBurned ~/ 3); // Adjust based on activity
    }
    
    // Get meals that match preferences and calorie needs
    final meals = await getMeals(
      dietaryTypes: preferredDietaryTypes.isNotEmpty ? preferredDietaryTypes : null,
      maxCalories: (recommendedCalories / 3).round(), // Roughly one meal's worth
    );
    
    // Sort by rating to get the best recommendations first
    meals.sort((a, b) => b.rating.compareTo(a.rating));
    
    return meals.take(3).toList(); // Return top 3 recommendations
  }

  @override
  Future<void> toggleFavorite(String mealId) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    
    if (favorites.contains(mealId)) {
      favorites.remove(mealId);
    } else {
      favorites.add(mealId);
    }
    
    await prefs.setStringList(_favoritesKey, favorites);
  }

  @override
  Future<List<MealModel>> getFavoriteMeals() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    
    return _mockMeals
        .where((meal) => favorites.contains(meal.id))
        .map((meal) => meal.copyWith(isFavorite: true))
        .toList();
  }

  @override
  Future<void> rateMeal(String mealId, double rating) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // In a real app, this would update the rating in the backend
    // For this mock implementation, we don't actually update the ratings
  }
}
