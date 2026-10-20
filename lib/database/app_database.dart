import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/previous_workout_data.dart';

part 'app_database.g.dart';

// ============================================================
// EXERCISES TABLE
// ============================================================

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get muscleGroup => text()();

  TextColumn get equipment => text()();
}

// ============================================================
// WORKOUTS TABLE
// ============================================================

class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  DateTimeColumn get date => dateTime()();

  IntColumn get duration => integer().withDefault(const Constant(0))();

  TextColumn get notes => text().withDefault(const Constant(''))();
}

// ============================================================
// WORKOUT EXERCISES TABLE
// ============================================================

class WorkoutExercises extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get workoutId => integer()();

  IntColumn get exerciseId => integer()();
}

// ============================================================
// WORKOUT SETS TABLE
// ============================================================

class WorkoutSets extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get workoutExerciseId => integer()();

  IntColumn get setNumber => integer()();

  RealColumn get weight => real()();

  IntColumn get reps => integer()();

  TextColumn get type => text().withDefault(const Constant('working'))();

  BoolColumn get completed => boolean().withDefault(const Constant(false))();
}

// ============================================================
// DATABASE
// ============================================================

@DriftDatabase(tables: [Exercises, Workouts, WorkoutExercises, WorkoutSets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ==========================================================
  // EXERCISES
  // ==========================================================

  Future<int> addExercise(ExercisesCompanion exercise) {
    return into(exercises).insert(exercise);
  }

  Future<List<Exercise>> getAllExercises() {
    return select(exercises).get();
  }

  // ==========================================================
  // WORKOUTS
  // ==========================================================

  Future<int> addWorkout(WorkoutsCompanion workout) {
    return into(workouts).insert(workout);
  }

  Future<List<Workout>> getAllWorkouts() {
    return (select(workouts)..orderBy([
          (table) =>
              OrderingTerm(expression: table.date, mode: OrderingMode.desc),
        ]))
        .get();
  }

  // ----------------------------------------------------------
  // GET SINGLE WORKOUT
  // ----------------------------------------------------------

  Future<Workout?> getWorkoutById(int workoutId) {
    return (select(
      workouts,
    )..where((table) => table.id.equals(workoutId))).getSingleOrNull();
  }

  // ----------------------------------------------------------
  // UPDATE WORKOUT
  // ----------------------------------------------------------

  Future<void> updateWorkout({
    required int workoutId,
    required String name,
    required DateTime date,
    required int duration,
    required String notes,
  }) async {
    await (update(
      workouts,
    )..where((table) => table.id.equals(workoutId))).write(
      WorkoutsCompanion(
        name: Value(name),
        date: Value(date),
        duration: Value(duration),
        notes: Value(notes),
      ),
    );
  }

  // ----------------------------------------------------------
  // DELETE WORKOUT
  // ----------------------------------------------------------

  Future<void> deleteWorkout(int workoutId) async {
    await transaction(() async {
      // Get all workout exercises first.
      final workoutExerciseRows = await getWorkoutExercises(workoutId);

      // Delete all sets belonging to the workout exercises.
      for (final workoutExercise in workoutExerciseRows) {
        await (delete(workoutSets)..where(
              (table) => table.workoutExerciseId.equals(workoutExercise.id),
            ))
            .go();
      }

      // Delete workout-exercise records.
      await (delete(
        workoutExercises,
      )..where((table) => table.workoutId.equals(workoutId))).go();

      // Finally delete the workout.
      await (delete(
        workouts,
      )..where((table) => table.id.equals(workoutId))).go();
    });
  }

  // ----------------------------------------------------------
  // DELETE WORKOUT CONTENT
  // ----------------------------------------------------------

  Future<void> deleteWorkoutContent(int workoutId) async {
    await transaction(() async {
      final workoutExerciseRows = await getWorkoutExercises(workoutId);

      for (final workoutExercise in workoutExerciseRows) {
        await (delete(workoutSets)..where(
              (table) => table.workoutExerciseId.equals(workoutExercise.id),
            ))
            .go();
      }

      await (delete(
        workoutExercises,
      )..where((table) => table.workoutId.equals(workoutId))).go();
    });
  }

  // ==========================================================
  // WORKOUT EXERCISES
  // ==========================================================

  Future<int> addWorkoutExercise(WorkoutExercisesCompanion workoutExercise) {
    return into(workoutExercises).insert(workoutExercise);
  }

  Future<List<WorkoutExercise>> getWorkoutExercises(int workoutId) {
    return (select(
      workoutExercises,
    )..where((table) => table.workoutId.equals(workoutId))).get();
  }

  // ----------------------------------------------------------
  // GET SINGLE WORKOUT EXERCISE
  // ----------------------------------------------------------

  Future<WorkoutExercise?> getWorkoutExerciseById(int workoutExerciseId) {
    return (select(
      workoutExercises,
    )..where((table) => table.id.equals(workoutExerciseId))).getSingleOrNull();
  }

  // ==========================================================
  // WORKOUT SETS
  // ==========================================================

  Future<int> addWorkoutSet(WorkoutSetsCompanion workoutSet) {
    return into(workoutSets).insert(workoutSet);
  }

  Future<List<WorkoutSet>> getWorkoutSets(int workoutExerciseId) {
    return (select(workoutSets)
          ..where((table) => table.workoutExerciseId.equals(workoutExerciseId))
          ..orderBy([(table) => OrderingTerm(expression: table.setNumber)]))
        .get();
  }

  // ----------------------------------------------------------
  // DELETE SETS FOR WORKOUT EXERCISE
  // ----------------------------------------------------------

  Future<void> deleteWorkoutSets(int workoutExerciseId) async {
    await (delete(workoutSets)
          ..where((table) => table.workoutExerciseId.equals(workoutExerciseId)))
        .go();
  }

  // ==========================================================
  // PREVIOUS WORKOUT VALUES
  // ==========================================================

  Future<PreviousWorkoutData?> getPreviousWorkoutForExercise({
    required int exerciseId,
    int? excludeWorkoutId,
  }) async {
    final query = select(workoutExercises).join([
      innerJoin(workouts, workouts.id.equalsExp(workoutExercises.workoutId)),
    ]);

    query.where(workoutExercises.exerciseId.equals(exerciseId));

    if (excludeWorkoutId != null) {
      query.where(workouts.id.isNotValue(excludeWorkoutId));
    }

    query.orderBy([
      OrderingTerm(expression: workouts.date, mode: OrderingMode.desc),
    ]);

    final rows = await query.get();

    if (rows.isEmpty) {
      return null;
    }

    final workoutExercise = rows.first.readTable(workoutExercises);

    final workout = rows.first.readTable(workouts);

    final sets = await getWorkoutSets(workoutExercise.id);

    return PreviousWorkoutData(workout: workout, sets: sets);
  }

  // ==========================================================
  // WORKOUT STATISTICS
  // ==========================================================

  Future<int> getWorkoutExerciseCount(int workoutId) async {
    final rows = await getWorkoutExercises(workoutId);
    return rows.length;
  }

  Future<int> getWorkoutSetCount(int workoutId) async {
    final workoutExerciseRows = await getWorkoutExercises(workoutId);

    int total = 0;

    for (final workoutExercise in workoutExerciseRows) {
      final sets = await getWorkoutSets(workoutExercise.id);

      total += sets.length;
    }

    return total;
  }

  Future<int> getCompletedSetCount(int workoutId) async {
    final workoutExerciseRows = await getWorkoutExercises(workoutId);

    int total = 0;

    for (final workoutExercise in workoutExerciseRows) {
      final sets = await getWorkoutSets(workoutExercise.id);

      for (final set in sets) {
        if (set.completed) {
          total++;
        }
      }
    }

    return total;
  }

  Future<double> getWorkoutVolume(int workoutId) async {
    final workoutExerciseRows = await getWorkoutExercises(workoutId);

    double total = 0;

    for (final workoutExercise in workoutExerciseRows) {
      final sets = await getWorkoutSets(workoutExercise.id);

      for (final set in sets) {
        total += set.weight * set.reps;
      }
    }

    return total;
  }
}

// ============================================================
// DATABASE CONNECTION
// ============================================================

QueryExecutor _openConnection() {
  return driftDatabase(name: 'gym_tracker_database');
}
