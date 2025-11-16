// lib/data/models/user_model.dart

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? avatarUrl;
  final bool isEmailVerified;
  final String? tag; // ⭐ NOUVEAU


  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.avatarUrl,
    required this.isEmailVerified,
    this.tag,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      avatarUrl: json['avatarUrl'],
      isEmailVerified: json['isEmailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'isEmailVerified': isEmailVerified,
    };
  }
}