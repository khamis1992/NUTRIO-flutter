# Nutrio Wellness

A comprehensive health and wellness Flutter application that provides personalized meal recommendations, fitness tracking integration, and real-time order tracking.

## Features

### Personalized Meal Recommendations
- Browse and filter meals by dietary preferences (vegan, keto, gluten-free, etc.)
- View detailed nutritional information for each meal
- Get personalized meal recommendations based on preferences and fitness data
- Save favorite meals for quick access

### Fitness Tracking Integration
- Connect with popular fitness platforms (Apple Health, Google Fit, Fitbit)
- Track steps, distance, calories burned, and active minutes
- Monitor sleep and water intake
- Log and track workout sessions
- View weekly fitness summaries and trends

### Real-time Order Tracking
- Place orders for healthy meals
- Track order status in real-time
- View delivery location on map
- Chat with delivery riders
- View order history and details

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio or VS Code with Flutter extensions
- An emulator or physical device for testing

### Installation
1. Clone the repository:
```
git clone https://github.com/yourusername/nutrio_wellness.git
```

2. Navigate to the project directory:
```
cd nutrio_wellness
```

3. Install dependencies:
```
flutter pub get
```

4. Run the app:
```
flutter run
```

## Project Structure

```
lib/
├── core/                 # Core utilities and constants
│   ├── theme/            # App theme configuration
│   └── services/         # Core services
├── data/                 # Data layer
│   ├── models/           # Data models
│   ├── repositories/     # Data repositories
│   └── services/         # API services
├── features/             # Feature modules
│   ├── auth/             # Authentication
│   ├── meal_planner/     # Meal planning and recommendations
│   ├── fitness/          # Fitness tracking
│   ├── order_tracking/   # Order and delivery tracking
│   └── profile/          # User profile
├── presentation/         # Shared presentation components
│   ├── screens/          # App screens
│   └── widgets/          # Reusable widgets
├── app.dart              # App configuration
├── main.dart             # Entry point
└── routes.dart           # App routes
```

## Technologies Used

- **Flutter**: UI framework
- **Bloc**: State management
- **Dio**: Network requests
- **Google Maps**: For order tracking
- **Health**: For fitness tracking integration
- **Firebase**: Authentication and backend services

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- All the open-source packages used in this project
