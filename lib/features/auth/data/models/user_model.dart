import 'package:flutter_application_4/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.createdAt,
  });

  // From JSON (API response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // To JSON (for local storage or API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Convert Model to Entity
  User toEntity() {
    return User(
      id: id,
      username: username,
      email: email,
      createdAt: createdAt,
    );
  }

  // Create from Entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      createdAt: user.createdAt,
    );
  }
}
