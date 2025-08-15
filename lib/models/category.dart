import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';
@JsonSerializable()
class Category {
  final int? id;
  final String name;
  final int? userId;
  @JsonKey(name: 'created_at')
  DateTime createdAt;
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  Category({
    this.id,
    required this.name,
    this.userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }): createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}