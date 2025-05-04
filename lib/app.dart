import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrio_wellness/core/theme/app_theme.dart';
import 'package:nutrio_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nutrio_wellness/features/meal_planner/presentation/bloc/meal_planner_bloc.dart';
import 'package:nutrio_wellness/features/fitness/presentation/bloc/fitness_bloc.dart';
import 'package:nutrio_wellness/features/order_tracking/presentation/bloc/order_tracking_bloc.dart';
import 'package:nutrio_wellness/routes.dart';

class NutrioWellnessApp extends StatelessWidget {
  const NutrioWellnessApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        BlocProvider<MealPlannerBloc>(
          create: (context) => MealPlannerBloc(),
        ),
        BlocProvider<FitnessBloc>(
          create: (context) => FitnessBloc(),
        ),
        BlocProvider<OrderTrackingBloc>(
          create: (context) => OrderTrackingBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Nutrio Wellness',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
