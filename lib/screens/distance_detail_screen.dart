import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class DistanceDetailScreen extends StatelessWidget {
  final VoidCallback onBack;

  const DistanceDetailScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final todayDistance = 7.9;
    final weeklyTotal = 53.8;
    final monthlyTotal = 204.4;
    final goalDistance = 10.0;

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
                      Text("移動距離",
                          style: GoogleFonts.notoSans(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("詳細な記録と統計",
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),

              // 今日の移動距離カード
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF22c55e), Color(0xFF16a34a)],
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
                        Icon(PhosphorIconsRegular.mapPin, color: Colors.white),
                        SizedBox(width: 8),
                        Text("今日の移動距離",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("$todayDistance",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Text("km",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 20)),
                      ],
                    ),
                    Text(
                      "目標: ${goalDistance.toStringAsFixed(1)}km (${((todayDistance / goalDistance) * 100).toStringAsFixed(0)}%)",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: todayDistance / goalDistance,
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
                      value: "$todayDistance",
                      unit: "km",
                      color: Colors.green),
                  _buildStatCard(
                      icon: PhosphorIconsRegular.trendUp,
                      label: "今週",
                      value: "$weeklyTotal",
                      unit: "km",
                      color: Colors.blue),
                  _buildStatCard(
                      icon: PhosphorIconsRegular.target,
                      label: "今月",
                      value: "$monthlyTotal",
                      unit: "km",
                      color: Colors.purple),
                ],
              ),

              const SizedBox(height: 20),

              // Weekly Chart
              _buildChartCard("週間の移動距離", _buildWeeklyChart()),

              const SizedBox(height: 20),

              // Monthly Trend Chart
              _buildChartCard("月間推移", _buildMonthlyChart()),

              const SizedBox(height: 20),

              // Recent Activities
              _buildChartCard("最近の活動", _buildRecentActivities()),
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

  Widget _buildWeeklyChart() {
    final data = [
      FlSpot(1, 6.6),
      FlSpot(2, 7.6),
      FlSpot(3, 6.3),
      FlSpot(4, 8.2),
      FlSpot(5, 7.2),
      FlSpot(6, 10.0),
      FlSpot(7, 7.9),
    ];

    return SizedBox(
      height: 220,
      child: LineChart(LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data,
            isCurved: true,
            color: const Color(0xFF22c55e),
            barWidth: 4,
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF86efac).withOpacity(0.6),
            ),
            dotData: FlDotData(show: true),
          )
        ],
      )),
    );
  }

  Widget _buildMonthlyChart() {
    final data = [
      FlSpot(1, 48.5),
      FlSpot(2, 52.3),
      FlSpot(3, 49.8),
      FlSpot(4, 53.8),
    ];

    return SizedBox(
      height: 200,
      child: BarChart(BarChartData(
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        barGroups: data
            .map((spot) => BarChartGroupData(x: spot.x.toInt(), barRods: [
                  BarChartRodData(
                      toY: spot.y,
                      color: const Color(0xFF22c55e),
                      width: 22,
                      borderRadius: BorderRadius.circular(8))
                ]))
            .toList(),
      )),
    );
  }

  Widget _buildRecentActivities() {
    final activities = [
      {'date': '10月31日', 'activity': 'ランニング', 'distance': 7.9, 'duration': 45},
      {'date': '10月30日', 'activity': 'ウォーキング', 'distance': 10.0, 'duration': 120},
      {'date': '10月29日', 'activity': 'サイクリング', 'distance': 25.0, 'duration': 90},
      {'date': '10月28日', 'activity': 'ランニング', 'distance': 8.2, 'duration': 48},
    ];

    return Column(
      children: activities
          .map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['activity'] as String,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          Text(item['date'] as String,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600])),
                        ]),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("${item['distance']}km",
                              style: const TextStyle(fontSize: 16)),
                          Text("${item['duration']}分",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600])),
                        ]),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
