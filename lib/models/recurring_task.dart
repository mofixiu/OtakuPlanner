
import 'package:json_annotation/json_annotation.dart';

part 'recurring_task.g.dart';

@JsonSerializable()
class Reccuring_Task {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
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
  final String? frequency;
   @JsonKey(name: 'completed_instances')
  final String? completedInstances;
   @JsonKey(name: 'excluded_dates')
  final String? excludedDates;
   @JsonKey(name: 'reccurence_end')
  final String? recurrenceEnd;
   @JsonKey(name: 'custom_pattern')
  final String? customPattern;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  static bool _completedFromJson(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  static dynamic _completedToJson(bool value) => value;

  // Convenience getter to maintain compatibility with existing code
  bool get isChecked => completed;

  Reccuring_Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.time,
    required this.date,
    this.completed = false,
    this.createdAt,
    this.updatedAt,
    this.frequency,
    this.completedInstances,
    this.excludedDates,
    this.recurrenceEnd,
    this.customPattern,

  });

  factory Reccuring_Task.fromJson(Map<String, dynamic> json) =>
      _$Reccuring_TaskFromJson(json);
  Map<String, dynamic> toJson() => _$Reccuring_TaskToJson(this);
}
