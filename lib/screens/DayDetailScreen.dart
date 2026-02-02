import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/workout_record.dart';

class DayDetailScreen extends StatelessWidget {
  final DateTime selectedDate;
  final List<WorkoutRecord> workoutRecords;
  final VoidCallback onBack;

  const DayDetailScreen({
    super.key,
    required this.selectedDate,
    required this.workoutRecords,
    required this.onBack,
  });

  String _formatDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final key = _formatDateKey(selectedDate);
    final dayRecords =
        workoutRecords.where((r) => r.date == key).toList();

    final totalCalories =
        dayRecords.fold<int>(0, (sum, r) => sum + r.calories);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('運動記録の詳細'),
      ),
      body: dayRecords.isEmpty
          ? const Center(child: Text('この日の運動記録はありません'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  DateFormat.yMMMMd('ja').format(selectedDate),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text('合計カロリー: $totalCalories kcal'),
                const SizedBox(height: 16),
                ...dayRecords.map(
                  (r) => Card(
                    child: ListTile(
                      title: Text(r.type),
                      subtitle: Text(
                        '${r.startTime} / ${r.duration}分 / ${r.calories}kcal',
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
