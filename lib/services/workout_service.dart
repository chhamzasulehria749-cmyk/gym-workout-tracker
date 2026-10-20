import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout.dart';

class WorkoutService {
  static const String boxName = 'workoutBox';

  Box get box => Hive.box(boxName);

  List<Workout> getWorkouts() {
    return box.values.map((value) {
      return Workout.fromMap(value);
    }).toList();
  }

  Future<void> addWorkout(Workout workout) async {
    await box.add(workout.toMap());
  }

  Future<void> updateWorkout(int index, Workout workout) async {
    await box.putAt(index, workout.toMap());
  }

  Future<void> deleteWorkout(int index) async {
    await box.deleteAt(index);
  }
}
