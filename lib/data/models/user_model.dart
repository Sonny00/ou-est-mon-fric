class UserModel {
  final String id;
  final String phoneNumber;
  final String? name;
  final String? avatarUrl;
  final DateTime createdAt;
  
  UserModel({
    required this.id,
    required this.phoneNumber,
    this.name,
    this.avatarUrl,
    required this.createdAt,
  });

  String get displayName => name ?? phoneNumber;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phoneNumber: json['phoneNumber'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
