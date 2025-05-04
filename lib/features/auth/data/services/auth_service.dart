import 'package:nutrio_wellness/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthService {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({required String name, required String email, required String password});
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<void> updateUserProfile({required UserModel user});
  Future<void> updateUserPreferences({required Map<String, dynamic> preferences});
}

class AuthServiceImpl implements AuthService {
  // This is a mock implementation for demonstration purposes
  // In a real app, you would use Firebase Auth or another authentication service
  
  static const String _userKey = 'current_user';
  
  @override
  Future<UserModel> login({required String email, required String password}) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock login logic
    if (email == 'test@example.com' && password == 'password') {
      final user = UserModel(
        id: '1',
        name: 'Test User',
        email: email,
        photoUrl: null,
        preferences: {
          'dietaryPreferences': ['vegetarian'],
          'allergies': ['nuts', 'dairy'],
          'fitnessGoals': ['weight_loss', 'muscle_gain'],
        },
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );
      
      // Save user to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, user.toJson().toString());
      
      return user;
    } else {
      throw Exception('Invalid email or password');
    }
  }

  @override
  Future<UserModel> register({required String name, required String email, required String password}) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock registration logic
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      photoUrl: null,
      preferences: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Save user to local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.toJson().toString());
    
    return user;
  }

  @override
  Future<void> logout() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Clear user from local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Get user from local storage
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson != null) {
      try {
        return UserModel.fromJson(userJson as Map<String, dynamic>);
      } catch (e) {
        return null;
      }
    }
    
    return null;
  }

  @override
  Future<void> updateUserProfile({required UserModel user}) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Update user in local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.toJson().toString());
  }

  @override
  Future<void> updateUserPreferences({required Map<String, dynamic> preferences}) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Get current user
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson != null) {
      try {
        final user = UserModel.fromJson(userJson as Map<String, dynamic>);
        final updatedUser = user.copyWith(
          preferences: preferences,
          updatedAt: DateTime.now(),
        );
        
        // Save updated user
        await prefs.setString(_userKey, updatedUser.toJson().toString());
      } catch (e) {
        throw Exception('Failed to update preferences: ${e.toString()}');
      }
    } else {
      throw Exception('User not found');
    }
  }
}
