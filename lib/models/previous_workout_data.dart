import '../database/app_database.dart';

class PreviousWorkoutData {
  final Workout workout;
  final List<WorkoutSet> sets;

  const PreviousWorkoutData({required this.workout, required this.sets});
}
