import 'package:flutter/material.dart';
import 'package:nutrio_wellness/core/theme/app_colors.dart';
import 'package:nutrio_wellness/features/meal_planner/data/models/meal_model.dart';

class DietaryTag extends StatelessWidget {
  final DietaryType type;
  final bool small;

  const DietaryTag({
    Key? key,
    required this.type,
    this.small = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getColor()),
      ),
      child: Text(
        _getLabel(),
        style: TextStyle(
          color: _getColor(),
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getLabel() {
    switch (type) {
      case DietaryType.vegetarian:
        return 'Vegetarian';
      case DietaryType.vegan:
        return 'Vegan';
      case DietaryType.keto:
        return 'Keto';
      case DietaryType.paleo:
        return 'Paleo';
      case DietaryType.glutenFree:
        return 'Gluten-Free';
      case DietaryType.dairyFree:
        return 'Dairy-Free';
      case DietaryType.nutFree:
        return 'Nut-Free';
      case DietaryType.regular:
        return 'Regular';
    }
  }

  Color _getColor() {
    switch (type) {
      case DietaryType.vegetarian:
        return Colors.green;
      case DietaryType.vegan:
        return Colors.green.shade800;
      case DietaryType.keto:
        return Colors.purple;
      case DietaryType.paleo:
        return Colors.brown;
      case DietaryType.glutenFree:
        return Colors.amber.shade700;
      case DietaryType.dairyFree:
        return Colors.blue;
      case DietaryType.nutFree:
        return Colors.orange;
      case DietaryType.regular:
        return AppColors.textSecondary;
    }
  }
}
