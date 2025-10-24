// lib/data/models/tab_model.dart

enum TabStatus {
  pending,           // En attente de confirmation initiale
  confirmed,         // Confirmé par les deux parties
  repaymentRequested, // Le débiteur dit qu'il a remboursé
  settled,           // Le créditeur confirme le remboursement
  disputed,          // Contesté
}

class TabModel {
  final String id;
  final String creditorId;      // Qui prête
  final String creditorName;    
  final String debtorId;        // Qui emprunte
  final String debtorName;
  final double amount;
  final String description;
  final DateTime createdAt;
  final TabStatus status;
  final String? proofImageUrl;
  final DateTime? repaymentRequestedAt;
  final DateTime? settledAt;
  final String? disputeReason;
  
  TabModel({
    required this.id,
    required this.creditorId,
    required this.creditorName,
    required this.debtorId,
    required this.debtorName,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.status,
    this.proofImageUrl,
    this.repaymentRequestedAt,
    this.settledAt,
    this.disputeReason,
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

  factory TabModel.fromJson(Map<String, dynamic> json) {
    return TabModel(
      id: json['id'],
      creditorId: json['creditorId'],
      creditorName: json['creditorName'],
      debtorId: json['debtorId'],
      debtorName: json['debtorName'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      status: TabStatus.values.firstWhere(
        (e) => e.toString() == 'TabStatus.${json['status']}',
      ),
      proofImageUrl: json['proofImageUrl'],
      repaymentRequestedAt: json['repaymentRequestedAt'] != null 
          ? DateTime.parse(json['repaymentRequestedAt']) 
          : null,
      settledAt: json['settledAt'] != null 
          ? DateTime.parse(json['settledAt']) 
          : null,
      disputeReason: json['disputeReason'],
    );
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
      'status': status.toString().split('.').last,
      'proofImageUrl': proofImageUrl,
      'repaymentRequestedAt': repaymentRequestedAt?.toIso8601String(),
      'settledAt': settledAt?.toIso8601String(),
      'disputeReason': disputeReason,
    };
  }
  
  TabModel copyWith({
    TabStatus? status,
    String? proofImageUrl,
    DateTime? repaymentRequestedAt,
    DateTime? settledAt,
  }) {
    return TabModel(
      id: id,
      creditorId: creditorId,
      creditorName: creditorName,
      debtorId: debtorId,
      debtorName: debtorName,
      amount: amount,
      description: description,
      createdAt: createdAt,
      status: status ?? this.status,
      proofImageUrl: proofImageUrl ?? this.proofImageUrl,
      repaymentRequestedAt: repaymentRequestedAt ?? this.repaymentRequestedAt,
      settledAt: settledAt ?? this.settledAt,
      disputeReason: disputeReason,
    );
  }
}