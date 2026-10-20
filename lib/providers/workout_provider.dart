import 'package:flutter/material.dart';

import '../database/app_database.dart';
import '../services/database_service.dart';
import '../models/previous_workout_data.dart';

class WorkoutProvider extends ChangeNotifier {
  final DatabaseService databaseService;

  WorkoutProvider(this.databaseService);

  // ==========================================================
  // DATA
  // ==========================================================

  List<Workout> _workouts = [];
  List<Workout> get workouts => _workouts;

  List<Exercise> _exercises = [];
  List<Exercise> get exercises => _exercises;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ==========================================================
  // LOAD DATA
  // ==========================================================

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _workouts = await databaseService.getWorkouts();
      _exercises = await databaseService.getExercises();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================================
  // EXERCISES
  // ==========================================================

  Future<int> addExercise({
    required String name,
    required String muscleGroup,
    required String equipment,
  }) async {
    final id = await databaseService.addExercise(
      name: name,
      muscleGroup: muscleGroup,
      equipment: equipment,
    );

    await loadData();

    return id;
  }

  // ==========================================================
  // CREATE WORKOUT
  // ==========================================================

  Future<int> createWorkout({
    required String name,
    DateTime? date,
    int duration = 0,
    String notes = '',
  }) async {
    final id = await databaseService.createWorkout(
      name: name,
      date: date ?? DateTime.now(),
      duration: duration,
      notes: notes,
    );

    await loadData();

    return id;
  }

  // ==========================================================
  // UPDATE WORKOUT
  // ==========================================================

  Future<void> updateWorkout({
    required int workoutId,
    required String name,
    required DateTime date,
    required int duration,
    required String notes,
  }) async {
    await databaseService.updateWorkout(
      workoutId: workoutId,
      name: name,
      date: date,
      duration: duration,
      notes: notes,
    );

    await loadData();
  }

  // ==========================================================
  // DELETE WORKOUT
  // ==========================================================

  Future<void> deleteWorkout(int workoutId) async {
    await databaseService.deleteWorkout(workoutId);
    await loadData();
  }

  // ==========================================================
  // WORKOUT EXERCISES
  // ==========================================================

  Future<int> addExerciseToWorkout({
    required int workoutId,
    required int exerciseId,
  }) {
    return databaseService.addExerciseToWorkout(
      workoutId: workoutId,
      exerciseId: exerciseId,
    );
  }

  Future<List<WorkoutExercise>> getWorkoutExercises(int workoutId) {
    return databaseService.getWorkoutExercises(workoutId);
  }

  // ==========================================================
  // DELETE WORKOUT CONTENT
  // ==========================================================

  Future<void> deleteWorkoutContent(int workoutId) {
    return databaseService.deleteWorkoutContent(workoutId);
  }

  // ==========================================================
  // SETS
  // ==========================================================

  Future<int> addSet({
    required int workoutExerciseId,
    required int setNumber,
    required double weight,
    required int reps,
    String type = 'working',
    bool completed = false,
  }) {
    return databaseService.addSet(
      workoutExerciseId: workoutExerciseId,
      setNumber: setNumber,
      weight: weight,
      reps: reps,
      type: type,
      completed: completed,
    );
  }

  Future<List<WorkoutSet>> getSets(int workoutExerciseId) {
    return databaseService.getSets(workoutExerciseId);
  }

  Future<void> deleteWorkoutSets(int workoutExerciseId) {
    return databaseService.deleteWorkoutSets(workoutExerciseId);
  }

  // ==========================================================
  // PREVIOUS WORKOUT
  // ==========================================================

  Future<PreviousWorkoutData?> getPreviousWorkoutForExercise({
    required int exerciseId,
    int? excludeWorkoutId,
  }) {
    return databaseService.getPreviousWorkoutForExercise(
      exerciseId: exerciseId,
      excludeWorkoutId: excludeWorkoutId,
    );
  }

  // ==========================================================
  // STATISTICS
  // ==========================================================

  Future<int> getWorkoutExerciseCount(int workoutId) {
    return databaseService.getWorkoutExerciseCount(workoutId);
  }

  Future<int> getWorkoutSetCount(int workoutId) {
    return databaseService.getWorkoutSetCount(workoutId);
  }

  Future<int> getCompletedSetCount(int workoutId) {
    return databaseService.getCompletedSetCount(workoutId);
  }

  Future<double> getWorkoutVolume(int workoutId) {
    return databaseService.getWorkoutVolume(workoutId);
  }
}
