import 'package:flutter/material.dart';
import 'package:nutrio_wellness/core/theme/app_colors.dart';
import 'package:nutrio_wellness/features/meal_planner/data/models/meal_model.dart';

class MealTypeSelector extends StatelessWidget {
  final MealType? selectedMealType;
  final Function(MealType?) onMealTypeSelected;

  const MealTypeSelector({
    Key? key,
    required this.selectedMealType,
    required this.onMealTypeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildMealTypeButton(
            context,
            null,
            'All',
            Icons.restaurant_menu,
          ),
          _buildMealTypeButton(
            context,
            MealType.breakfast,
            'Breakfast',
            Icons.free_breakfast,
          ),
          _buildMealTypeButton(
            context,
            MealType.lunch,
            'Lunch',
            Icons.lunch_dining,
          ),
          _buildMealTypeButton(
            context,
            MealType.dinner,
            'Dinner',
            Icons.dinner_dining,
          ),
          _buildMealTypeButton(
            context,
            MealType.snack,
            'Snack',
            Icons.cookie,
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeButton(
    BuildContext context,
    MealType? mealType,
    String label,
    IconData icon,
  ) {
    final isSelected = selectedMealType == mealType;
    
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => onMealTypeSelected(mealType),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
