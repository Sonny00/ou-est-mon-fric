// lib/data/models/tab_model.dart

enum TabStatus {
  active,              // ⭐ CHANGÉ
  repaymentPending,    // ⭐ CHANGÉ
  settled,
}

class TabModel {
  final String id;
  final String userId; // ⭐ NOUVEAU
  final String creditorId;
  final String creditorName;
  final String debtorId;
  final String debtorName;
  final double amount;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TabStatus status;
  final String? linkedTabId; // ⭐ NOUVEAU
  final String? linkedFriendId; // ⭐ NOUVEAU
  final String? proofImageUrl;
  final DateTime? repaymentRequestedAt;
  final DateTime? settledAt;
  final String? disputeReason;
  final DateTime? repaymentDeadline;
  final bool deadlineNotificationSent;

  TabModel({
    required this.id,
    required this.userId,
    required this.creditorId,
    required this.creditorName,
    required this.debtorId,
    required this.debtorName,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.linkedTabId,
    this.linkedFriendId,
    this.proofImageUrl,
    this.repaymentRequestedAt,
    this.settledAt,
    this.disputeReason,
    this.repaymentDeadline,
    this.deadlineNotificationSent = false,
  });

  bool iOwe(String currentUserId) {
    return debtorId == currentUserId;
  }

  bool canConfirmRepayment(String currentUserId) {
    return creditorId == currentUserId && status == TabStatus.repaymentPending;
  }

  bool canRequestRepayment(String currentUserId) {
    return debtorId == currentUserId && status == TabStatus.active;
  }

  bool get hasDeadline => repaymentDeadline != null;

  bool get isOverdue {
    if (repaymentDeadline == null) return false;
    return DateTime.now().isAfter(repaymentDeadline!) && status != TabStatus.settled;
  }

  int get daysUntilDeadline {
    if (repaymentDeadline == null) return 0;
    final difference = repaymentDeadline!.difference(DateTime.now());
    return difference.inDays;
  }

  String get deadlineStatus {
    if (!hasDeadline) return '';
    if (isOverdue) return 'En retard de ${-daysUntilDeadline} jours';
    if (daysUntilDeadline == 0) return 'Aujourd\'hui';
    if (daysUntilDeadline == 1) return 'Demain';
    return 'Dans $daysUntilDeadline jours';
  }

  factory TabModel.fromJson(Map<String, dynamic> json) {
    return TabModel(
      id: json['id'],
      userId: json['userId'],
      creditorId: json['creditorId'],
      creditorName: json['creditorName'],
      debtorId: json['debtorId'],
      debtorName: json['debtorName'],
      amount: _parseAmount(json['amount']),
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      status: _parseStatus(json['status']),
      linkedTabId: json['linkedTabId'],
      linkedFriendId: json['linkedFriendId'],
      proofImageUrl: json['proofImageUrl'],
      repaymentRequestedAt: json['repaymentRequestedAt'] != null
          ? DateTime.parse(json['repaymentRequestedAt'])
          : null,
      settledAt: json['settledAt'] != null
          ? DateTime.parse(json['settledAt'])
          : null,
      disputeReason: json['disputeReason'],
      repaymentDeadline: json['repaymentDeadline'] != null
          ? DateTime.parse(json['repaymentDeadline'])
          : null,
      deadlineNotificationSent: json['deadlineNotificationSent'] ?? false,
    );
  }

  static TabStatus _parseStatus(dynamic status) {
    if (status == null) return TabStatus.active;
    
    final statusStr = status.toString().toLowerCase().replaceAll('_', '');
    
    switch (statusStr) {
      case 'active':
        return TabStatus.active;
      case 'repaymentpending':
        return TabStatus.repaymentPending;
      case 'settled':
        return TabStatus.settled;
      default:
        print('⚠️ Unknown status: $status, defaulting to active');
        return TabStatus.active;
    }
  }

  static double _parseAmount(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.parse(value);
    throw Exception('Invalid amount format: $value');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'creditorId': creditorId,
      'creditorName': creditorName,
      'debtorId': debtorId,
      'debtorName': debtorName,
      'amount': amount,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'linkedTabId': linkedTabId,
      'linkedFriendId': linkedFriendId,
      'proofImageUrl': proofImageUrl,
      'repaymentRequestedAt': repaymentRequestedAt?.toIso8601String(),
      'settledAt': settledAt?.toIso8601String(),
      'disputeReason': disputeReason,
      'repaymentDeadline': repaymentDeadline?.toIso8601String(),
      'deadlineNotificationSent': deadlineNotificationSent,
    };
  }

  TabModel copyWith({
    TabStatus? status,
    String? proofImageUrl,
    DateTime? repaymentRequestedAt,
    DateTime? settledAt,
    String? disputeReason,
    double? amount,
    String? description,
    DateTime? repaymentDeadline,
    bool clearDeadline = false,
    bool? deadlineNotificationSent,
  }) {
    return TabModel(
      id: id,
      userId: userId,
      creditorId: creditorId,
      creditorName: creditorName,
      debtorId: debtorId,
      debtorName: debtorName,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      status: status ?? this.status,
      linkedTabId: linkedTabId,
      linkedFriendId: linkedFriendId,
      proofImageUrl: proofImageUrl ?? this.proofImageUrl,
      repaymentRequestedAt: repaymentRequestedAt ?? this.repaymentRequestedAt,
      settledAt: settledAt ?? this.settledAt,
      disputeReason: disputeReason ?? this.disputeReason,
      repaymentDeadline: clearDeadline ? null : (repaymentDeadline ?? this.repaymentDeadline),
      deadlineNotificationSent: deadlineNotificationSent ?? this.deadlineNotificationSent,
    );
  }
}