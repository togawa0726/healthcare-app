import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../models/workout_record.dart';

class CalendarScreen extends StatefulWidget {
  final List<WorkoutRecord> workoutRecords;
  final void Function(DateTime date) onNavigateToDayDetail;
  final VoidCallback onNavigateToAddWorkout;
  final VoidCallback? onBack;

  const CalendarScreen({
    super.key,
    required this.workoutRecords,
    required this.onNavigateToDayDetail,
    required this.onNavigateToAddWorkout,
    this.onBack,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  String _formatDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  List<WorkoutRecord> _getRecordsForDate(DateTime date) {
    final key = _formatDateKey(date);
    return widget.workoutRecords.where((r) => r.date == key).toList();
  }

  bool _hasWorkout(DateTime date) {
    return _getRecordsForDate(date).isNotEmpty;
  }

  int get _thisMonthWorkoutDays {
    final now = DateTime.now();
    final monthKey = DateFormat('yyyy-MM').format(now);

    return widget.workoutRecords
        .where((r) => r.date.startsWith(monthKey))
        .map((r) => r.date)
        .toSet()
        .length;
  }

  int get _daysInMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    final records = _getRecordsForDate(_selectedDate);
    final totalCalories =
        records.fold<int>(0, (sum, r) => sum + r.calories);
    final totalMinutes =
        records.fold<int>(0, (sum, r) => sum + r.duration);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onNavigateToAddWorkout,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCalendar(),
                  const SizedBox(height: 16),
                  _buildSelectedDateInfo(
                    records,
                    totalCalories,
                    totalMinutes,
                  ),
                  const SizedBox(height: 16),
                  _buildMonthlySummary(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple, Colors.deepPurple],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'カレンダー',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '運動記録をチェックしよう',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: TableCalendar(
        focusedDay: _focusedDay,
        firstDay: DateTime(2000),
        lastDay: DateTime(2100),
        selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
        onDaySelected: (selectedDay, focusedDay) {
          final isSame = isSameDay(selectedDay, _selectedDate);

          setState(() {
            _selectedDate = selectedDay;
            _focusedDay = focusedDay;
          });

          // ★ 同じ日を2回タップした場合のみ遷移
          if (isSame) {
            widget.onNavigateToDayDetail(selectedDay);
          }
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (_hasWorkout(date)) {
              return Positioned(
                bottom: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildSelectedDateInfo(
    List<WorkoutRecord> records,
    int totalCalories,
    int totalMinutes,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: records.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat.yMMMMd('ja').format(_selectedDate),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _infoTile('消費カロリー', '$totalCalories kcal'),
                      _infoTile('運動時間', '$totalMinutes 分'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children:
                        records.map((r) => Chip(label: Text(r.type))).toList(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        widget.onNavigateToDayDetail(_selectedDate),
                    child: const Text('詳細を見る'),
                  ),
                ],
              )
            : Column(
                children: [
                  const Text('この日の運動記録はありません'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: widget.onNavigateToAddWorkout,
                    child: const Text('運動を記録する'),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMonthlySummary() {
    final progress = _thisMonthWorkoutDays / _daysInMonth;

    return Card(
      color: Colors.purple.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('今月の運動日数'),
            const SizedBox(height: 8),
            Text(
              '$_thisMonthWorkoutDays日 / $_daysInMonth日',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Expanded(
      child: Card(
        color: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
