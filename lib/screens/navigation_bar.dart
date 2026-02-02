import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NavigationBarWidget extends StatelessWidget {
  final String currentScreen;
  final void Function(String screen) onNavigate;

  const NavigationBarWidget({
    super.key,
    required this.currentScreen,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
  {'id': 'home', 'icon': PhosphorIconsRegular.house, 'label': 'ホーム'},
  {'id': 'activity', 'icon': PhosphorIconsRegular.sneakerMove, 'label': '運動'},
  {'id': 'calendar', 'icon': PhosphorIconsRegular.calendar, 'label': 'カレンダー'},
  {'id': 'monthly', 'icon': PhosphorIconsRegular.chartBar, 'label': '統計'},
  {'id': 'profile', 'icon': PhosphorIconsRegular.user, 'label': 'プロフィール'},
];

    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navItems.map((item) {
          final isActive = currentScreen == item['id'];
          final icon = item['icon'] as IconData;

          return Expanded(
            child: InkWell(
              onTap: () => onNavigate(item['id'] as String),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 26,
                      color: isActive ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: isActive ? Colors.blue : Colors.grey,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
