// models/workout_data.dart
class WorkoutData {
  final String type;
  final DateTime date;
  final String startTime;
  final double duration; // 分単位
  final int calories;
  final double distance; // km
  final double? heartRate;
  final String? notes;

  WorkoutData({
    required this.type,
    required this.date,
    required this.startTime,
    required this.duration,
    required this.calories,
    required this.distance,
    this.heartRate,
    this.notes,
  });
}
