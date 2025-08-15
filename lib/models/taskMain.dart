// filepath: c:\works\otaku\otakuplanner\lib\models\task.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'taskMain.g.dart';

@JsonSerializable()
class TaskMain {
  final int? id;
  @JsonKey(name: 'user_id')
  final int? userId;
  final String title;
  final String date;
  final String category;
  final String time;
  @JsonKey(
    name: 'completed',
    fromJson: _completedFromJson,
    toJson: _completedToJson,
  )
  final bool completed;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  // Static helper methods for JSON conversion
  static bool _completedFromJson(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  static dynamic _completedToJson(bool value) => value;

  static final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
  ];

  Color get color {
    final index = (category + title).hashCode % _colors.length;
    return _colors[index.abs()];
  }

  IconData get icon {
    switch (category.toLowerCase()) {
      case 'work':
        return Icons.work;
      case 'personal':
        return Icons.person;
      case 'shopping':
        return Icons.shopping_cart;
      case 'health':
        return Icons.health_and_safety;
      case 'study':
        return Icons.school;
      default:
        return Icons.task;
    }
  }

  static Color getRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  // Convenience getter to maintain compatibility with existing code
  bool get isChecked => completed;

  TaskMain({
    this.id,
    this.userId,
    required this.title,
    required this.category,
    required this.time,
    required this.date,
    this.completed = false,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskMain.fromJson(Map<String, dynamic> json) =>
      _$TaskMainFromJson(json);
  Map<String, dynamic> toJson() => _$TaskMainToJson(this);
}
