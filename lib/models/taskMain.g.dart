// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taskMain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskMain _$TaskMainFromJson(Map<String, dynamic> json) => TaskMain(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['user_id'] as num?)?.toInt(),
  title: json['title'] as String,
  category: json['category'] as String,
  time: json['time'] as String,
  date: json['date'] as String,
  completed:
      json['completed'] == null
          ? false
          : TaskMain._completedFromJson(json['completed']),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$TaskMainToJson(TaskMain instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'title': instance.title,
  'date': instance.date,
  'category': instance.category,
  'time': instance.time,
  'completed': TaskMain._completedToJson(instance.completed),
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
