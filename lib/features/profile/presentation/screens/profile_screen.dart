import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrio_wellness/core/theme/app_colors.dart';
import 'package:nutrio_wellness/features/auth/data/models/user_model.dart';
import 'package:nutrio_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nutrio_wellness/features/profile/presentation/widgets/preference_section.dart';
import 'package:nutrio_wellness/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:nutrio_wellness/routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return _buildProfileContent(context, state.user);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to edit profile screen
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Dietary preferences
          PreferenceSection(
            title: 'Dietary Preferences',
            icon: Icons.restaurant_menu,
            preferences: _getDietaryPreferences(user),
            onEditPressed: () {
              // Navigate to edit dietary preferences screen
            },
          ),
          const SizedBox(height: 24),

          // Allergies
          PreferenceSection(
            title: 'Allergies & Restrictions',
            icon: Icons.warning_amber,
            preferences: _getAllergies(user),
            onEditPressed: () {
              // Navigate to edit allergies screen
            },
          ),
          const SizedBox(height: 24),

          // Fitness goals
          PreferenceSection(
            title: 'Fitness Goals',
            icon: Icons.fitness_center,
            preferences: _getFitnessGoals(user),
            onEditPressed: () {
              // Navigate to edit fitness goals screen
            },
          ),
          const SizedBox(height: 32),

          // Menu items
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ProfileMenuItem(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () {
              // Navigate to notifications settings
            },
          ),
          ProfileMenuItem(
            icon: Icons.payment,
            title: 'Payment Methods',
            onTap: () {
              // Navigate to payment methods
            },
          ),
          ProfileMenuItem(
            icon: Icons.location_on,
            title: 'Delivery Addresses',
            onTap: () {
              // Navigate to delivery addresses
            },
          ),
          ProfileMenuItem(
            icon: Icons.help,
            title: 'Help & Support',
            onTap: () {
              // Navigate to help & support
            },
          ),
          ProfileMenuItem(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () {
              // Navigate to privacy policy
            },
          ),
          ProfileMenuItem(
            icon: Icons.description,
            title: 'Terms of Service',
            onTap: () {
              // Navigate to terms of service
            },
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () => _confirmLogout(context),
              child: const Text(
                'Log Out',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<String> _getDietaryPreferences(UserModel user) {
    final preferences = user.preferences;
    if (preferences == null || !preferences.containsKey('dietaryPreferences')) {
      return ['None set'];
    }

    final dietaryPreferences = preferences['dietaryPreferences'] as List<dynamic>;
    if (dietaryPreferences.isEmpty) {
      return ['None set'];
    }

    return dietaryPreferences.map((pref) => _formatPreference(pref.toString())).toList();
  }

  List<String> _getAllergies(UserModel user) {
    final preferences = user.preferences;
    if (preferences == null || !preferences.containsKey('allergies')) {
      return ['None set'];
    }

    final allergies = preferences['allergies'] as List<dynamic>;
    if (allergies.isEmpty) {
      return ['None set'];
    }

    return allergies.map((allergy) => _formatPreference(allergy.toString())).toList();
  }

  List<String> _getFitnessGoals(UserModel user) {
    final preferences = user.preferences;
    if (preferences == null || !preferences.containsKey('fitnessGoals')) {
      return ['None set'];
    }

    final fitnessGoals = preferences['fitnessGoals'] as List<dynamic>;
    if (fitnessGoals.isEmpty) {
      return ['None set'];
    }

    return fitnessGoals.map((goal) => _formatPreference(goal.toString())).toList();
  }

  String _formatPreference(String preference) {
    // Convert snake_case or camelCase to Title Case with spaces
    final words = preference.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => ' ${match.group(0)}',
    ).split('_');

    return words.map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}').join(' ');
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
