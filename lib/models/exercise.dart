class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String equipment;

  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup,
      'equipment': equipment,
    };
  }

  factory Exercise.fromMap(Map<dynamic, dynamic> map) {
    return Exercise(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      muscleGroup: map['muscleGroup']?.toString() ?? '',
      equipment: map['equipment']?.toString() ?? '',
    );
  }
}
