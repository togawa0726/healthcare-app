import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ActiveTimeDetailScreen extends StatelessWidget {
  final VoidCallback onBack;
  final int todayMinutes;
  final int weeklyTotal;
  final int monthlyTotal;
  final int goalMinutes;

  const ActiveTimeDetailScreen({
    super.key,
    required this.onBack,
    required this.todayMinutes,
    required this.weeklyTotal,
    required this.monthlyTotal,
    this.goalMinutes = 120,
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
              // Header
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
                      Text("運動時間",
                          style: GoogleFonts.notoSans(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("詳細な記録と統計",
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),

              // 今日の運動カード
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFa855f7), Color(0xFF7e22ce)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(PhosphorIconsRegular.clock, color: Colors.white),
                        SizedBox(width: 8),
                        Text("今日の運動時間",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("$todayMinutes",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Text("分",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 20)),
                      ],
                    ),
                    Text(
                      "目標: $goalMinutes分 (${((todayMinutes / goalMinutes) * 100).toStringAsFixed(0)}%)",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: todayMinutes / goalMinutes.toDouble(),
                        color: Colors.white,
                        backgroundColor: Colors.white24,
                        minHeight: 10,
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Stats summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard(
                      icon: PhosphorIconsRegular.calendar,
                      label: "今日",
                      value: "$todayMinutes",
                      unit: "分",
                      color: Colors.purple),
                  _buildStatCard(
                      icon: PhosphorIconsRegular.trendUp,
                      label: "今週",
                      value: "$weeklyTotal",
                      unit: "分",
                      color: Colors.blue),
                  _buildStatCard(
                      icon: PhosphorIconsRegular.target,
                      label: "今月",
                      value: (monthlyTotal / 60).toStringAsFixed(1),
                      unit: "時間",
                      color: Colors.green),
                ],
              ),

              const SizedBox(height: 20),

              _buildChartCard("週間の運動時間", _buildWeeklyChart()),
              const SizedBox(height: 20),
              _buildChartCard("月間推移", _buildMonthlyChart()),
              const SizedBox(height: 20),
              _buildChartCard("活動の種類別", _buildActivityPieChart()),
              const SizedBox(height: 20),
              _buildChartCard("運動強度の内訳", _buildIntensityBars()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      {required IconData icon,
      required String label,
      required String value,
      required String unit,
      required Color color}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(unit, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
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

  // ------------------------
  // グラフ部分（fl_chart 0.69対応）
  // ------------------------
  Widget _buildWeeklyChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 30),
                FlSpot(1, 45),
                FlSpot(2, 40),
                FlSpot(3, 50),
                FlSpot(4, 60),
                FlSpot(5, 55),
                FlSpot(6, 70),
              ],
              isCurved: true,
              barWidth: 3,
              color: Colors.purple, // ← colorsではなく color
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChart() {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(show: true),
          barGroups: List.generate(7, (i) {
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: (i + 1) * 10, color: Colors.blue)
            ]);
          }),
        ),
      ),
    );
  }

  Widget _buildActivityPieChart() {
    return SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: 40,
              color: Colors.purple,
              title: "ウォーキング",
            ),
            PieChartSectionData(
              value: 30,
              color: Colors.blue,
              title: "ランニング",
            ),
            PieChartSectionData(
              value: 30,
              color: Colors.green,
              title: "自転車",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntensityBars() {
    return SizedBox(
      height: 150,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(show: true),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 30, color: Colors.red)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 50, color: Colors.orange)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 20, color: Colors.green)]),
          ],
        ),
      ),
    );
  }
}
