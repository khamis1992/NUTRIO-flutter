import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrio_wellness/core/theme/app_colors.dart';
import 'package:nutrio_wellness/features/meal_planner/data/models/meal_model.dart';
import 'package:nutrio_wellness/features/meal_planner/presentation/bloc/meal_planner_bloc.dart';
import 'package:nutrio_wellness/features/meal_planner/presentation/widgets/dietary_filter_chip.dart';
import 'package:nutrio_wellness/features/meal_planner/presentation/widgets/meal_card.dart';
import 'package:nutrio_wellness/features/meal_planner/presentation/widgets/meal_type_selector.dart';
import 'package:nutrio_wellness/features/meal_planner/presentation/widgets/recommended_meal_card.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({Key? key}) : super(key: key);

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<DietaryType> _selectedDietaryTypes = [];
  MealType? _selectedMealType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load initial data
    _loadRecommendedMeals();
    _loadMeals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadRecommendedMeals() {
    context.read<MealPlannerBloc>().add(LoadRecommendedMeals());
  }

  void _loadMeals() {
    context.read<MealPlannerBloc>().add(
      LoadMeals(
        dietaryTypes: _selectedDietaryTypes.isNotEmpty ? _selectedDietaryTypes : null,
        mealType: _selectedMealType,
      ),
    );
  }

  void _loadFavoriteMeals() {
    context.read<MealPlannerBloc>().add(LoadFavoriteMeals());
  }

  void _toggleDietaryType(DietaryType type) {
    setState(() {
      if (_selectedDietaryTypes.contains(type)) {
        _selectedDietaryTypes.remove(type);
      } else {
        _selectedDietaryTypes.add(type);
      }
    });
    _loadMeals();
  }

  void _selectMealType(MealType? type) {
    setState(() {
      _selectedMealType = type;
    });
    _loadMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            if (index == 0) {
              _loadRecommendedMeals();
            } else if (index == 1) {
              _loadMeals();
            } else if (index == 2) {
              _loadFavoriteMeals();
            }
          },
          tabs: const [
            Tab(text: 'Recommended'),
            Tab(text: 'Browse'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecommendedTab(),
          _buildBrowseTab(),
          _buildFavoritesTab(),
        ],
      ),
    );
  }

  Widget _buildRecommendedTab() {
    return BlocBuilder<MealPlannerBloc, MealPlannerState>(
      builder: (context, state) {
        if (state is MealPlannerLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RecommendedMealsLoaded) {
          final meals = state.meals;
          
          if (meals.isEmpty) {
            return const Center(
              child: Text(
                'No recommended meals found.\nUpdate your preferences to get personalized recommendations.',
                textAlign: TextAlign.center,
              ),
            );
          }
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Recommended For You',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Based on your preferences and activity',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ...meals.map((meal) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RecommendedMealCard(
                  meal: meal,
                  onTap: () {
                    // Navigate to meal details
                  },
                  onFavoriteToggle: () {
                    context.read<MealPlannerBloc>().add(ToggleFavoriteMeal(meal.id));
                  },
                ),
              )),
            ],
          );
        } else if (state is MealPlannerError) {
          return Center(
            child: Text(
              'Error: ${state.message}',
              textAlign: TextAlign.center,
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildBrowseTab() {
    return Column(
      children: [
        // Filters section
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dietary Preferences',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    DietaryFilterChip(
                      label: 'Vegetarian',
                      isSelected: _selectedDietaryTypes.contains(DietaryType.vegetarian),
                      onSelected: (_) => _toggleDietaryType(DietaryType.vegetarian),
                    ),
                    DietaryFilterChip(
                      label: 'Vegan',
                      isSelected: _selectedDietaryTypes.contains(DietaryType.vegan),
                      onSelected: (_) => _toggleDietaryType(DietaryType.vegan),
                    ),
                    DietaryFilterChip(
                      label: 'Keto',
                      isSelected: _selectedDietaryTypes.contains(DietaryType.keto),
                      onSelected: (_) => _toggleDietaryType(DietaryType.keto),
                    ),
                    DietaryFilterChip(
                      label: 'Paleo',
                      isSelected: _selectedDietaryTypes.contains(DietaryType.paleo),
                      onSelected: (_) => _toggleDietaryType(DietaryType.paleo),
                    ),
                    DietaryFilterChip(
                      label: 'Gluten-Free',
                      isSelected: _selectedDietaryTypes.contains(DietaryType.glutenFree),
                      onSelected: (_) => _toggleDietaryType(DietaryType.glutenFree),
                    ),
                    DietaryFilterChip(
                      label: 'Dairy-Free',
                      isSelected: _selectedDietaryTypes.contains(DietaryType.dairyFree),
                      onSelected: (_) => _toggleDietaryType(DietaryType.dairyFree),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Meal Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              MealTypeSelector(
                selectedMealType: _selectedMealType,
                onMealTypeSelected: _selectMealType,
              ),
            ],
          ),
        ),
        
        // Meals list
        Expanded(
          child: BlocBuilder<MealPlannerBloc, MealPlannerState>(
            builder: (context, state) {
              if (state is MealPlannerLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is MealsLoaded) {
                final meals = state.meals;
                
                if (meals.isEmpty) {
                  return const Center(
                    child: Text(
                      'No meals found matching your filters.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    return MealCard(
                      meal: meal,
                      onTap: () {
                        // Navigate to meal details
                      },
                      onFavoriteToggle: () {
                        context.read<MealPlannerBloc>().add(ToggleFavoriteMeal(meal.id));
                      },
                    );
                  },
                );
              } else if (state is MealPlannerError) {
                return Center(
                  child: Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesTab() {
    return BlocBuilder<MealPlannerBloc, MealPlannerState>(
      builder: (context, state) {
        if (state is MealPlannerLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is FavoriteMealsLoaded) {
          final meals = state.meals;
          
          if (meals.isEmpty) {
            return const Center(
              child: Text(
                'No favorite meals yet.\nAdd meals to your favorites to see them here.',
                textAlign: TextAlign.center,
              ),
            );
          }
          
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final meal = meals[index];
              return MealCard(
                meal: meal,
                onTap: () {
                  // Navigate to meal details
                },
                onFavoriteToggle: () {
                  context.read<MealPlannerBloc>().add(ToggleFavoriteMeal(meal.id));
                },
              );
            },
          );
        } else if (state is MealPlannerError) {
          return Center(
            child: Text(
              'Error: ${state.message}',
              textAlign: TextAlign.center,
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
