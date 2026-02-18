import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutData {
  final String type;
  final String date;
  final String startTime;
  final double duration;
  final int calories;
  final double distance;
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

  factory WorkoutData.fromJson(Map<String, dynamic> json) {
    return WorkoutData(
      type: json['type'],
      date: json['date'],
      startTime: json['startTime'],
      duration: (json['duration'] as num).toDouble(),
      calories: json['calories'],
      distance: (json['distance'] as num).toDouble(),
      heartRate: json['heartRate'] != null
          ? (json['heartRate'] as num).toDouble()
          : null,
      notes: json['notes'],
    );
  }
}

class CalendarScreen extends StatefulWidget {
  final VoidCallback onNavigateToAddWorkout;

  const CalendarScreen({
    super.key,
    required this.onNavigateToAddWorkout,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<WorkoutData> workoutRecords = [];

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored =
        prefs.getStringList('workouts') ?? [];

    setState(() {
      workoutRecords = stored
          .map((e) => WorkoutData.fromJson(jsonDecode(e)))
          .toList();
    });
  }

  String _formatDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  List<WorkoutData> _getRecordsForDate(DateTime date) {
    final key = _formatDateKey(date);
    return workoutRecords.where((r) => r.date == key).toList();
  }

  bool _hasWorkout(DateTime date) {
    return _getRecordsForDate(date).isNotEmpty;
  }

  int get _thisMonthWorkoutDays {
    final now = DateTime.now();
    final monthKey = DateFormat('yyyy-MM').format(now);

    return workoutRecords
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
        records.fold<int>(0, (sum, r) => sum + r.duration.toInt());

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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          setState(() {
            _selectedDate = selectedDay;
            _focusedDay = focusedDay;
          });
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
    List<WorkoutData> records,
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
