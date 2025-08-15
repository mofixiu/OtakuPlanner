// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num?)?.toInt(),
  username: json['username'] as String?,
  email: json['email'] as String?,
  password: json['password'] as String?,
  fullname: json['fullname'] as String?,
  isAdmin: json['is_admin'] as bool?,
  isVerified: json['is_verified'] as bool?,
  verificationToken: json['verification_token'] as String?,
  resetPasswordExpires: json['reset_password_expires'] as String?,
  profileImage: json['profile_image'] as String?,
  phone: json['phone'] as String?,
  age: (json['age'] as num?)?.toInt(),
  gender: json['gender'] as String?,
  preferredMode: json['preferredMode'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'password': instance.password,
  'fullname': instance.fullname,
  'is_admin': instance.isAdmin,
  'is_verified': instance.isVerified,
  'verification_token': instance.verificationToken,
  'reset_password_expires': instance.resetPasswordExpires,
  'profile_image': instance.profileImage,
  'phone': instance.phone,
  'age': instance.age,
  'gender': instance.gender,
  'preferredMode': instance.preferredMode,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
