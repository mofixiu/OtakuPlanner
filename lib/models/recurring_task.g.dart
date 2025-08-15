// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reccuring_Task _$Reccuring_TaskFromJson(Map<String, dynamic> json) =>
    Reccuring_Task(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      title: json['title'] as String,
      category: json['category'] as String,
      time: json['time'] as String,
      date: json['date'] as String,
      completed:
          json['completed'] == null
              ? false
              : Reccuring_Task._completedFromJson(json['completed']),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      frequency: json['frequency'] as String?,
      completedInstances: json['completed_instances'] as String?,
      excludedDates: json['excluded_dates'] as String?,
      recurrenceEnd: json['reccurence_end'] as String?,
      customPattern: json['custom_pattern'] as String?,
    );

Map<String, dynamic> _$Reccuring_TaskToJson(Reccuring_Task instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'date': instance.date,
      'category': instance.category,
      'time': instance.time,
      'completed': Reccuring_Task._completedToJson(instance.completed),
      'frequency': instance.frequency,
      'completed_instances': instance.completedInstances,
      'excluded_dates': instance.excludedDates,
      'reccurence_end': instance.recurrenceEnd,
      'custom_pattern': instance.customPattern,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
