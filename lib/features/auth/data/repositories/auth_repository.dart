import 'package:nutrio_wellness/features/auth/data/models/user_model.dart';
import 'package:nutrio_wellness/features/auth/data/services/auth_service.dart';

abstract class AuthRepository {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({required String name, required String email, required String password});
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<void> updateUserProfile({required UserModel user});
  Future<void> updateUserPreferences({required Map<String, dynamic> preferences});
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Future<UserModel> login({required String email, required String password}) async {
    try {
      return await _authService.login(email: email, password: password);
    } catch (e) {
      throw Exception('Failed to login: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register({required String name, required String email, required String password}) async {
    try {
      return await _authService.register(name: name, email: email, password: password);
    } catch (e) {
      throw Exception('Failed to register: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      throw Exception('Failed to logout: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      return await _authService.getCurrentUser();
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserProfile({required UserModel user}) async {
    try {
      await _authService.updateUserProfile(user: user);
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserPreferences({required Map<String, dynamic> preferences}) async {
    try {
      await _authService.updateUserPreferences(preferences: preferences);
    } catch (e) {
      throw Exception('Failed to update user preferences: ${e.toString()}');
    }
  }
}
