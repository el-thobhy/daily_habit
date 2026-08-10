import 'package:daily_habit/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['sub']?.toString() ?? json['id']?.toString() ?? json['userId']?.toString() ?? '',
      name: json['name'] ?? json['fullname'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  UserEntity toEntity() => UserEntity(id: id, name: name, email: email);
}
