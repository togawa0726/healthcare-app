import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weightData = [
      {'date': '10/1', 'value': 72.5},
      {'date': '10/8', 'value': 72.0},
      {'date': '10/15', 'value': 71.8},
      {'date': '10/22', 'value': 71.5},
      {'date': '10/29', 'value': 71.2},
    ];

    final heartRateData = [
      {'time': '6:00', 'value': 65},
      {'time': '9:00', 'value': 72},
      {'time': '12:00', 'value': 78},
      {'time': '15:00', 'value': 75},
      {'time': '18:00', 'value': 82},
      {'time': '21:00', 'value': 68},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text("健康データ",
                  style: GoogleFonts.notoSans(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("体調管理と記録", style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 20),

              // Health Metrics Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _metricCard(
                    color1: Colors.red.shade500,
                    color2: Colors.red.shade600,
                    icon: PhosphorIconsRegular.heart,
                    label: "心拍数",
                    value: "72",
                    unit: "bpm",
                  ),
                  _metricCard(
                    color1: Colors.blue.shade500,
                    color2: Colors.blue.shade600,
                    icon: PhosphorIconsRegular.gauge,
                    label: "体重",
                    value: "71.2",
                    unit: "kg",
                  ),
                  _metricCard(
                    color1: Colors.purple.shade500,
                    color2: Colors.purple.shade600,
                    icon: PhosphorIconsRegular.moon,
                    label: "睡眠",
                    value: "7.5",
                    unit: "時間",
                  ),
                  _metricCard(
                    color1: Colors.cyan.shade500,
                    color2: Colors.cyan.shade600,
                    icon: PhosphorIconsRegular.drop,
                    label: "水分補給",
                    value: "1.8",
                    unit: "リットル",
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Weight Chart
              _buildChartCard(
                "体重の推移",
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.trending_up, color: Colors.green, size: 18),
                    SizedBox(width: 4),
                    Text("-1.3kg",
                        style: TextStyle(color: Colors.green, fontSize: 14)),
                  ],
                ),
                chart: _buildLineChart(weightData,
                    color: Colors.blue, yMin: 70, yMax: 73),
              ),

              const SizedBox(height: 20),

              // Heart Rate Chart
              _buildChartCard(
                "今日の心拍数",
                chart: _buildLineChart(heartRateData,
                    color: Colors.red, yMin: 60, yMax: 90),
              ),

              const SizedBox(height: 20),

              // Health Tips
              _buildTipsSection(),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------
  // ✅ Metrics Card
  // -------------------------------
  Widget _metricCard({
    required Color color1,
    required Color color2,
    required IconData icon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color2.withOpacity(0.4), blurRadius: 6),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white)),
            ],
          ),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          Text(unit, style: const TextStyle(color: Colors.white70, fontSize: 12))
        ],
      ),
    );
  }

  // -------------------------------
  // ✅ Chart Card Wrapper
  // -------------------------------
  Widget _buildChartCard(String title,
      {Widget? trailing, required Widget chart}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          chart,
        ],
      ),
    );
  }

  // -------------------------------
  // ✅ Line Chart (weight / heart)
  // -------------------------------
  Widget _buildLineChart(List<Map<String, dynamic>> data,
      {required Color color, required double yMin, required double yMax}) {
    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), (e.value['value'] as num).toDouble()))
        .toList();

    return SizedBox(
      height: 200,
      child: LineChart(LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(show: false),
        minY: yMin,
        maxY: yMax,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            belowBarData: BarAreaData(
                show: true, color: color.withOpacity(0.2)),
            dotData: FlDotData(show: true),
          )
        ],
      )),
    );
  }

  // -------------------------------
  // ✅ Health Tips Section
  // -------------------------------
  Widget _buildTipsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("健康アドバイス",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _tipCard(
            bg: Colors.green.shade50,
            iconBg: Colors.green.shade100,
            icon: PhosphorIconsRegular.sneaker,
            title: "素晴らしい進捗です！",
            message: "この調子で運動を続けましょう",
            iconColor: Colors.green.shade600,
          ),
          const SizedBox(height: 8),
          _tipCard(
            bg: Colors.blue.shade50,
            iconBg: Colors.blue.shade100,
            icon: PhosphorIconsRegular.drop,
            title: "水分補給を忘れずに",
            message: "1日2リットルを目標にしましょう",
            iconColor: Colors.blue.shade600,
          ),
          const SizedBox(height: 8),
          _tipCard(
            bg: Colors.purple.shade50,
            iconBg: Colors.purple.shade100,
            icon: PhosphorIconsRegular.moon,
            title: "良い睡眠をとっています",
            message: "7-8時間の睡眠は健康の基本です",
            iconColor: Colors.purple.shade600,
          ),
        ],
      ),
    );
  }

  Widget _tipCard({
    required Color bg,
    required Color iconBg,
    required IconData icon,
    required String title,
    required String message,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                Text(message,
                    style:
                        TextStyle(color: Colors.grey[700], fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
