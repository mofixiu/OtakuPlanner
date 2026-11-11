import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:otakuplanner/models/task.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/normalMode/editProfile.dart';
import 'package:otakuplanner/shared/planner_stats.dart';
import 'package:otakuplanner/widgets/ink_kit.dart';
import 'package:provider/provider.dart';

/// Who you are and what you've done, worked out from your own tasks.
class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    final tasks = Provider.of<TaskProvider>(context).tasks;
    final stats = PlannerStats(tasks);
    final summary = _Summary.of(tasks);

    final name = user.fullName.isNotEmpty ? user.fullName : _capitalise(user.username);
    final joined = DateTime.tryParse(user.joinDate);

    return Scaffold(
      appBar: const InkBackBar(title: 'Profile'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.page, Space.l, Space.page, Space.l),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Photo(path: user.profileImagePath, initial: user.username),
              const SizedBox(width: Space.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name.isEmpty ? 'Your profile' : name, style: context.type.displaySmall),
                    const SizedBox(height: Space.xs),
                    if (user.username.isNotEmpty)
                      Text('@${user.username}', style: context.type.bodyMedium),
                    if (user.email.isNotEmpty)
                      Text(user.email, style: context.type.bodySmall),
                    const SizedBox(height: Space.s),
                    InkButton.secondary(
                      label: 'Change photo',
                      icon: Icons.photo_camera_outlined,
                      small: true,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfile()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.l),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 4,
                  child: _StatPanel(
                    label: 'Tasks done',
                    child: Text('${stats.completedTotal}', style: TypeScale.stat(context.ink.ink)),
                  ),
                ),
                const SizedBox(width: Space.gutter),
                Expanded(
                  flex: 3,
                  child: _StatPanel(
                    label: 'Streak',
                    stamped: true,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Stamp(
                        'EP. ${stats.currentStreak.toString().padLeft(2, '0')}',
                        large: true,
                        filled: stats.currentStreak > 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Space.gutter),
                Expanded(
                  flex: 3,
                  child: _StatPanel(
                    label: 'Badges',
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '${stats.badgesEarned}'),
                          TextSpan(
                            text: '/${PlannerBadge.all.length}',
                            style: context.type.bodySmall?.copyWith(fontFeatures: TypeScale.tabular),
                          ),
                        ],
                      ),
                      style: TypeScale.stat(context.ink.ink),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.gutter),
          Panel(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _PanelLabel('Activity'),
                _FactRow(
                  label: 'Best streak',
                  value: stats.bestStreak == 1 ? '1 day' : '${stats.bestStreak} days',
                ),
                const InkRule(indent: Space.gutter),
                _FactRow(
                  label: 'Busiest day',
                  value: summary.busiestWeekday ?? 'Not yet',
                ),
                if (joined != null) ...[
                  const InkRule(indent: Space.gutter),
                  _FactRow(
                    label: 'Joined',
                    value: '${PlannerFormat.day(joined.toLocal())} ${joined.toLocal().year}',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: Space.gutter),
          Panel(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _PanelLabel('Top categories'),
                if (summary.topCategories.isEmpty)
                  const EmptyState(
                    message: 'Finish a task to see where your time goes.',
                    artHeight: 64,
                    padding: EdgeInsets.fromLTRB(Space.m, Space.s, Space.m, Space.m),
                  )
                else
                  for (var i = 0; i < summary.topCategories.length; i++) ...[
                    if (i > 0) const InkRule(indent: Space.gutter),
                    _CategoryRow(
                      category: summary.topCategories[i].key,
                      done: summary.topCategories[i].value,
                    ),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Counts from finished tasks that [PlannerStats] doesn't keep.
class _Summary {
  const _Summary({required this.busiestWeekday, required this.topCategories});

  /// "Saturday", or null before anything is finished.
  final String? busiestWeekday;

  /// Up to three categories with the most finished tasks.
  final List<MapEntry<String, int>> topCategories;

  static _Summary of(Map<DateTime, List<Task>> tasks) {
    final byWeekday = <int, int>{};
    final byCategory = <String, int>{};
    final names = <String, String>{};
    for (final entry in tasks.entries) {
      for (final task in entry.value.where((t) => t.isChecked)) {
        byWeekday.update(entry.key.weekday, (n) => n + 1, ifAbsent: () => 1);
        final key = task.category.trim().toLowerCase();
        if (key.isEmpty) continue;
        names.putIfAbsent(key, () => task.category.trim());
        byCategory.update(key, (n) => n + 1, ifAbsent: () => 1);
      }
    }

    String? busiest;
    if (byWeekday.isNotEmpty) {
      final top = byWeekday.entries.reduce((a, b) => b.value > a.value ? b : a).key;
      // 2024-01-01 was a Monday, so day N of that week has weekday N.
      busiest = DateFormat('EEEE').format(DateTime(2024, 1, top));
    }

    final categories = byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return _Summary(
      busiestWeekday: busiest,
      topCategories: [
        for (final e in categories.take(3)) MapEntry(names[e.key]!, e.value),
      ],
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.path, required this.initial});

  final String path;
  final String initial;

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    final hasImage = path.isNotEmpty && File(path).existsSync();
    return Container(
      width: 88,
      height: 88,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: c.ink, width: Strokes.panel),
        borderRadius: Radii.controlAll,
        image: hasImage ? DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover) : null,
      ),
      child: hasImage
          ? null
          : Semantics(
              label: 'No profile photo',
              child: Text(
                initial.isEmpty ? '?' : initial[0].toUpperCase(),
                style: context.type.displaySmall,
              ),
            ),
    );
  }
}

class _StatPanel extends StatelessWidget {
  const _StatPanel({required this.label, required this.child, this.stamped = false});

  final String label;
  final Widget child;
  final bool stamped;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Kicker(label, stamped: stamped),
          const SizedBox(height: Space.s),
          child,
        ],
      ),
    );
  }
}

class _PanelLabel extends StatelessWidget {
  const _PanelLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.gutter, Space.gutter, Space.gutter, Space.xs),
      child: Kicker(text),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.gutter, vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: context.type.bodyMedium)),
          Text(
            value,
            style: context.type.titleSmall?.copyWith(fontFeatures: TypeScale.tabular),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.done});

  final String category;
  final int done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.gutter, vertical: 10),
      child: Row(
        children: [
          ToneSwatch(category: category),
          const SizedBox(width: Space.s),
          Expanded(child: Text(category, style: context.type.bodyMedium)),
          Text(
            '$done done',
            style: context.type.titleSmall?.copyWith(fontFeatures: TypeScale.tabular),
          ),
        ],
      ),
    );
  }
}

String _capitalise(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}';
