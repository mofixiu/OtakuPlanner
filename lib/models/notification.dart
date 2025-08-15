import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class Notification {
  final int? id;
  @JsonKey(name: 'user_id')
  final int? userId;
  @JsonKey(name: 'task_id')
  final int? taskId;
  @JsonKey(name: 'recurring_task_id')
  final int? recurringTaskId;
  final String? type;
  final String? title;
  final String? message;
  final String? scheduledTime;
  final String? sentAt;
  final String? status;
  final Map<String, dynamic>? metadata;
  final String? createdAt;
  final String? updatedAt;

  Notification({
    this.id,
    this.userId,
    this.taskId,
    this.recurringTaskId,
    this.type,
    this.title,
    this.message,
    this.scheduledTime,
    this.sentAt,
    this.status,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => _$NotificationFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationToJson(this);
}