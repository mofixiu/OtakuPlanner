// filepath: c:\works\otaku\otakuplanner\lib\models\user.dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int? id;
  final String? username;
  final String? email;
  final String? password;
  final String? fullname;
  @JsonKey(name: 'is_admin')
  final bool? isAdmin;
  @JsonKey(name: 'is_verified')
  final bool? isVerified;
  @JsonKey(name: 'verification_token')
  final String? verificationToken;
  @JsonKey(name: 'reset_password_expires')
  final String? resetPasswordExpires;
  @JsonKey(name: 'profile_image')
  final String? profileImage;
  final String? phone;
  final int? age;
  final String? gender;
  final String? preferredMode;
  final String? createdAt;
  final String? updatedAt;

  User({
    this.id,
    this.username,
    this.email,
    this.password,
    this.fullname,
    this.isAdmin,
    this.isVerified,
    this.verificationToken,
    this.resetPasswordExpires,
    this.profileImage,
    this.phone,
    this.age,
    this.gender,
    this.preferredMode,
    this.createdAt,
    this.updatedAt,
  });

  String get name => fullname ?? username ?? 'User';
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}