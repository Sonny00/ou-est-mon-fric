// lib/data/models/tab_sync_request_model.dart

class TabSyncRequest {
  final String id;
  final String type; // 'create', 'update', 'delete', 'repayment'
  final String initiatedBy;
  final String initiatedByName;
  final String targetUserId;
  final String initiatorTabId;
  final String? targetTabId;
  final TabData? tabData;
  final String? message;
  final String status; // 'pending', 'accepted', 'rejected'
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? respondedAt;

  TabSyncRequest({
    required this.id,
    required this.type,
    required this.initiatedBy,
    required this.initiatedByName,
    required this.targetUserId,
    required this.initiatorTabId,
    this.targetTabId,
    this.tabData,
    this.message,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    this.respondedAt,
  });

  factory TabSyncRequest.fromJson(Map<String, dynamic> json) {
    return TabSyncRequest(
      id: json['id'],
      type: json['type'],
      initiatedBy: json['initiatedBy'],
      initiatedByName: json['initiatedByName'],
      targetUserId: json['targetUserId'],
      initiatorTabId: json['initiatorTabId'],
      targetTabId: json['targetTabId'],
      tabData: json['tabData'] != null ? TabData.fromJson(json['tabData']) : null,
      message: json['message'],
      status: json['status'],
      rejectionReason: json['rejectionReason'],
      createdAt: DateTime.parse(json['createdAt']),
      respondedAt: json['respondedAt'] != null 
        ? DateTime.parse(json['respondedAt']) 
        : null,
    );
  }
}

class TabData {
  final String description;
  final double amount;
  final String creditorId;
  final String creditorName;
  final String debtorId;
  final String debtorName;

  TabData({
    required this.description,
    required this.amount,
    required this.creditorId,
    required this.creditorName,
    required this.debtorId,
    required this.debtorName,
  });

  factory TabData.fromJson(Map<String, dynamic> json) {
    return TabData(
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      creditorId: json['creditorId'],
      creditorName: json['creditorName'],
      debtorId: json['debtorId'],
      debtorName: json['debtorName'],
    );
  }
}