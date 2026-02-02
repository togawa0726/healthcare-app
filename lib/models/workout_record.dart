class WorkoutRecord {
  final String id;
  final String date; // yyyy-MM-dd
  final String type;
  final String startTime;
  final int duration;
  final int calories;
  final double distance;
  final int? heartRate;
  final String? notes;

  WorkoutRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.startTime,
    required this.duration,
    required this.calories,
    required this.distance,
    this.heartRate,
    this.notes,
  });
}
