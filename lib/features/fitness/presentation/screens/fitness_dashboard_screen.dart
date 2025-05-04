import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nutrio_wellness/core/theme/app_colors.dart';
import 'package:nutrio_wellness/features/fitness/data/models/fitness_data_model.dart';
import 'package:nutrio_wellness/features/fitness/presentation/bloc/fitness_bloc.dart';
import 'package:nutrio_wellness/features/fitness/presentation/widgets/activity_summary_card.dart';
import 'package:nutrio_wellness/features/fitness/presentation/widgets/fitness_metric_card.dart';
import 'package:nutrio_wellness/features/fitness/presentation/widgets/weekly_chart.dart';
import 'package:nutrio_wellness/features/fitness/presentation/widgets/workout_list_item.dart';
import 'package:nutrio_wellness/routes.dart';

class FitnessDashboardScreen extends StatefulWidget {
  const FitnessDashboardScreen({Key? key}) : super(key: key);

  @override
  State<FitnessDashboardScreen> createState() => _FitnessDashboardScreenState();
}

class _FitnessDashboardScreenState extends State<FitnessDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  DateTime _weekStartDate = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load initial data
    _loadDailySummary();
    _loadWeeklySummary();
    _loadWorkoutSessions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDailySummary() {
    context.read<FitnessBloc>().add(LoadDailySummary(_selectedDate));
  }

  void _loadWeeklySummary() {
    context.read<FitnessBloc>().add(LoadWeeklySummary(_weekStartDate));
  }

  void _loadWorkoutSessions() {
    final now = DateTime.now();
    context.read<FitnessBloc>().add(
      LoadWorkoutSessions(
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now,
      ),
    );
  }

  void _syncFitnessData(String provider) {
    context.read<FitnessBloc>().add(SyncFitnessData(provider));
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadDailySummary();
    }
  }

  void _selectWeek(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _weekStartDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      selectableDayPredicate: (DateTime date) {
        // Only allow Mondays to be selected
        return date.weekday == DateTime.monday;
      },
    );

    if (picked != null && picked != _weekStartDate) {
      setState(() {
        _weekStartDate = picked;
      });
      _loadWeeklySummary();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Tracking'),
        actions: [
          // Connect button
          IconButton(
            icon: const Icon(Icons.link),
            tooltip: 'Connect Fitness Services',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.fitnessConnection);
            },
          ),
          // Sync button
          PopupMenuButton<String>(
            onSelected: _syncFitnessData,
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'apple_health',
                child: Text('Sync with Apple Health'),
              ),
              const PopupMenuItem<String>(
                value: 'google_fit',
                child: Text('Sync with Google Fit'),
              ),
              const PopupMenuItem<String>(
                value: 'fitbit',
                child: Text('Sync with Fitbit'),
              ),
            ],
            icon: const Icon(Icons.sync),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Weekly'),
            Tab(text: 'Workouts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyTab(),
          _buildWeeklyTab(),
          _buildWorkoutsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add workout or manual entry screen
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDailyTab() {
    return BlocBuilder<FitnessBloc, FitnessState>(
      builder: (context, state) {
        if (state is FitnessLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DailySummaryLoaded) {
          final summary = state.summary;

          return RefreshIndicator(
            onRefresh: () async {
              _loadDailySummary();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date selector
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Activity summary
                  ActivitySummaryCard(
                    steps: summary.steps,
                    distance: summary.distance,
                    calories: summary.caloriesBurned,
                    activeMinutes: summary.activeMinutes,
                  ),
                  const SizedBox(height: 24),

                  // Metrics grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      FitnessMetricCard(
                        title: 'Steps',
                        value: summary.steps.toString(),
                        icon: Icons.directions_walk,
                        color: AppColors.primary,
                        progress: summary.steps / 10000, // Assuming 10,000 steps goal
                      ),
                      FitnessMetricCard(
                        title: 'Distance',
                        value: '${summary.distance.toStringAsFixed(1)} km',
                        icon: Icons.place,
                        color: AppColors.fitness,
                        progress: summary.distance / 8, // Assuming 8 km goal
                      ),
                      FitnessMetricCard(
                        title: 'Calories',
                        value: '${summary.caloriesBurned} kcal',
                        icon: Icons.local_fire_department,
                        color: AppColors.accent,
                        progress: summary.caloriesBurned / 500, // Assuming 500 kcal goal
                      ),
                      FitnessMetricCard(
                        title: 'Active Minutes',
                        value: '${summary.activeMinutes} min',
                        icon: Icons.timer,
                        color: AppColors.warning,
                        progress: summary.activeMinutes / 60, // Assuming 60 min goal
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Additional metrics
                  if (summary.sleepDuration != null) ...[
                    const Text(
                      'Sleep',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.nightlight_round,
                              color: AppColors.primary,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${(summary.sleepDuration! / 60).toStringAsFixed(1)} hours',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Last night',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const Text(
                    'Water Intake',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.water_drop,
                            color: Colors.blue,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${(summary.waterIntake / 1000).toStringAsFixed(1)} L',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'of 2.5 L goal',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: Stack(
                              children: [
                                CircularProgressIndicator(
                                  value: summary.waterIntake / 2500, // 2.5 L goal
                                  backgroundColor: Colors.blue.withOpacity(0.2),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                                  strokeWidth: 8,
                                ),
                                Center(
                                  child: Text(
                                    '${((summary.waterIntake / 2500) * 100).round()}%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is FitnessError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${state.message}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadDailySummary,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildWeeklyTab() {
    return BlocBuilder<FitnessBloc, FitnessState>(
      builder: (context, state) {
        if (state is FitnessLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is WeeklySummaryLoaded) {
          final summaries = state.summaries;

          return RefreshIndicator(
            onRefresh: () async {
              _loadWeeklySummary();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Week selector
                  GestureDetector(
                    onTap: () => _selectWeek(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Week of ${DateFormat('MMMM d').format(_weekStartDate)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Steps chart
                  const Text(
                    'Steps',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  WeeklyChart(
                    summaries: summaries,
                    dataType: 'steps',
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 24),

                  // Calories chart
                  const Text(
                    'Calories Burned',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  WeeklyChart(
                    summaries: summaries,
                    dataType: 'calories',
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: 24),

                  // Distance chart
                  const Text(
                    'Distance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  WeeklyChart(
                    summaries: summaries,
                    dataType: 'distance',
                    color: AppColors.fitness,
                  ),
                  const SizedBox(height: 24),

                  // Active minutes chart
                  const Text(
                    'Active Minutes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  WeeklyChart(
                    summaries: summaries,
                    dataType: 'activeMinutes',
                    color: AppColors.warning,
                  ),
                  const SizedBox(height: 24),

                  // Weekly summary
                  const Text(
                    'Weekly Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildWeeklySummaryRow(
                            'Total Steps',
                            summaries.fold(0, (sum, item) => sum + item.steps).toString(),
                            Icons.directions_walk,
                            AppColors.primary,
                          ),
                          const Divider(),
                          _buildWeeklySummaryRow(
                            'Total Distance',
                            '${summaries.fold(0.0, (sum, item) => sum + item.distance).toStringAsFixed(1)} km',
                            Icons.place,
                            AppColors.fitness,
                          ),
                          const Divider(),
                          _buildWeeklySummaryRow(
                            'Total Calories',
                            '${summaries.fold(0, (sum, item) => sum + item.caloriesBurned)} kcal',
                            Icons.local_fire_department,
                            AppColors.accent,
                          ),
                          const Divider(),
                          _buildWeeklySummaryRow(
                            'Total Active Minutes',
                            '${summaries.fold(0, (sum, item) => sum + item.activeMinutes)} min',
                            Icons.timer,
                            AppColors.warning,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is FitnessError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${state.message}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadWeeklySummary,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildWorkoutsTab() {
    return BlocBuilder<FitnessBloc, FitnessState>(
      builder: (context, state) {
        if (state is FitnessLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is WorkoutSessionsLoaded) {
          final sessions = state.sessions;

          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No workout sessions yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap the + button to add a workout',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          // Sort sessions by date (newest first)
          sessions.sort((a, b) => b.startTime.compareTo(a.startTime));

          return RefreshIndicator(
            onRefresh: () async {
              _loadWorkoutSessions();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return WorkoutListItem(
                  session: session,
                  onTap: () {
                    // Navigate to workout details
                  },
                );
              },
            ),
          );
        } else if (state is FitnessError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${state.message}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadWorkoutSessions,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildWeeklySummaryRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
