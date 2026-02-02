import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class StepsScreen extends StatefulWidget {
  const StepsScreen({super.key});

  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  String period = 'week';

  final List<Map<String, dynamic>> monthlyData = [
    {'date': '1日', 'steps': 8234},
    {'date': '2日', 'steps': 9521},
    {'date': '3日', 'steps': 7832},
    {'date': '4日', 'steps': 10234},
    {'date': '5日', 'steps': 8945},
    {'date': '6日', 'steps': 12456},
    {'date': '7日', 'steps': 9876},
    {'date': '8日', 'steps': 11234},
    {'date': '9日', 'steps': 8567},
    {'date': '10日', 'steps': 9234},
  ];

  final totalSteps = 96189;
  final avgSteps = 9619;
  final bestDay = 12456;
  final daysGoalAchieved = 24;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9fafb),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text("歩数記録",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 4),
              const Text("詳細な歩数データと統計", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),

              // Period selector
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => period = 'week'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: period == 'week' ? Colors.blue : Colors.white,
                        foregroundColor: period == 'week' ? Colors.white : Colors.grey[700],
                        side: BorderSide(color: period == 'week' ? Colors.blue : Colors.grey[300]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("週間"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => period = 'month'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: period == 'month' ? Colors.blue : Colors.white,
                        foregroundColor: period == 'month' ? Colors.white : Colors.grey[700],
                        side: BorderSide(color: period == 'month' ? Colors.blue : Colors.grey[300]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("月間"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Stats cards
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard("平均歩数", avgSteps.toString(), "歩/日",
                      Colors.blue, PhosphorIconsRegular.trendUp),
                  _buildStatCard("最高記録", bestDay.toString(), "歩",
                      Colors.green, PhosphorIconsRegular.medal),
                  _buildStatCard("目標達成", daysGoalAchieved.toString(), "日",
                      Colors.purple, PhosphorIconsRegular.target),
                  _buildStatCard("総歩数", "${(totalSteps / 1000).toStringAsFixed(1)}K", "歩",
                      Colors.orange, PhosphorIconsRegular.calendar),
                ],
              ),
              const SizedBox(height: 24),

              // Chart
              _buildChartCard(),

              const SizedBox(height: 24),

              // Daily records
              _buildRecentRecords(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String unit, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.85), color]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(6),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ]),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(unit, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
    );
  }

  Widget _buildChartCard() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
        BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3)),
      ]),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("歩数推移",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(drawVerticalLine: false, horizontalInterval: 2000),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) => Text(value.toInt().toString(),
                          style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < monthlyData.length) {
                          return Text(monthlyData[index]['date'], style: const TextStyle(fontSize: 10));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(monthlyData.length, (index) {
                  final steps = monthlyData[index]['steps'] as int;
                  return BarChartGroupData(x: index, barRods: [
                    BarChartRodData(
                      toY: steps.toDouble(),
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(6),
                      width: 14,
                    ),
                  ]);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRecords() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
        BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3)),
      ]),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("最近の記録",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 12),
        Column(
          children: monthlyData.take(5).map((item) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.all(6),
                      child: Icon(PhosphorIconsRegular.calendar, color: Colors.blue[600], size: 18),
                    ),
                    const SizedBox(width: 10),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item['date'], style: const TextStyle(color: Colors.black87, fontSize: 14)),
                      const Text("2025年10月", style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ]),
                  ]),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(item['steps'].toString(),
                          style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      const Text("歩", style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }
}
