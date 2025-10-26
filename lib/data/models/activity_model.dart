// lib/data/models/activity_model.dart

enum ActivityType {
  tabCreated,
  tabConfirmed,
  repaymentRequested,
  repaymentConfirmed,
  friendAdded,
  tabDeleted,
}

class ActivityModel {
  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  ActivityModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    this.metadata,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'],
      type: _parseActivityType(json['type']),
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      metadata: json['metadata'],
    );
  }

  static ActivityType _parseActivityType(String type) {
    switch (type) {
      case 'tab_created':
        return ActivityType.tabCreated;
      case 'tab_confirmed':
        return ActivityType.tabConfirmed;
      case 'repayment_requested':
        return ActivityType.repaymentRequested;
      case 'repayment_confirmed':
        return ActivityType.repaymentConfirmed;
      case 'friend_added':
        return ActivityType.friendAdded;
      case 'tab_deleted':
        return ActivityType.tabDeleted;
      default:
        return ActivityType.tabCreated;
    }
  }

  String getTimeAgo() {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 0) return 'Il y a ${diff.inDays}j';
    if (diff.inHours > 0) return 'Il y a ${diff.inHours}h';
    if (diff.inMinutes > 0) return 'Il y a ${diff.inMinutes}min';
    return 'À l\'instant';
  }
}