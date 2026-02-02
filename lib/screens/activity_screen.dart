import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class Activity {
  final int id;
  final String type;
  final String name;
  final int duration; // 分
  final int calories;
  final String date;
  final double? distance;

  Activity({
    required this.id,
    required this.type,
    required this.name,
    required this.duration,
    required this.calories,
    required this.date,
    this.distance,
  });
}

final Map<String, IconData> activityIcons = {
  'walking': PhosphorIconsRegular.footprints,
  'running': PhosphorIconsRegular.personSimpleRun,
  'cycling': PhosphorIconsRegular.bicycle,
  'gym': PhosphorIconsRegular.barbell,
  // 'swimming': PhosphorIconsRegular.swimmingPool, // 削除
};

final Map<String, Color> activityColors = {
  'walking': Colors.teal,
  'running': Colors.blue,
  'cycling': Colors.green,
  'gym': Colors.purple,
  // 'swimming': Colors.cyan, // 削除
};

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<Activity> activities = [];

  String selectedType = 'walking'; // デフォルトウォーキング
  int selectedDuration = 30; // デフォルト30分

  void _addActivity() {
    final newActivity = Activity(
      id: activities.length + 1,
      type: selectedType,
      name: _getActivityName(selectedType),
      duration: selectedDuration,
      calories: (selectedDuration * 5), // 仮計算: 1分5kcal
      date: DateTime.now().toIso8601String(),
      distance: (selectedType == 'walking' || selectedType == 'running')
          ? selectedDuration * 0.08 // 1分=80mの仮計算
          : null,
    );

    setState(() {
      activities.add(newActivity);
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalDuration = activities.fold<int>(0, (sum, a) => sum + a.duration);
    final totalCalories = activities.fold<int>(0, (sum, a) => sum + a.calories);
    final totalActivities = activities.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('運動記録'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryCard('運動回数', '$totalActivities', '回', Colors.indigo),
                _buildSummaryCard('合計時間', '$totalDuration', '分', Colors.green),
                _buildSummaryCard('消費カロリー', '$totalCalories', 'kcal', Colors.orange),
              ],
            ),
            const SizedBox(height: 24),

            // 運動タイプ選択
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: activityIcons.entries.map((e) {
                final color = activityColors[e.key]!;
                return GestureDetector(
                  onTap: () => setState(() => selectedType = e.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                      color: selectedType == e.key
                          ? color.withOpacity(0.3)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(e.value, color: color, size: 28),
                        const SizedBox(height: 2),
                        Text(
                          _getActivityName(e.key),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // 運動時間スライダー
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('運動時間: $selectedDuration 分'),
                Slider(
                  value: selectedDuration.toDouble(),
                  min: 5,
                  max: 180,
                  divisions: 35,
                  label: '$selectedDuration',
                  onChanged: (v) => setState(() => selectedDuration = v.toInt()),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _addActivity,
              child: const Text('運動を追加'),
            ),

            const SizedBox(height: 24),

            // 最近の運動リスト
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '最近の運動',
                    style: GoogleFonts.notoSans(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  ...activities.map((activity) {
                    final color = activityColors[activity.type] ?? Colors.grey;
                    final icon = activityIcons[activity.type];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: color, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(activity.name,
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w600)),
                                Text(
                                  _formatDate(activity.date),
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text('${activity.duration}分', style: TextStyle(color: Colors.grey[700])),
                                    const SizedBox(width: 16),
                                    Icon(Icons.local_fire_department, size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text('${activity.calories}kcal', style: TextStyle(color: Colors.grey[700])),
                                    if (activity.distance != null) ...[
                                      const SizedBox(width: 16),
                                      Icon(Icons.route, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text('${activity.distance?.toStringAsFixed(1)}km', style: TextStyle(color: Colors.grey[700])),
                                    ],
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, String unit, Color color) {
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
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(unit, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.month}月${date.day}日';
  }

  String _getActivityName(String key) {
    switch (key) {
      case 'walking':
        return 'ウォーキング';
      case 'running':
        return 'ランニング';
      case 'cycling':
        return 'サイクリング';
      case 'gym':
        return '筋トレ';
      // case 'swimming':
      //   return '水泳'; // 削除
      default:
        return '';
    }
  }
}
