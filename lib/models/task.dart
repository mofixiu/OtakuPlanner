// filepath: c:\works\otaku\otakuplanner\lib\models\task.dart
import 'dart:math';
import 'package:flutter/material.dart';

class Task {
  final int? id;
  final int? userId;
  final String title;
  final String date;
  final String category;
  final String time;
  final Color color;
  final IconData? icon;
  bool isChecked;
  final bool isRecurring;
  final String? createdAt;
  final String? updatedAt;

  Task({
    this.id,
    this.userId,
    required this.title,
    required this.category,
    required this.time,
    required this.date,
    required this.color,
    this.icon,
    this.isChecked = false,
    this.isRecurring = false,
    this.createdAt,
    this.updatedAt,
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