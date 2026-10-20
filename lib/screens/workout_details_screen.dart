import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/app_database.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutDetailsScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailsScreen> createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen> {
  bool _isLoading = true;

  final List<_ExerciseDetails> _exercises = [];

  @override
  void initState() {
    super.initState();
    _loadWorkoutDetails();
  }

  Future<void> _loadWorkoutDetails() async {
    final provider = context.read<WorkoutProvider>();

    try {
      final workoutExercises = await provider.getWorkoutExercises(
        widget.workout.id,
      );

      final List<_ExerciseDetails> loadedExercises = [];

      for (final workoutExercise in workoutExercises) {
        final exercise = provider.exercises.firstWhere(
          (item) => item.id == workoutExercise.exerciseId,
          orElse: () => Exercise(
            id: workoutExercise.exerciseId,
            name: 'Unknown Exercise',
            muscleGroup: 'Unknown',
            equipment: 'Unknown',
          ),
        );

        final sets = await provider.getSets(workoutExercise.id);

        loadedExercises.add(_ExerciseDetails(exercise: exercise, sets: sets));
      }

      if (!mounted) return;

      setState(() {
        _exercises
          ..clear()
          ..addAll(loadedExercises);

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load workout details: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;

    final displayHour = hour == 0 ? 12 : hour;

    final minute = date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$displayHour:$minute $period';
  }

  double _totalVolume() {
    double total = 0;

    for (final exercise in _exercises) {
      for (final set in exercise.sets) {
        total += set.weight * set.reps;
      }
    }

    return total;
  }

  int _totalSets() {
    return _exercises.fold(
      0,
      (total, exercise) => total + exercise.sets.length,
    );
  }

  int _completedSets() {
    int total = 0;

    for (final exercise in _exercises) {
      for (final set in exercise.sets) {
        if (set.completed) {
          total++;
        }
      }
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Details')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWorkoutDetails,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
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
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.20),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.fitness_center_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                widget.workout.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              _formatDate(widget.workout.date),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Icon(
                              Icons.access_time_rounded,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              _formatTime(widget.workout.date),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ==================================================
                  // SUMMARY
                  // ==================================================
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.fitness_center_rounded,
                          title: 'Exercises',
                          value: '${_exercises.length}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.format_list_numbered_rounded,
                          title: 'Sets',
                          value: '${_totalSets()}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.check_circle_outline_rounded,
                          title: 'Done',
                          value: '${_completedSets()}',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // ==================================================
                  // VOLUME
                  // ==================================================
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.bar_chart_rounded,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Volume',
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${_totalVolume().toStringAsFixed(1)} kg',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // EXERCISES
                  // ==================================================
                  Text(
                    'Exercises',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (_exercises.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.fitness_center_outlined,
                            size: 45,
                            color: AppTheme.primary,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No exercises found',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),

                  ..._exercises.map(
                    (exercise) => _buildExerciseCard(context, exercise),
                  ),

                  // ==================================================
                  // NOTES
                  // ==================================================
                  if (widget.workout.notes.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),

                    Text(
                      'Notes',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Text(
                        widget.workout.notes,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    _ExerciseDetails exerciseDetails,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          // ========================================================
          // EXERCISE HEADER
          // ========================================================
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: AppTheme.primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exerciseDetails.exercise.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${exerciseDetails.exercise.muscleGroup} • '
                      '${exerciseDetails.exercise.equipment}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ========================================================
          // SET HEADER
          // ========================================================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 35,
                  child: Text(
                    'SET',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
                Expanded(
                  child: Text(
                    'WEIGHT',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    'REPS',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: Text(
                    'DONE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // ========================================================
          // SETS
          // ========================================================
          ...List.generate(exerciseDetails.sets.length, (index) {
            final set = exerciseDetails.sets[index];

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 35,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),

                  Expanded(
                    child: Text(
                      '${set.weight} kg',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),

                  SizedBox(
                    width: 70,
                    child: Text(
                      '${set.reps}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),

                  SizedBox(
                    width: 35,
                    child: Icon(
                      set.completed
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: set.completed ? Colors.green : theme.disabledColor,
                      size: 21,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================
// SUMMARY CARD
// ============================================================

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primary, size: 22),
          const SizedBox(height: 7),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EXERCISE DETAILS
// ============================================================

class _ExerciseDetails {
  final Exercise exercise;
  final List<WorkoutSet> sets;

  _ExerciseDetails({required this.exercise, required this.sets});
}
