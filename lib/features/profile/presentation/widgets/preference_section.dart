import 'package:flutter/material.dart';
import 'package:nutrio_wellness/core/theme/app_colors.dart';

class PreferenceSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> preferences;
  final VoidCallback onEditPressed;

  const PreferenceSection({
    Key? key,
    required this.title,
    required this.icon,
    required this.preferences,
    required this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onEditPressed,
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: preferences.map((preference) {
            return Chip(
              label: Text(preference),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              labelStyle: const TextStyle(
                color: AppColors.primary,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            );
          }).toList(),
        ),
      ],
    );
  }
}
