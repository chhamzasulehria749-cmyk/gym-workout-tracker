import 'workout_exercise.dart';

class Workout {
  final String id;
  final String name;
  final DateTime date;
  final int duration;
  final String notes;
  final List<WorkoutExercise> exercises;

  Workout({
    required this.id,
    required this.name,
    required this.date,
    this.duration = 0,
    this.notes = '',
    required this.exercises,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'duration': duration,
      'notes': notes,
      'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
    };
  }

  factory Workout.fromMap(Map<dynamic, dynamic> map) {
    final exercisesData = map['exercises'];

    return Workout(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Workout',
      date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
      duration: int.tryParse(map['duration']?.toString() ?? '0') ?? 0,
      notes: map['notes']?.toString() ?? '',
      exercises: exercisesData is List
          ? exercisesData
                .map((exercise) => WorkoutExercise.fromMap(exercise))
                .toList()
          : [],
    );
  }
}
