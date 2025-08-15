// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String,
  userId: (json['userId'] as num?)?.toInt(),
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'userId': instance.userId,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
