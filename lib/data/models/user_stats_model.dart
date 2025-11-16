// lib/data/models/user_stats_model.dart

class UserStatsModel {
  final int activeTabs;
  final int totalFriends;
  final double totalOwed;
  final double totalDue;
  final double balance;

  UserStatsModel({
    required this.activeTabs,
    required this.totalFriends,
    required this.totalOwed,
    required this.totalDue,
    required this.balance,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      activeTabs: json['activeTabs'] ?? 0,
      totalFriends: json['totalFriends'] ?? 0,
      totalOwed: _parseDouble(json['totalOwed']),
      totalDue: _parseDouble(json['totalDue']),
      balance: _parseDouble(json['balance']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
