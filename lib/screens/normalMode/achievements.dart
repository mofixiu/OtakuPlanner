import 'package:flutter/material.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/shared/planner_stats.dart';
import 'package:otakuplanner/widgets/bottomNavBar.dart';
import 'package:otakuplanner/widgets/ink_kit.dart';
import 'package:provider/provider.dart';

enum _Show {
  all('All'),
  earned('Earned'),
  going('In progress'),
  locked('Locked');

  const _Show(this.label);
  final String label;
}

/// Badges earned from the user's own tasks and streaks. Every number here
/// is worked out from the planner; nothing is pre-filled.
class Achievements extends StatefulWidget {
  const Achievements({super.key});

  @override
  State<Achievements> createState() => _AchievementsState();
}

class _AchievementsState extends State<Achievements> {
  _Show _show = _Show.all;

  bool _visible(BadgeProgress b) => switch (_show) {
        _Show.all => true,
        _Show.earned => b.earned,
        _Show.going => b.started && !b.earned,
        _Show.locked => !b.started,
      };

  @override
  Widget build(BuildContext context) {
    final stats = PlannerStats(Provider.of<TaskProvider>(context).tasks);
    final badges = stats.badges;
    final earned = badges.where((b) => b.earned).length;
    final closest = (badges.where((b) => !b.earned).toList()
          ..sort((a, b) => b.fraction.compareTo(a.fraction)))
        .firstOrNull;

    final groups = <String, List<BadgeProgress>>{};
    for (final b in badges.where(_visible)) {
      groups.putIfAbsent(b.badge.group, () => []).add(b);
    }

    return Scaffold(
      appBar: const PlannerAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.page, Space.l, Space.page, Space.l),
        children: [
          Text('Badges', style: context.type.displaySmall),
          const SizedBox(height: Space.m),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$earned', style: TypeScale.stat(context.ink.ink)),
                    Text(
                      ' of ${badges.length} earned',
                      style: context.type.titleMedium?.copyWith(color: context.ink.inkMuted),
                    ),
                    const Spacer(),
                    Kicker('Best run · Ep. ${stats.bestStreak.toString().padLeft(2, '0')}'),
                  ],
                ),
                const SizedBox(height: Space.s),
                ToneBar(value: earned / badges.length),
                if (closest != null) ...[
                  const SizedBox(height: Space.s),
                  Text(
                    'Closest: ${closest.badge.title}, ${closest.current} of ${closest.badge.goal}.',
                    style: context.type.bodySmall?.copyWith(fontFeatures: TypeScale.tabular),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: Space.gutter),
          InkSegmented<_Show>(
            segments: _Show.values,
            selected: _show,
            labelOf: (s) => s.label,
            onChanged: (s) => setState(() => _show = s),
          ),
          const SizedBox(height: Space.m),
          if (groups.isEmpty)
            EmptyState(
              message: switch (_show) {
                _Show.earned => 'No badges yet. Finish a task to earn the first one.',
                _Show.going => 'Nothing in progress. Finish a task to get one going.',
                _Show.locked => 'Every badge has been started.',
                _Show.all => 'No badges to show.',
              },
            )
          else
            for (final entry in groups.entries) ...[
              Kicker(entry.key),
              const SizedBox(height: Space.xs + 2),
              Panel(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < entry.value.length; i++) ...[
                      if (i > 0) const InkRule(indent: 68),
                      _BadgeRow(progress: entry.value[i]),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: Space.m),
            ],
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}

class _BadgeRow extends StatelessWidget {
  const _BadgeRow({required this.progress});

  final BadgeProgress progress;

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    final b = progress.badge;
    final status = progress.earned
        ? 'earned'
        : progress.started
            ? '${progress.current} of ${b.goal}'
            : 'locked';
    return Semantics(
      label: '${b.title}, ${b.description}, $status',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.all(Space.gutter),
        child: Row(
          children: [
            _BadgeMark(progress: progress),
            const SizedBox(width: Space.gutter),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          b.title,
                          style: context.type.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: progress.started ? c.ink : c.inkMuted,
                          ),
                        ),
                      ),
                      Text(
                        progress.earned ? 'Earned' : '${progress.current}/${b.goal}',
                        style: context.type.labelMedium?.copyWith(
                          fontWeight: progress.earned ? FontWeight.w700 : FontWeight.w500,
                          color: progress.started ? c.ink : c.inkMuted,
                          fontFeatures: TypeScale.tabular,
                        ),
                      ),
                    ],
                  ),
                  Text(b.description, style: context.type.bodySmall),
                  if (!progress.earned) ...[
                    const SizedBox(height: Space.s),
                    ToneBar(value: progress.fraction, height: 8),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Earned: solid ink. In progress: ink outline. Locked: printed screentone.
class _BadgeMark extends StatelessWidget {
  const _BadgeMark({required this.progress});

  final BadgeProgress progress;

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    const size = 44.0;
    final icon = progress.started ? progress.badge.icon : Icons.lock_outline;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: progress.earned ? c.ink : c.paper,
        border: Border.all(color: c.ink, width: Strokes.panel),
        borderRadius: Radii.controlAll,
      ),
      child: ClipRRect(
        borderRadius: Radii.controlAll,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!progress.started) const Screentone(tone: Tone.dots, opacity: 0.4),
            Center(
              child: Container(
                padding: progress.started ? EdgeInsets.zero : const EdgeInsets.all(3),
                color: progress.started ? null : c.paper,
                child: Icon(icon, size: progress.started ? 22 : 16, color: progress.earned ? c.paper : c.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
