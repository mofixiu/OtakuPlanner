// filepath: c:\works\otaku\otakuplanner\lib\models\task.dart
import 'dart:math';

import 'package:flutter/material.dart';

class Task {
  final String title;
  final String category;
  final String time;
  final Color color;
  final IconData? icon;
  bool isChecked;
  final bool isRecurring;

  Task({
    required this.title,
    required this.category,
    required this.time,
    required this.color,
    this.icon,
    this.isChecked = false,
    this.isRecurring = false,
  });

  static Color getRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }
}