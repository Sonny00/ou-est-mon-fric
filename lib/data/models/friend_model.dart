// lib/data/models/friend_model.dart

class Friend {
  final String id;
  final String name;
  final String? phoneNumber;
  final String? email;
  final String? avatarUrl;
  final DateTime addedAt;
  
  Friend({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.email,
    this.avatarUrl,
    required this.addedAt,
  });
  
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }
  
  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      addedAt: DateTime.parse(json['addedAt']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'avatarUrl': avatarUrl,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}