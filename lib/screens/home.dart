import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  final int steps; // main.dart から渡されるリアル歩数
  final void Function(String screen) onNavigate;

  const HomeScreen({
    super.key,
    required this.steps,
    required this.onNavigate,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ⭐ 今日の曜日に合わせた週間データ生成
  List<Map<String, Object>> _generateWeeklyData(int todaySteps) {
    const weekDays = ["月", "火", "水", "木", "金", "土", "日"];
    int todayIndex = DateTime.now().weekday - 1;

    List<Map<String, Object>> weekly = [];

    for (int i = 0; i < 7; i++) {
      int index = (i + todayIndex + 1) % 7;
      weekly.add({
        'day': weekDays[index],
        'steps': 0,
      });
    }

    weekly[6]['steps'] = todaySteps;
    return weekly;
  }

  @override
  Widget build(BuildContext context) {
    final int todaySteps = widget.steps;
    final int goalSteps = 10000;

    final int calories = (todaySteps * 0.04).floor();
    final double distance = todaySteps * 0.0008;
    final int activeMinutes = (todaySteps / 100).floor();

    final weeklyData = _generateWeeklyData(todaySteps);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "ヘルスケアダッシュボード",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text("今日も頑張りましょう！",
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),

              _buildMainStepCard(todaySteps, goalSteps),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statCard(
                    context,
                    color: Colors.orange,
                    icon: PhosphorIconsRegular.flame,
                    label: "カロリー",
                    value: "$calories",
                    unit: "kcal",
                    onTap: () => widget.onNavigate('calories-detail'),
                  ),
                  _statCard(
                    context,
                    color: Colors.green,
                    icon: PhosphorIconsRegular.trendUp,
                    label: "距離",
                    value: distance.toStringAsFixed(2),
                    unit: "km",
                    onTap: () => widget.onNavigate('distance-detail'),
                  ),
                  _statCard(
                    context,
                    color: Colors.purple,
                    icon: PhosphorIconsRegular.clock,
                    label: "運動時間",
                    value: "$activeMinutes",
                    unit: "分",
                    onTap: () => widget.onNavigate('time-detail'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildWeeklyStepsChart(weeklyData),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainStepCard(int todaySteps, int goalSteps) {
    final double progress = (todaySteps / goalSteps).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(PhosphorIconsRegular.footprints,
                      color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  const Text("今日の歩数",
                      style: TextStyle(color: Colors.white)),
                ],
              ),
              Text("${DateTime.now().month}/${DateTime.now().day}",
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(todaySteps.toString(),
                  style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(width: 6),
              const Text("歩",
                  style: TextStyle(fontSize: 20, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text("目標: ${goalSteps.toString()}歩",
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(width: 8),
              Text("(${(progress * 100).toStringAsFixed(0)}%)",
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.3),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(unit,
                  style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  // ⭐ 修正済：文字が潰れないようにしたグラフ
  Widget _buildWeeklyStepsChart(List<Map<String, Object>> weeklyData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("週間の歩数",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1.7,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1, // ← ★追加：潰れ防止
                      getTitlesWidget: (value, _) {
                        int index = value.toInt();
                        if (index < 0 || index >= weeklyData.length) {
                          return const SizedBox();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 6), // ← 余白で見やすく
                          child: Transform.rotate(
                            angle: -0.4, // ← 少し傾けて潰れ防止
                            child: Text(
                              weeklyData[index]['day'] as String,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles:
                        SideTitles(showTitles: true, reservedSize: 32),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.2),
                    ),
                    spots: List.generate(
                      weeklyData.length,
                      (i) => FlSpot(i.toDouble(),
                          (weeklyData[i]['steps'] as num).toDouble()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
