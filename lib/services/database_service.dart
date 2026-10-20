import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/previous_workout_data.dart';

class DatabaseService {
  final AppDatabase database;

  DatabaseService(this.database);

  // ==========================================================
  // EXERCISES
  // ==========================================================

  Future<int> addExercise({
    required String name,
    required String muscleGroup,
    required String equipment,
  }) {
    return database.addExercise(
      ExercisesCompanion.insert(
        name: name,
        muscleGroup: muscleGroup,
        equipment: equipment,
      ),
    );
  }

  Future<List<Exercise>> getExercises() {
    return database.getAllExercises();
  }

  // ==========================================================
  // WORKOUTS
  // ==========================================================

  Future<int> createWorkout({
    required String name,
    required DateTime date,
    int duration = 0,
    String notes = '',
  }) {
    return database.addWorkout(
      WorkoutsCompanion.insert(
        name: name,
        date: date,
        duration: Value(duration),
        notes: Value(notes),
      ),
    );
  }

  Future<List<Workout>> getWorkouts() {
    return database.getAllWorkouts();
  }

  Future<Workout?> getWorkoutById(int workoutId) {
    return database.getWorkoutById(workoutId);
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
  }) {
    return database.updateWorkout(
      workoutId: workoutId,
      name: name,
      date: date,
      duration: duration,
      notes: notes,
    );
  }

  // ==========================================================
  // DELETE WORKOUT
  // ==========================================================

  Future<void> deleteWorkout(int workoutId) {
    return database.deleteWorkout(workoutId);
  }

  // ==========================================================
  // WORKOUT EXERCISES
  // ==========================================================

  Future<int> addExerciseToWorkout({
    required int workoutId,
    required int exerciseId,
  }) {
    return database.addWorkoutExercise(
      WorkoutExercisesCompanion.insert(
        workoutId: workoutId,
        exerciseId: exerciseId,
      ),
    );
  }

  Future<List<WorkoutExercise>> getWorkoutExercises(int workoutId) {
    return database.getWorkoutExercises(workoutId);
  }

  // ==========================================================
  // DELETE WORKOUT CONTENT
  // ==========================================================

  Future<void> deleteWorkoutContent(int workoutId) {
    return database.deleteWorkoutContent(workoutId);
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
    return database.addWorkoutSet(
      WorkoutSetsCompanion.insert(
        workoutExerciseId: workoutExerciseId,
        setNumber: setNumber,
        weight: weight,
        reps: reps,
        type: Value(type),
        completed: Value(completed),
      ),
    );
  }

  Future<List<WorkoutSet>> getSets(int workoutExerciseId) {
    return database.getWorkoutSets(workoutExerciseId);
  }

  Future<void> deleteWorkoutSets(int workoutExerciseId) {
    return database.deleteWorkoutSets(workoutExerciseId);
  }

  // ==========================================================
  // PREVIOUS WORKOUT VALUES
  // ==========================================================

  Future<PreviousWorkoutData?> getPreviousWorkoutForExercise({
    required int exerciseId,
    int? excludeWorkoutId,
  }) {
    return database.getPreviousWorkoutForExercise(
      exerciseId: exerciseId,
      excludeWorkoutId: excludeWorkoutId,
    );
  }

  // ==========================================================
  // WORKOUT STATISTICS
  // ==========================================================

  Future<int> getWorkoutExerciseCount(int workoutId) {
    return database.getWorkoutExerciseCount(workoutId);
  }

  Future<int> getWorkoutSetCount(int workoutId) {
    return database.getWorkoutSetCount(workoutId);
  }

  Future<int> getCompletedSetCount(int workoutId) {
    return database.getCompletedSetCount(workoutId);
  }

  Future<double> getWorkoutVolume(int workoutId) {
    return database.getWorkoutVolume(workoutId);
  }
}
