// filepath: c:\works\otaku\otakuplanner\lib\models\task.dart
import 'dart:math';

import 'package:flutter/material.dart';

class Task {
  String title;
  String category;
  String time;
  Color color; // Make color non-nullable
  IconData? icon;
  bool isChecked;

  Task({
    required this.title,
    required this.category,
    required this.time,
    required this.color, // Require color in the constructor
    this.icon,
    this.isChecked = false,
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