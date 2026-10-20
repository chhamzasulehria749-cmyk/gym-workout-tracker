import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../database/app_database.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';
import 'workout_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Box settingsBox = Hive.box('settingsBox');

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<WorkoutProvider>().loadData();
    });
  }

  String get userName {
    final name = settingsBox.get('name');

    if (name == null || name.toString().trim().isEmpty) {
      return 'Hamza';
    }

    return name.toString();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }

    final yesterday = now.subtract(const Duration(days: 1));

    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  // ==========================================================
  // ADD WORKOUT
  // ==========================================================

  Future<void> _openAddWorkout() async {
    debugPrint('ADD WORKOUT BUTTON PRESSED');

    try {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            debugPrint('OPENING WORKOUT FORM');

            return const WorkoutFormScreen();
          },
        ),
      );

      debugPrint('WORKOUT FORM CLOSED: $result');

      if (!mounted) return;

      await context.read<WorkoutProvider>().loadData();
    } catch (e, stackTrace) {
      debugPrint('OPEN WORKOUT ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open workout screen: $e')),
      );
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // ======================================================
      // FLOATING ADD BUTTON
      // ======================================================
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddWorkout,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded, size: 28),
      ),

      // ======================================================
      // BODY
      // ======================================================
      body: SafeArea(
        child: Consumer<WorkoutProvider>(
          builder: (context, provider, child) {
            final workouts = provider.workouts;

            final today = DateTime.now();

            // ------------------------------------------------
            // TODAY'S WORKOUTS
            // ------------------------------------------------

            final todayWorkouts = workouts.where((workout) {
              return workout.date.year == today.year &&
                  workout.date.month == today.month &&
                  workout.date.day == today.day;
            }).toList();

            // ------------------------------------------------
            // RECENT WORKOUTS
            // ------------------------------------------------

            final recentWorkouts = workouts.take(5).toList();

            return RefreshIndicator(
              onRefresh: provider.loadData,

              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),

                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(.65),
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              userName,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(.08)
                              : AppTheme.primary.withOpacity(.08),
                          shape: BoxShape.circle,
                        ),

                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.notifications_none_rounded,
                            color: isDark ? Colors.white : AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // HERO CARD
                  // ==================================================
                  Container(
                    padding: const EdgeInsets.all(24),

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.primaryDark,
                          AppTheme.primary,
                          AppTheme.primaryLight,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),

                      borderRadius: BorderRadius.circular(28),

                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(.25),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text(
                          "TODAY'S FOCUS",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          todayWorkouts.isEmpty
                              ? 'Ready to train?'
                              : '${todayWorkouts.length} workout${todayWorkouts.length == 1 ? '' : 's'} today',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          todayWorkouts.isEmpty
                              ? 'Start your workout and track every set.'
                              : 'Keep going and make today count.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ==================================================
                        // ADD WORKOUT BUTTON
                        // ==================================================
                        SizedBox(
                          width: double.infinity,

                          child: ElevatedButton.icon(
                            onPressed: _openAddWorkout,

                            icon: const Icon(Icons.add_rounded),

                            label: const Text('Add Workout'),

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primary,

                              padding: const EdgeInsets.symmetric(vertical: 15),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // QUICK STATS
                  // ==================================================
                  Text(
                    'Quick Stats',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.fitness_center_rounded,
                          title: 'Workouts',
                          value: workouts.length.toString(),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _StatCard(
                          icon: Icons.today_rounded,
                          title: 'Today',
                          value: todayWorkouts.length.toString(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // WEEKLY ACTIVITY
                  // ==================================================
                  Text(
                    'Weekly Activity',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 18,
                    ),

                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(.05)
                          : theme.cardColor,

                      borderRadius: BorderRadius.circular(22),

                      border: Border.all(
                        color: theme.dividerColor.withOpacity(.1),
                      ),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: List.generate(7, (index) {
                        final day = DateTime.now().subtract(
                          Duration(days: 6 - index),
                        );

                        final active = workouts.any((workout) {
                          return workout.date.year == day.year &&
                              workout.date.month == day.month &&
                              workout.date.day == day.day;
                        });

                        final dayName = const [
                          'M',
                          'T',
                          'W',
                          'T',
                          'F',
                          'S',
                          'S',
                        ][day.weekday - 1];

                        return Column(
                          children: [
                            Text(
                              dayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodySmall?.color
                                    ?.withOpacity(.6),
                              ),
                            ),

                            const SizedBox(height: 10),

                            Container(
                              width: 30,
                              height: 30,

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,

                                color: active
                                    ? AppTheme.primary
                                    : theme.dividerColor.withOpacity(.12),
                              ),

                              child: active
                                  ? const Icon(
                                      Icons.check,
                                      size: 17,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ],
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // BODY STATS
                  // ==================================================
                  Text(
                    'Body Stats',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _BodyStatCard(
                          icon: Icons.monitor_weight_outlined,
                          title: 'Weight',
                          value: settingsBox.get('weight')?.toString() ?? '--',
                          unit: 'kg',
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _BodyStatCard(
                          icon: Icons.height_rounded,
                          title: 'Height',
                          value: settingsBox.get('height')?.toString() ?? '--',
                          unit: 'ft',
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _BodyStatCard(
                          icon: Icons.cake_outlined,
                          title: 'Age',
                          value: settingsBox.get('age')?.toString() ?? '--',
                          unit: 'yrs',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // RECENT WORKOUTS
                  // ==================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        'Recent Workouts',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (workouts.isNotEmpty)
                        TextButton(
                          onPressed: () {},
                          child: const Text('View All'),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // LOADING
                  // ==================================================
                  if (provider.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  // ==================================================
                  // EMPTY
                  // ==================================================
                  else if (recentWorkouts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(28),

                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(.05)
                            : theme.cardColor,

                        borderRadius: BorderRadius.circular(22),
                      ),

                      child: Column(
                        children: [
                          Icon(
                            Icons.fitness_center_outlined,
                            size: 42,
                            color: AppTheme.primary.withOpacity(.6),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'No workouts yet',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'Add your first workout to get started.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),

                          const SizedBox(height: 18),

                          // ==================================================
                          // EMPTY STATE ADD BUTTON
                          // ==================================================
                          SizedBox(
                            width: double.infinity,

                            child: ElevatedButton.icon(
                              onPressed: _openAddWorkout,

                              icon: const Icon(Icons.add_rounded),

                              label: const Text('Add Workout'),
                            ),
                          ),
                        ],
                      ),
                    )
                  // ==================================================
                  // WORKOUT LIST
                  // ==================================================
                  else
                    ...recentWorkouts.map(
                      (workout) => _WorkoutTile(
                        workout: workout,
                        dateText: _formatDate(workout.date),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// STAT CARD
// ============================================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(.05) : theme.cardColor,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: theme.dividerColor.withOpacity(.1)),
      ),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(.1),
              borderRadius: BorderRadius.circular(13),
            ),

            child: Icon(icon, color: AppTheme.primary, size: 21),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(title, style: theme.textTheme.bodySmall),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BODY STAT CARD
// ============================================================

class _BodyStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;

  const _BodyStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(.05) : theme.cardColor,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: theme.dividerColor.withOpacity(.1)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon, color: AppTheme.primary, size: 22),

          const SizedBox(height: 12),

          Text(title, style: theme.textTheme.bodySmall),

          const SizedBox(height: 3),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,

            children: [
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 3),

              Text(unit, style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WORKOUT TILE
// ============================================================

class _WorkoutTile extends StatelessWidget {
  final Workout workout;
  final String dateText;

  const _WorkoutTile({required this.workout, required this.dateText});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(.05) : theme.cardColor,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: theme.dividerColor.withOpacity(.1)),
      ),

      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,

            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryLight],
              ),

              borderRadius: BorderRadius.circular(15),
            ),

            child: const Icon(Icons.fitness_center, color: Colors.white),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  workout.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  workout.duration > 0
                      ? '$dateText • ${workout.duration} min'
                      : dateText,

                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(.65),
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}
