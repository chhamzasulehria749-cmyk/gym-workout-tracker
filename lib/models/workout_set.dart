class WorkoutSet {
  final double weight;
  final int reps;
  final String type;
  final bool completed;

  WorkoutSet({
    required this.weight,
    required this.reps,
    this.type = 'working',
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'weight': weight,
      'reps': reps,
      'type': type,
      'completed': completed,
    };
  }

  factory WorkoutSet.fromMap(Map<dynamic, dynamic> map) {
    return WorkoutSet(
      weight: double.tryParse(map['weight']?.toString() ?? '0') ?? 0,
      reps: int.tryParse(map['reps']?.toString() ?? '0') ?? 0,
      type: map['type']?.toString() ?? 'working',
      completed: map['completed'] == true,
    );
  }
}
