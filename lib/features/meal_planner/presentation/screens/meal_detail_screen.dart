import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrio_wellness/core/theme/app_colors.dart';
import 'package:nutrio_wellness/features/meal_planner/data/models/meal_model.dart';
import 'package:nutrio_wellness/features/meal_planner/presentation/bloc/meal_planner_bloc.dart';
import 'package:nutrio_wellness/features/meal_planner/presentation/widgets/dietary_tag.dart';
import 'package:nutrio_wellness/features/meal_planner/presentation/widgets/nutrition_fact_card.dart';
import 'package:nutrio_wellness/routes.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealId;

  const MealDetailScreen({
    Key? key,
    required this.mealId,
  }) : super(key: key);

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadMealDetails();
  }

  void _loadMealDetails() {
    context.read<MealPlannerBloc>().add(LoadMealDetails(widget.mealId));
  }

  void _toggleFavorite(String mealId) {
    context.read<MealPlannerBloc>().add(ToggleFavoriteMeal(mealId));
  }

  void _orderMeal(MealModel meal) {
    // Navigate to order screen with meal details
    Navigator.of(context).pushNamed(
      AppRoutes.orderTracking,
      arguments: {'mealId': meal.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MealPlannerBloc, MealPlannerState>(
        builder: (context, state) {
          if (state is MealPlannerLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MealDetailsLoaded) {
            final meal = state.meal;
            return _buildMealDetails(meal);
          } else if (state is MealPlannerError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadMealDetails,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildMealDetails(MealModel meal) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  meal.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.primary.withOpacity(0.2),
                      child: const Icon(
                        Icons.restaurant,
                        size: 80,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${meal.preparationTime} min',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${meal.calories} cal',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                meal.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: meal.isFavorite ? Colors.red : Colors.white,
              ),
              onPressed: () => _toggleFavorite(meal.id),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dietary tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: meal.dietaryTypes.map((type) {
                    return DietaryTag(type: type);
                  }).toList(),
                ),
                const SizedBox(height: 16),
                
                // Description
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(meal.description),
                const SizedBox(height: 24),
                
                // Nutrition facts
                const Text(
                  'Nutrition Facts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    NutritionFactCard(
                      title: 'Calories',
                      value: '${meal.calories}',
                      unit: 'kcal',
                      color: AppColors.primary,
                    ),
                    NutritionFactCard(
                      title: 'Protein',
                      value: '${meal.nutritionFacts['protein']}',
                      unit: 'g',
                      color: AppColors.fitness,
                    ),
                    NutritionFactCard(
                      title: 'Carbs',
                      value: '${meal.nutritionFacts['carbs']}',
                      unit: 'g',
                      color: AppColors.accent,
                    ),
                    NutritionFactCard(
                      title: 'Fat',
                      value: '${meal.nutritionFacts['fat']}',
                      unit: 'g',
                      color: AppColors.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Ingredients
                const Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...meal.ingredients.map((ingredient) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(ingredient)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
                
                // Instructions
                const Text(
                  'Instructions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(meal.instructions.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(meal.instructions[index])),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 32),
                
                // Order button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _orderMeal(meal),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Order Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
