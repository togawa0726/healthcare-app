import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// ----------------------
// データモデル
// ----------------------
class ActivityData {
  final int day;
  final int calories;

  ActivityData({required this.day, required this.calories});
}

class ActivityBreakdown {
  final String activity;
  final int calories;
  final int percentage;

  ActivityBreakdown({
    required this.activity,
    required this.calories,
    required this.percentage,
  });
}

// ----------------------
// カロリー詳細画面
// ----------------------
class CaloriesDetailScreen extends StatelessWidget {
  final VoidCallback onBack;
  final int todayCalories;
  final int weeklyAvg;
  final int monthlyTotal;
  final int goalCalories;
  final List<ActivityData> weeklyData;
  final List<ActivityData> monthlyData;
  final List<ActivityBreakdown> breakdownData;

  const CaloriesDetailScreen({
    super.key,
    required this.onBack,
    required this.todayCalories,
    required this.weeklyAvg,
    required this.monthlyTotal,
    required this.goalCalories,
    required this.weeklyData,
    required this.monthlyData,
    required this.breakdownData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Header =====
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBack,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("消費カロリー",
                          style: GoogleFonts.notoSans(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("詳細な記録と統計",
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ===== Today’s Card =====
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(PhosphorIconsRegular.flame, color: Colors.white),
                        SizedBox(width: 8),
                        Text("今日の消費カロリー",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("$todayCalories",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Text("kcal",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 20)),
                      ],
                    ),
                    Text(
                      "目標: $goalCalories kcal (${((todayCalories / goalCalories) * 100).toStringAsFixed(0)}%)",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: todayCalories / goalCalories,
                        color: Colors.white,
                        backgroundColor: Colors.white24,
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ===== Summary =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard(
                    icon: PhosphorIconsRegular.calendar,
                    label: "今日",
                    value: "$todayCalories",
                    unit: "kcal",
                    color: Colors.orange,
                  ),
                  _buildStatCard(
                    icon: PhosphorIconsRegular.trendUp,
                    label: "週平均",
                    value: "$weeklyAvg",
                    unit: "kcal",
                    color: Colors.blue,
                  ),
                  _buildStatCard(
                    icon: PhosphorIconsRegular.target,
                    label: "月合計",
                    value: (monthlyTotal / 1000).toStringAsFixed(1),
                    unit: "K kcal",
                    color: Colors.green,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ===== Weekly Chart =====
              _buildChartCard("週間の消費カロリー", _buildWeeklyChart()),

              const SizedBox(height: 20),

              // ===== Monthly Trend =====
              _buildChartCard("月間推移", _buildMonthlyChart()),

              const SizedBox(height: 20),

              // ===== Breakdown =====
              _buildChartCard("活動別の内訳", _buildActivityBreakdown()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(unit, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: weeklyData
              .map((data) => BarChartGroupData(
                    x: data.day,
                    barRods: [
                      BarChartRodData(
                        toY: data.calories.toDouble(),
                        color: const Color(0xFFF97316),
                        borderRadius: BorderRadius.circular(6),
                      )
                    ],
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildMonthlyChart() {
    return SizedBox(
      height: 200,
      child: LineChart(LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: monthlyData
                .map((data) => FlSpot(data.day.toDouble(), data.calories.toDouble()))
                .toList(),
            isCurved: true,
            color: const Color(0xFFF97316),
            barWidth: 3,
            dotData: FlDotData(show: true),
          )
        ],
      )),
    );
  }

  Widget _buildActivityBreakdown() {
    return Column(
      children: breakdownData
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.activity,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text(
                        "${item.calories} kcal (${item.percentage}%)",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: item.percentage / 100,
                    color: const Color(0xFFF97316),
                    backgroundColor: Colors.grey[300],
                    minHeight: 8,
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
