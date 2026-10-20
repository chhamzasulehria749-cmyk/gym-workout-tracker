import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/app_database.dart';
import '../models/previous_workout_data.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';

class WorkoutFormScreen extends StatefulWidget {
  final Workout? workout;

  const WorkoutFormScreen({super.key, this.workout});

  @override
  State<WorkoutFormScreen> createState() => _WorkoutFormScreenState();
}

class _WorkoutFormScreenState extends State<WorkoutFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;

  bool _isSaving = false;
  bool _isAddingExercise = false;

  final List<_ExerciseEntry> _selectedExercises = [];

  bool get isEditing => widget.workout != null;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.workout?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();

    for (final exercise in _selectedExercises) {
      exercise.dispose();
    }

    super.dispose();
  }

  // ==========================================================
  // ADD EXERCISE
  // ==========================================================

  Future<void> _addExercise() async {
    if (_isAddingExercise) return;

    final provider = context.read<WorkoutProvider>();

    final selected = await showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);

        return SafeArea(
          child: Container(
            height: MediaQuery.of(sheetContext).size.height * 0.78,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),

                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Choose Exercise',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // CREATE NEW EXERCISE BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.primaryDark,
                          AppTheme.primary,
                          AppTheme.primaryLight,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () async {
                          final navigator = Navigator.of(sheetContext);

                          final newExercise = await _showCreateExerciseDialog();

                          if (!mounted) return;

                          if (newExercise != null) {
                            navigator.pop(newExercise);
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 15,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add_circle_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Create New Exercise',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Add your own exercise',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white70,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Your Exercises',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: provider.exercises.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(30),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.10,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.fitness_center_rounded,
                                    color: AppTheme.primary,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No exercises yet',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Create your first exercise above.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: provider.exercises.length,
                          itemBuilder: (context, index) {
                            final exercise = provider.exercises[index];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 5,
                                ),
                                leading: Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.10,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.fitness_center_rounded,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                title: Text(
                                  exercise.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(
                                  '${exercise.muscleGroup} • ${exercise.equipment}',
                                ),
                                trailing: const Icon(
                                  Icons.add_circle_outline_rounded,
                                  color: AppTheme.primary,
                                ),
                                onTap: () {
                                  Navigator.pop(sheetContext, exercise);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || !mounted) {
      return;
    }

    await _addSelectedExercise(selected);
  }

  // ==========================================================
  // ADD SELECTED EXERCISE TO CURRENT FORM
  // ==========================================================

  Future<void> _addSelectedExercise(Exercise selected) async {
    final alreadyAdded = _selectedExercises.any(
      (item) => item.exercise.id == selected.id,
    );

    if (alreadyAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This exercise is already added.')),
      );
      return;
    }

    setState(() {
      _isAddingExercise = true;
    });

    try {
      final provider = context.read<WorkoutProvider>();

      PreviousWorkoutData? previousWorkout;

      try {
        previousWorkout = await provider.getPreviousWorkoutForExercise(
          exerciseId: selected.id,
          excludeWorkoutId: widget.workout?.id,
        );
      } catch (e) {
        debugPrint('Could not load previous workout values: $e');
      }

      if (!mounted) return;

      setState(() {
        _selectedExercises.add(
          _ExerciseEntry(exercise: selected, previousWorkout: previousWorkout),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAddingExercise = false;
        });
      }
    }
  }

  // ==========================================================
  // CREATE EXERCISE
  // ==========================================================

  Future<Exercise?> _showCreateExerciseDialog() async {
    final nameController = TextEditingController();
    final equipmentController = TextEditingController();

    String muscleGroup = 'Chest';

    final muscleGroups = [
      'Chest',
      'Back',
      'Legs',
      'Shoulders',
      'Biceps',
      'Triceps',
      'Core',
    ];

    try {
      final result = await showDialog<Exercise?>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Create Exercise'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Exercise Name',
                          prefixIcon: Icon(Icons.fitness_center_rounded),
                        ),
                      ),

                      const SizedBox(height: 14),

                      DropdownButtonFormField<String>(
                        initialValue: muscleGroup,
                        decoration: const InputDecoration(
                          labelText: 'Muscle Group',
                          prefixIcon: Icon(Icons.accessibility_new_rounded),
                        ),
                        items: muscleGroups.map((muscle) {
                          return DropdownMenuItem<String>(
                            value: muscle,
                            child: Text(muscle),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              muscleGroup = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: equipmentController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Equipment',
                          prefixIcon: Icon(Icons.sports_gymnastics_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();

                      if (name.isEmpty) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(content: Text('Enter exercise name.')),
                        );
                        return;
                      }

                      final equipment = equipmentController.text.trim().isEmpty
                          ? 'Gym'
                          : equipmentController.text.trim();

                      try {
                        final provider = context.read<WorkoutProvider>();

                        // IMPORTANT:
                        // addExercise returns the exact new ID.
                        final newExerciseId = await provider.addExercise(
                          name: name,
                          muscleGroup: muscleGroup,
                          equipment: equipment,
                        );

                        if (!dialogContext.mounted) return;

                        // Find the exact exercise using its ID.
                        Exercise? newExercise;

                        for (final exercise in provider.exercises) {
                          if (exercise.id == newExerciseId) {
                            newExercise = exercise;
                            break;
                          }
                        }

                        if (newExercise == null) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Exercise was created, but could not be loaded.',
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.pop(dialogContext, newExercise);
                      } catch (e) {
                        if (!dialogContext.mounted) return;

                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Text('Could not create exercise: $e'),
                          ),
                        );
                      }
                    },
                    child: const Text('Create'),
                  ),
                ],
              );
            },
          );
        },
      );

      return result;
    } finally {
      nameController.dispose();
      equipmentController.dispose();
    }
  }

  // ==========================================================
  // SAVE WORKOUT
  // ==========================================================

  Future<void> _saveWorkout() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one exercise.')),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
    });

    try {
      final provider = context.read<WorkoutProvider>();

      // 1. CREATE WORKOUT
      final workoutId = await provider.createWorkout(
        name: _nameController.text.trim(),
        date: widget.workout?.date ?? DateTime.now(),
      );

      // 2. ADD EXERCISES + SETS
      for (final exerciseEntry in _selectedExercises) {
        final workoutExerciseId = await provider.addExerciseToWorkout(
          workoutId: workoutId,
          exerciseId: exerciseEntry.exercise.id,
        );

        for (int i = 0; i < exerciseEntry.sets.length; i++) {
          final set = exerciseEntry.sets[i];

          await provider.addSet(
            workoutExerciseId: workoutExerciseId,
            setNumber: i + 1,
            weight: double.tryParse(set.weight.text.trim()) ?? 0,
            reps: int.tryParse(set.reps.text.trim()) ?? 0,
            type: set.type,
            completed: set.completed,
          );
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout saved successfully.')),
      );

      Navigator.pop(context);
    } catch (e, stackTrace) {
      debugPrint('SAVE WORKOUT ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save workout: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ==========================================================
  // INPUT DECORATION
  // ==========================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20));
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Workout' : 'New Workout')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  children: [
                    // HERO
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
                      child: Row(
                        children: [
                          Container(
                            height: 58,
                            width: 58,
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEditing ? 'Edit Workout' : 'New Workout',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'Track every exercise and set.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // WORKOUT DETAILS
                    Text(
                      'Workout Details',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(
                        label: 'Workout Name',
                        icon: Icons.edit_note_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter workout name';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    // EXERCISES HEADER
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Exercises',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_selectedExercises.length} exercise${_selectedExercises.length == 1 ? '' : 's'} added',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        SizedBox(
                          width: 105,
                          child: OutlinedButton.icon(
                            onPressed: _isAddingExercise ? null : _addExercise,
                            icon: _isAddingExercise
                                ? const SizedBox(
                                    width: 17,
                                    height: 17,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.add_rounded, size: 19),
                            label: const Text('Add'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // EMPTY STATE
                    if (_selectedExercises.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 64,
                              width: 64,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.10),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.fitness_center_rounded,
                                color: AppTheme.primary,
                                size: 30,
                              ),
                            ),

                            const SizedBox(height: 15),

                            Text(
                              'No exercises yet',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              'Add an exercise to start recording your sets.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),

                            const SizedBox(height: 18),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isAddingExercise
                                    ? null
                                    : _addExercise,
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Add Exercise'),
                              ),
                            ),
                          ],
                        ),
                      ),

                    ..._selectedExercises.map(
                      (entry) => _buildExerciseCard(context, entry),
                    ),
                  ],
                ),
              ),

              // SAVE BUTTON
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  border: Border(top: BorderSide(color: theme.dividerColor)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveWorkout,
                    child: _isSaving
                        ? const SizedBox(
                            height: 23,
                            width: 23,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_rounded),
                              SizedBox(width: 9),
                              Text('Save Workout'),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // EXERCISE CARD
  // ==========================================================

  Widget _buildExerciseCard(BuildContext context, _ExerciseEntry entry) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
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
                      entry.exercise.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${entry.exercise.muscleGroup} • ${entry.exercise.equipment}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () {
                  setState(() {
                    entry.dispose();
                    _selectedExercises.remove(entry);
                  });
                },
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),

          if (entry.previousWorkout != null) ...[
            const SizedBox(height: 16),
            _buildPreviousWorkoutCard(context, entry),
          ],

          const SizedBox(height: 18),

          const Row(
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
                width: 97,
                child: Text(
                  'REPS',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
              SizedBox(width: 47),
            ],
          ),

          const SizedBox(height: 8),

          ...List.generate(
            entry.sets.length,
            (index) => _buildSetRow(entry, index),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  entry.addSet();
                });
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Set'),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PREVIOUS WORKOUT
  // ==========================================================

  Widget _buildPreviousWorkoutCard(BuildContext context, _ExerciseEntry entry) {
    final theme = Theme.of(context);
    final previous = entry.previousWorkout!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: AppTheme.primary,
                  size: 19,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Previous Workout',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatPreviousDate(previous.workout.date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.65,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ...previous.sets.map(
            (set) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  SizedBox(
                    width: 45,
                    child: Text(
                      'Set ${set.setNumber}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Text(
                      '${_formatWeight(set.weight)} kg × ${set.reps}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  Icon(
                    set.completed
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    size: 18,
                    color: set.completed
                        ? Colors.green
                        : theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.35,
                          ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: entry.isCopyingPrevious
                  ? null
                  : () {
                      setState(() {
                        entry.copyPreviousSets();
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Previous sets copied to current workout.',
                          ),
                        ),
                      );
                    },
              icon: entry.isCopyingPrevious
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.copy_rounded, size: 18),
              label: Text(
                entry.isCopyingPrevious ? 'Copying...' : 'Copy Previous',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SET ROW
  // ==========================================================

  Widget _buildSetRow(_ExerciseEntry entry, int index) {
    final set = entry.sets[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
            child: TextField(
              controller: set.weight,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                hintText: '0',
                suffixText: 'kg',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            width: 97,
            child: TextField(
              controller: set.reps,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '0',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
              ),
            ),
          ),

          const SizedBox(width: 5),

          SizedBox(
            width: 42,
            child: Checkbox(
              value: set.completed,
              onChanged: (value) {
                setState(() {
                  set.completed = value ?? false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  String _formatPreviousDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatWeight(double weight) {
    if (weight == weight.roundToDouble()) {
      return weight.toInt().toString();
    }

    return weight.toStringAsFixed(1);
  }
}

// ============================================================
// EXERCISE ENTRY
// ============================================================

class _ExerciseEntry {
  final Exercise exercise;

  final PreviousWorkoutData? previousWorkout;

  final List<_SetEntry> sets = [_SetEntry()];

  bool isCopyingPrevious = false;

  _ExerciseEntry({required this.exercise, this.previousWorkout});

  void addSet() {
    sets.add(_SetEntry());
  }

  void copyPreviousSets() {
    if (previousWorkout == null) {
      return;
    }

    isCopyingPrevious = true;

    for (final set in sets) {
      set.dispose();
    }

    sets.clear();

    for (final previousSet in previousWorkout!.sets) {
      final newSet = _SetEntry();

      newSet.weight.text = _formatWeight(previousSet.weight);

      newSet.reps.text = previousSet.reps.toString();

      newSet.completed = false;
      newSet.type = previousSet.type;

      sets.add(newSet);
    }

    if (sets.isEmpty) {
      sets.add(_SetEntry());
    }

    isCopyingPrevious = false;
  }

  void dispose() {
    for (final set in sets) {
      set.dispose();
    }
  }

  String _formatWeight(double weight) {
    if (weight == weight.roundToDouble()) {
      return weight.toInt().toString();
    }

    return weight.toStringAsFixed(1);
  }
}

// ============================================================
// SET ENTRY
// ============================================================

class _SetEntry {
  final TextEditingController weight = TextEditingController();

  final TextEditingController reps = TextEditingController();

  String type = 'working';

  bool completed = false;

  void dispose() {
    weight.dispose();
    reps.dispose();
  }
}
