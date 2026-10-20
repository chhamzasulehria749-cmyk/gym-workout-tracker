import 'workout_set.dart';

class WorkoutExercise {
  final String exerciseId;
  final String name;
  final String muscleGroup;
  final List<WorkoutSet> sets;

  WorkoutExercise({
    required this.exerciseId,
    required this.name,
    required this.muscleGroup,
    required this.sets,
  });

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'name': name,
      'muscleGroup': muscleGroup,
      'sets': sets.map((set) => set.toMap()).toList(),
    };
  }

  factory WorkoutExercise.fromMap(Map<dynamic, dynamic> map) {
    final setsData = map['sets'];

    return WorkoutExercise(
      exerciseId: map['exerciseId']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Exercise',
      muscleGroup: map['muscleGroup']?.toString() ?? 'Other',
      sets: setsData is List
          ? setsData.map((set) => WorkoutSet.fromMap(set)).toList()
          : [],
    );
  }
}
