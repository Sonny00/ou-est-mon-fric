// lib/data/models/tab_model.dart

enum TabStatus {
  pending,
  confirmed,
  repaymentRequested,
  settled,
  disputed,
}

class TabModel {
  final String id;
  final String creditorId;
  final String creditorName;
  final String debtorId;
  final String debtorName;
  final double amount;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TabStatus status;
  final String? proofImageUrl;
  final DateTime? repaymentRequestedAt;
  final DateTime? settledAt;
  final String? disputeReason;
  final DateTime? repaymentDeadline; // ← AJOUTÉ
  final bool deadlineNotificationSent; // ← AJOUTÉ

  TabModel({
    required this.id,
    required this.creditorId,
    required this.creditorName,
    required this.debtorId,
    required this.debtorName,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.proofImageUrl,
    this.repaymentRequestedAt,
    this.settledAt,
    this.disputeReason,
    this.repaymentDeadline, // ← AJOUTÉ
    this.deadlineNotificationSent = false, // ← AJOUTÉ
  });

  bool iOwe(String currentUserId) {
    return debtorId == currentUserId;
  }

  bool canConfirmRepayment(String currentUserId) {
    return creditorId == currentUserId && status == TabStatus.repaymentRequested;
  }

  bool canRequestRepayment(String currentUserId) {
    return debtorId == currentUserId && status == TabStatus.confirmed;
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
  // =========================================

  factory TabModel.fromJson(Map<String, dynamic> json) {
  return TabModel(
    id: json['id'],
    creditorId: json['creditorId'],
    creditorName: json['creditorName'],
    debtorId: json['debtorId'],
    debtorName: json['debtorName'],
    amount: _parseAmount(json['amount']),
    description: json['description'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    status: _parseStatus(json['status']), // ⭐ UTILISER LA NOUVELLE MÉTHODE
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
  if (status == null) return TabStatus.pending;
  
  final statusStr = status.toString().toLowerCase().replaceAll('_', '');
  
  switch (statusStr) {
    case 'pending':
      return TabStatus.pending;
    case 'confirmed':
      return TabStatus.confirmed;
    case 'repaymentrequested':
      return TabStatus.repaymentRequested;
    case 'settled':
      return TabStatus.settled;
    case 'disputed':
      return TabStatus.disputed;
    default:
      print('⚠️ Unknown status: $status, defaulting to pending');
      return TabStatus.pending;
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
      'creditorId': creditorId,
      'creditorName': creditorName,
      'debtorId': debtorId,
      'debtorName': debtorName,
      'amount': amount,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'proofImageUrl': proofImageUrl,
      'repaymentRequestedAt': repaymentRequestedAt?.toIso8601String(),
      'settledAt': settledAt?.toIso8601String(),
      'disputeReason': disputeReason,
      'repaymentDeadline': repaymentDeadline?.toIso8601String(),
      'deadlineNotificationSent': deadlineNotificationSent,
      // ========================================
    };
  }

  TabModel copyWith({
    TabStatus? status,
    String? proofImageUrl,
    DateTime? repaymentRequestedAt,
    DateTime? settledAt,
    String? disputeReason,
    double? amount, // ← AJOUTÉ
    String? description, // ← AJOUTÉ
    DateTime? repaymentDeadline, // ← AJOUTÉ
    bool clearDeadline = false, // ← AJOUTÉ pour pouvoir supprimer la deadline
    bool? deadlineNotificationSent, // ← AJOUTÉ
  }) {
    return TabModel(
      id: id,
      creditorId: creditorId,
      creditorName: creditorName,
      debtorId: debtorId,
      debtorName: debtorName,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      status: status ?? this.status,
      proofImageUrl: proofImageUrl ?? this.proofImageUrl,
      repaymentRequestedAt: repaymentRequestedAt ?? this.repaymentRequestedAt,
      settledAt: settledAt ?? this.settledAt,
      disputeReason: disputeReason ?? this.disputeReason,
      repaymentDeadline: clearDeadline ? null : (repaymentDeadline ?? this.repaymentDeadline),
      deadlineNotificationSent: deadlineNotificationSent ?? this.deadlineNotificationSent,
    );
  }
}