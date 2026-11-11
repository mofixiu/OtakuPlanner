import 'package:flutter/material.dart';
import 'package:otakuplanner/screens/normalMode/achievements.dart';
import 'package:otakuplanner/screens/normalMode/calendar.dart';
import 'package:otakuplanner/screens/normalMode/dashboard.dart';
import 'package:otakuplanner/screens/normalMode/settings.dart';
import 'package:otakuplanner/screens/normalMode/tasks.dart';
import 'package:otakuplanner/themes/tokens.dart';

/// The tab bar. The active tab is marked with the vermilion stamp.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, required this.currentIndex});

  final int currentIndex;

  static const _tabs = [
    (Icons.space_dashboard_outlined, Icons.space_dashboard, 'Today'),
    (Icons.calendar_month_outlined, Icons.calendar_month, 'Calendar'),
    (Icons.checklist_outlined, Icons.checklist, 'Tasks'),
    (Icons.military_tech_outlined, Icons.military_tech, 'Badges'),
    (Icons.settings_outlined, Icons.settings, 'Settings'),
  ];

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;
    final Widget next = switch (index) {
      0 => const Dashboard(),
      1 => const Calendar(),
      2 => const Tasks(),
      3 => const Achievements(),
      _ => const Settings(),
    };
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => next,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    return Container(
      decoration: BoxDecoration(
        color: c.paper,
        border: Border(top: BorderSide(color: c.ink, width: Strokes.panel)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: _Tab(
                    icon: i == currentIndex ? _tabs[i].$2 : _tabs[i].$1,
                    label: _tabs[i].$3,
                    active: i == currentIndex,
                    onTap: () => _navigate(context, i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.icon, required this.label, required this.active, required this.onTap});

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    return Semantics(
      selected: active,
      button: true,
      label: '$label tab',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: active ? c.ink : c.inkMuted),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              style: context.type.labelSmall?.copyWith(
                letterSpacing: 0,
                color: active ? c.ink : c.inkMuted,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            // The stamp: a small vermilion block under the active tab.
            Container(
              width: 18,
              height: 3,
              decoration: BoxDecoration(
                color: active ? c.stamp : Colors.transparent,
                borderRadius: Radii.controlAll,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
