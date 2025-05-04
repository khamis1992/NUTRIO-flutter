import 'package:flutter/material.dart';
import 'package:nutrio_wellness/core/theme/app_colors.dart';
import 'package:nutrio_wellness/features/meal_planner/data/models/meal_model.dart';
import 'package:nutrio_wellness/features/meal_planner/presentation/widgets/dietary_tag.dart';

class RecommendedMealCard extends StatelessWidget {
  final MealModel meal;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const RecommendedMealCard({
    Key? key,
    required this.meal,
    required this.onTap,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal image and info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: Image.network(
                      meal.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.primary.withOpacity(0.2),
                          child: const Icon(
                            Icons.restaurant,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Meal info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                meal.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: onFavoriteToggle,
                              child: Icon(
                                meal.isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: meal.isFavorite ? Colors.red : Colors.grey,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          meal.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              meal.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${meal.reviewCount})',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.access_time,
                              color: AppColors.textSecondary,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${meal.preparationTime} min',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Dietary tags and nutrition info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Divider
                  const Divider(),
                  
                  // Dietary tags
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: meal.dietaryTypes.map((type) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: DietaryTag(type: type, small: true),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Nutrition info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNutritionInfo(
                        'Calories',
                        '${meal.calories}',
                        'kcal',
                      ),
                      _buildNutritionInfo(
                        'Protein',
                        '${meal.nutritionFacts['protein']}',
                        'g',
                      ),
                      _buildNutritionInfo(
                        'Carbs',
                        '${meal.nutritionFacts['carbs']}',
                        'g',
                      ),
                      _buildNutritionInfo(
                        'Fat',
                        '${meal.nutritionFacts['fat']}',
                        'g',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionInfo(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            style: const TextStyle(color: AppColors.textPrimary),
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: unit,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
