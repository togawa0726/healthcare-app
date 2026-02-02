import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyStatsScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const MonthlyStatsScreen({super.key, this.onBack});

  // ===== モックデータ =====
  static const int totalCalories = 12450;
  static const int totalActiveMinutes = 1250;
  static const double totalDistance = 89.5;
  static const int totalWorkouts = 28;
  static const String currentMonth = '2025年11月';

  static const weeklyCaloriesData = [
    {'week': '第1週', 'calories': 2800.0},
    {'week': '第2週', 'calories': 3200.0},
    {'week': '第3週', 'calories': 2950.0},
    {'week': '第4週', 'calories': 3500.0},
  ];

  static const workoutTypeData = [
    {'name': 'ウォーキング', 'value': 45.0, 'color': Colors.blue},
    {'name': 'ランニング', 'value': 25.0, 'color': Colors.green},
    {'name': 'サイクリング', 'value': 15.0, 'color': Colors.orange},
    {'name': 'その他', 'value': 15.0, 'color': Colors.purple},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatsGrid(),
                  const SizedBox(height: 24),
                  _buildWeeklyCaloriesChart(),
                  const SizedBox(height: 24),
                  _buildWorkoutTypeChart(),
                  const SizedBox(height: 24),
                  _buildDailyAverage(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Header =====
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff2563eb), Color(0xff1d4ed8)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onBack != null)
            GestureDetector(
              onTap: onBack,
              child: const Row(
                children: [
                  Icon(Icons.arrow_back, color: Colors.white),
                  SizedBox(width: 8),
                  Text('戻る', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.white),
              SizedBox(width: 8),
              Text(
                '月間統計',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            currentMonth,
            style: TextStyle(color: Color(0xffbfdbfe)),
          ),
        ],
      ),
    );
  }

  // ===== Stats Cards =====
  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _statCard('総消費カロリー', totalCalories.toString(), 'kcal'),
        _statCard(
          '総運動時間',
          (totalActiveMinutes ~/ 60).toString(),
          '時間 ${totalActiveMinutes % 60}分',
        ),
        _statCard('総移動距離', totalDistance.toString(), 'km'),
        _statCard('運動回数', totalWorkouts.toString(), '回'),
      ],
    );
  }

  Widget _statCard(String title, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 22)),
          Text(unit, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // ===== Weekly Calories Bar Chart =====
  Widget _buildWeeklyCaloriesChart() {
    return _card(
      title: '週別消費カロリー',
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            barGroups: List.generate(weeklyCaloriesData.length, (i) {
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: weeklyCaloriesData[i]['calories'] as double,
                    width: 18,
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              );
            }),
            titlesData: FlTitlesData(
              leftTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: true)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    return Text(
                      weeklyCaloriesData[value.toInt()]['week'] as String,
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            gridData: const FlGridData(show: true),
          ),
        ),
      ),
    );
  }

  // ===== Workout Type Pie Chart =====
  Widget _buildWorkoutTypeChart() {
    return _card(
      title: '運動種別の内訳',
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: workoutTypeData.map((item) {
                  return PieChartSectionData(
                    value: item['value'] as double,
                    color: item['color'] as Color,
                    radius: 60,
                    title: '${item['value']}%',
                    titleStyle: const TextStyle(
                        color: Colors.white, fontSize: 12),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 4,
            children: workoutTypeData.map((item) {
              return Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: item['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(item['name'] as String),
                  const Spacer(),
                  Text('${item['value']}%'),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ===== Daily Average =====
  Widget _buildDailyAverage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xffdbeafe), Color(0xffbfdbfe)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _averageItem(
              'カロリー', (totalCalories ~/ 30).toString(), 'kcal'),
          _averageItem(
              '運動時間', (totalActiveMinutes ~/ 30).toString(), '分'),
          _averageItem(
              '距離', (totalDistance / 30).toStringAsFixed(1), 'km'),
        ],
      ),
    );
  }

  Widget _averageItem(String title, String value, String unit) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 18)),
        Text(unit, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  // ===== Card Wrapper =====
  Widget _card({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
