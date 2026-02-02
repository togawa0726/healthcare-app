import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
}

class AddWorkoutScreen extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(WorkoutData workout) onSave;

  const AddWorkoutScreen({
    super.key,
    required this.onBack,
    required this.onSave,
  });

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  String selectedType = '';
  DateTime selectedDate = DateTime.now();
  TimeOfDay? startTime;
  String duration = '';
  String distance = '';
  String heartRate = '';
  String notes = '';

  final workoutTypes = [
    {'id': 'walking', 'name': 'ウォーキング', 'icon': '🚶', 'cal': 4},
    {'id': 'running', 'name': 'ランニング', 'icon': '🏃', 'cal': 9},
    {'id': 'cycling', 'name': 'サイクリング', 'icon': '🚴', 'cal': 8},
    {'id': 'swimming', 'name': '水泳', 'icon': '🏊', 'cal': 10},
    {'id': 'yoga', 'name': 'ヨガ', 'icon': '🧘', 'cal': 3},
    {'id': 'stretch', 'name': 'ストレッチ', 'icon': '🤸', 'cal': 2},
    {'id': 'training', 'name': '筋トレ', 'icon': '💪', 'cal': 6},
    {'id': 'other', 'name': 'その他', 'icon': '⚡', 'cal': 5},
  ];

  int get estimatedCalories {
    final durationValue = double.tryParse(duration); // ★ 修正
    if (selectedType.isEmpty || durationValue == null) return 0;

    final type =
        workoutTypes.firstWhere((w) => w['id'] == selectedType);

    return (durationValue * (type['cal'] as int)).round();
  }

  void _save() {
    final durationValue = double.tryParse(duration);

    if (selectedType.isEmpty ||
        durationValue == null ||
        startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('必須項目を正しく入力してください')),
      );
      return;
    }

    final type =
        workoutTypes.firstWhere((w) => w['id'] == selectedType);

    final workout = WorkoutData(
      type: type['name'] as String,
      date:
          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
      startTime:
          '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}',
      duration: durationValue,
      calories: estimatedCalories,
      distance: double.tryParse(distance) ?? 0, // ★ 安全
      heartRate: heartRate.isNotEmpty
          ? double.tryParse(heartRate)
          : null,
      notes: notes.isNotEmpty ? notes : null,
    );

    widget.onSave(workout);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('運動記録を保存しました！')),
    );

    Future.delayed(const Duration(milliseconds: 500), widget.onBack);
  }

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
                  _buildWorkoutType(),
                  const SizedBox(height: 16),
                  _buildBasicInfo(),
                  const SizedBox(height: 16),
                  _buildOptionalInfo(),
                  const SizedBox(height: 16),
                  if (estimatedCalories > 0) _buildCalories(),
                  const SizedBox(height: 16),
                  _buildSaveButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== UI Parts =====

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff16a34a), Color(0xff15803d)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: widget.onBack,
            child: const Row(
              children: [
                Icon(Icons.arrow_back, color: Colors.white),
                SizedBox(width: 8),
                Text('戻る', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '運動を記録する',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          const Text(
            '今日の運動を記録しましょう',
            style: TextStyle(color: Color(0xffbbf7d0)),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutType() {
    return _card(
      title: '運動の種類',
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        children: workoutTypes.map((type) {
          final isSelected = selectedType == type['id'];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedType = type['id'] as String;
              });
            },
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xff16a34a)
                    : const Color(0xfff9fafb),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(type['icon'] as String,
                      style: const TextStyle(fontSize: 24)),
                  Text(
                    type['name'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return _card(
      title: '基本情報',
      child: Column(
        children: [
          ListTile(
            title: const Text('日付'),
            trailing: TextButton(
              child: Text(
                  '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}'),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
            ),
          ),
          ListTile(
            title: const Text('開始時刻'),
            trailing: TextButton(
              child: Text(startTime == null
                  ? '選択'
                  : startTime!.format(context)),
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(() => startTime = picked);
                }
              },
            ),
          ),
          TextField(
            decoration: const InputDecoration(labelText: '運動時間（分）'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // ★ 重要
            ],
            onChanged: (v) => setState(() => duration = v),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionalInfo() {
    return _card(
      title: '詳細情報（任意）',
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(labelText: '距離（km）'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            onChanged: (v) => distance = v,
          ),
          TextField(
            decoration: const InputDecoration(labelText: '平均心拍数'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (v) => heartRate = v,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'メモ'),
            maxLines: 3,
            onChanged: (v) => notes = v,
          ),
        ],
      ),
    );
  }

  Widget _buildCalories() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffffedd5), Color(0xfffed7aa)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Colors.orange),
          const SizedBox(width: 8),
          Text('推定消費カロリー: $estimatedCalories kcal'),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _save,
        child: const Text('記録を保存'),
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
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
