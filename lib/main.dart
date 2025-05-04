import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutrio_wellness/app.dart';
import 'package:nutrio_wellness/core/services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize service locator
  await setupServiceLocator();
  
  runApp(const NutrioWellnessApp());
}
