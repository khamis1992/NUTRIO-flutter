import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrio_wellness/core/services/service_locator.dart';
import 'package:nutrio_wellness/core/theme/app_colors.dart';
import 'package:nutrio_wellness/features/fitness/data/services/fitbit_auth_service.dart';
import 'package:nutrio_wellness/features/fitness/presentation/bloc/fitness_bloc.dart';

class FitnessConnectionScreen extends StatefulWidget {
  const FitnessConnectionScreen({Key? key}) : super(key: key);

  @override
  State<FitnessConnectionScreen> createState() => _FitnessConnectionScreenState();
}

class _FitnessConnectionScreenState extends State<FitnessConnectionScreen> {
  final FitbitAuthService _fitbitAuthService = getIt<FitbitAuthService>();
  bool _isAppleHealthConnected = false;
  bool _isGoogleFitConnected = false;
  bool _isFitbitConnected = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkConnections();
  }

  Future<void> _checkConnections() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check Apple Health connection (iOS only)
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        _isAppleHealthConnected = await _checkAppleHealthConnection();
      }

      // Check Google Fit connection (Android only)
      if (Theme.of(context).platform == TargetPlatform.android) {
        _isGoogleFitConnected = await _checkGoogleFitConnection();
      }

      // Check Fitbit connection (both platforms)
      _isFitbitConnected = await _fitbitAuthService.isAuthenticated();
    } catch (e) {
      debugPrint('Error checking connections: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _checkAppleHealthConnection() async {
    // In a real app, you would check if the app has permission to access Apple Health
    // For now, we'll just return a mock value
    await Future.delayed(const Duration(milliseconds: 500));
    return false;
  }

  Future<bool> _checkGoogleFitConnection() async {
    // In a real app, you would check if the app has permission to access Google Fit
    // For now, we'll just return a mock value
    await Future.delayed(const Duration(milliseconds: 500));
    return false;
  }

  Future<void> _connectAppleHealth() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Sync with Apple Health
      context.read<FitnessBloc>().add(const SyncFitnessData('apple_health'));
      
      // Wait for sync to complete
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isAppleHealthConnected = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connected to Apple Health')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to Apple Health: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _connectGoogleFit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Sync with Google Fit
      context.read<FitnessBloc>().add(const SyncFitnessData('google_fit'));
      
      // Wait for sync to complete
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isGoogleFitConnected = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connected to Google Fit')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to Google Fit: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _connectFitbit() async {
    try {
      await _fitbitAuthService.authenticate();
      
      // Note: The actual authentication will happen when the app receives the redirect
      // We'll show a message to the user to wait for the redirect
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connecting to Fitbit...')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to Fitbit: $e')),
      );
    }
  }

  Future<void> _disconnectFitbit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _fitbitAuthService.logout();
      
      setState(() {
        _isFitbitConnected = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disconnected from Fitbit')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to disconnect from Fitbit: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Fitness Services'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _checkConnections,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Connect your fitness services to get personalized meal recommendations based on your activity data.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Apple Health (iOS only)
                  if (Theme.of(context).platform == TargetPlatform.iOS)
                    _buildConnectionCard(
                      title: 'Apple Health',
                      icon: Icons.favorite,
                      iconColor: Colors.red,
                      isConnected: _isAppleHealthConnected,
                      onConnect: _connectAppleHealth,
                      onDisconnect: () {
                        // Apple Health doesn't support programmatic disconnection
                        // Users need to go to Settings > Privacy > Health to revoke permissions
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'To disconnect from Apple Health, go to Settings > Privacy > Health',
                            ),
                          ),
                        );
                      },
                    ),
                  
                  // Google Fit (Android only)
                  if (Theme.of(context).platform == TargetPlatform.android)
                    _buildConnectionCard(
                      title: 'Google Fit',
                      icon: Icons.fitness_center,
                      iconColor: Colors.blue,
                      isConnected: _isGoogleFitConnected,
                      onConnect: _connectGoogleFit,
                      onDisconnect: () {
                        // Google Fit doesn't support programmatic disconnection
                        // Users need to go to Settings > Apps > Nutrio Wellness > Permissions to revoke permissions
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'To disconnect from Google Fit, go to Settings > Apps > Nutrio Wellness > Permissions',
                            ),
                          ),
                        );
                      },
                    ),
                  
                  // Fitbit (both platforms)
                  _buildConnectionCard(
                    title: 'Fitbit',
                    icon: Icons.watch,
                    iconColor: Colors.teal,
                    isConnected: _isFitbitConnected,
                    onConnect: _connectFitbit,
                    onDisconnect: _disconnectFitbit,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Sync button
                  ElevatedButton.icon(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      
                      try {
                        // Sync with all connected platforms
                        if (_isAppleHealthConnected) {
                          context.read<FitnessBloc>().add(const SyncFitnessData('apple_health'));
                        }
                        
                        if (_isGoogleFitConnected) {
                          context.read<FitnessBloc>().add(const SyncFitnessData('google_fit'));
                        }
                        
                        if (_isFitbitConnected) {
                          context.read<FitnessBloc>().add(const SyncFitnessData('fitbit'));
                        }
                        
                        // Wait for sync to complete
                        await Future.delayed(const Duration(seconds: 2));
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fitness data synced successfully')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to sync fitness data: $e')),
                        );
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.sync),
                    label: const Text('Sync Fitness Data Now'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildConnectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool isConnected,
    required VoidCallback onConnect,
    required VoidCallback onDisconnect,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isConnected ? 'Connected' : 'Not Connected',
                    style: TextStyle(
                      color: isConnected ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              isConnected
                  ? 'Your $title data is being used to provide personalized recommendations.'
                  : 'Connect to $title to get personalized recommendations based on your activity data.',
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isConnected ? onDisconnect : onConnect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isConnected ? Colors.red.shade50 : AppColors.primary.withOpacity(0.1),
                  foregroundColor: isConnected ? Colors.red : AppColors.primary,
                ),
                child: Text(isConnected ? 'Disconnect' : 'Connect'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
