// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['user_id'] as num?)?.toInt(),
  taskId: (json['task_id'] as num?)?.toInt(),
  recurringTaskId: (json['recurring_task_id'] as num?)?.toInt(),
  type: json['type'] as String?,
  title: json['title'] as String?,
  message: json['message'] as String?,
  scheduledTime: json['scheduledTime'] as String?,
  sentAt: json['sentAt'] as String?,
  status: json['status'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'task_id': instance.taskId,
      'recurring_task_id': instance.recurringTaskId,
      'type': instance.type,
      'title': instance.title,
      'message': instance.message,
      'scheduledTime': instance.scheduledTime,
      'sentAt': instance.sentAt,
      'status': instance.status,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
