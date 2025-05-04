import 'package:get_it/get_it.dart';
import 'package:nutrio_wellness/features/auth/data/repositories/auth_repository.dart';
import 'package:nutrio_wellness/features/auth/data/services/auth_service.dart';
import 'package:nutrio_wellness/features/meal_planner/data/repositories/meal_repository.dart';
import 'package:nutrio_wellness/features/meal_planner/data/services/meal_service.dart';
import 'package:nutrio_wellness/features/fitness/data/repositories/fitness_repository.dart';
import 'package:nutrio_wellness/features/fitness/data/services/fitness_service.dart';
import 'package:nutrio_wellness/features/fitness/data/services/fitness_service_impl.dart';
import 'package:nutrio_wellness/features/fitness/data/services/fitbit_auth_service.dart';
import 'package:nutrio_wellness/features/order_tracking/data/repositories/order_repository.dart';
import 'package:nutrio_wellness/features/order_tracking/data/services/order_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External services
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Services
  getIt.registerLazySingleton<AuthService>(() => AuthServiceImpl());
  getIt.registerLazySingleton<MealService>(() => MealServiceImpl());
  getIt.registerLazySingleton<FitnessService>(() => RealFitnessServiceImpl());
  getIt.registerLazySingleton<OrderService>(() => OrderServiceImpl());

  // Fitbit Auth Service
  getIt.registerLazySingleton<FitbitAuthService>(() => FitbitAuthService(
    clientId: 'YOUR_FITBIT_CLIENT_ID', // Replace with your actual Fitbit client ID
    clientSecret: 'YOUR_FITBIT_CLIENT_SECRET', // Replace with your actual Fitbit client secret
    redirectUri: 'nutriowellness://fitbit/auth',
  ));

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt<AuthService>()));
  getIt.registerLazySingleton<MealRepository>(() => MealRepositoryImpl(getIt<MealService>()));
  getIt.registerLazySingleton<FitnessRepository>(() => FitnessRepositoryImpl(getIt<FitnessService>()));
  getIt.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl(getIt<OrderService>()));
}
