import 'package:flutter/material.dart';
import 'package:nutrio_wellness/features/auth/presentation/screens/login_screen.dart';
import 'package:nutrio_wellness/features/auth/presentation/screens/register_screen.dart';
import 'package:nutrio_wellness/features/meal_planner/presentation/screens/meal_detail_screen.dart';
import 'package:nutrio_wellness/features/meal_planner/presentation/screens/meal_planner_screen.dart';
import 'package:nutrio_wellness/features/fitness/presentation/screens/fitness_dashboard_screen.dart';
import 'package:nutrio_wellness/features/fitness/presentation/screens/fitness_connection_screen.dart';
import 'package:nutrio_wellness/features/order_tracking/presentation/screens/order_chat_screen.dart';
import 'package:nutrio_wellness/features/order_tracking/presentation/screens/order_tracking_screen.dart';
import 'package:nutrio_wellness/features/profile/presentation/screens/profile_screen.dart';
import 'package:nutrio_wellness/presentation/screens/home_screen.dart';
import 'package:nutrio_wellness/presentation/screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String mealPlanner = '/meal-planner';
  static const String mealDetail = '/meal-detail';
  static const String fitnessDashboard = '/fitness-dashboard';
  static const String fitnessConnection = '/fitness-connection';
  static const String orderTracking = '/order-tracking';
  static const String orderChat = '/order-chat';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRoutes.mealPlanner:
        return MaterialPageRoute(builder: (_) => const MealPlannerScreen());
      case AppRoutes.mealDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => MealDetailScreen(mealId: args['mealId']),
        );
      case AppRoutes.fitnessDashboard:
        return MaterialPageRoute(builder: (_) => const FitnessDashboardScreen());
      case AppRoutes.fitnessConnection:
        return MaterialPageRoute(builder: (_) => const FitnessConnectionScreen());
      case AppRoutes.orderTracking:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => OrderTrackingScreen(orderId: args['orderId']),
        );
      case AppRoutes.orderChat:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => OrderChatScreen(orderId: args['orderId']),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
