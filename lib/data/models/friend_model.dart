// lib/data/models/friend_model.dart

enum FriendStatus {
  pending,
  accepted,
  blocked,
}

class Friend {
  final String id;
  final String userId;
  final String? friendUserId;
  final String name;
  final String? phoneNumber;
  final String? email;
  final String? avatarUrl;
  final FriendStatus status;
  final bool isVerified;
  final DateTime addedAt;
  final DateTime updatedAt;
  
  // ⭐ Infos du friendUser (pour invitations ENVOYÉES)
  final String? friendUserName;
  final String? friendUserEmail;
  final String? friendUserAvatar;
  final String? friendUserTag;
  
  // ⭐ NOUVEAU : Infos du user (pour invitations REÇUES)
  final String? senderUserName;
  final String? senderUserEmail;
  final String? senderUserAvatar;
  final String? senderUserTag;
  
  Friend({
    required this.id,
    required this.userId,
    this.friendUserId,
    required this.name,
    this.phoneNumber,
    this.email,
    this.avatarUrl,
    required this.status,
    required this.isVerified,
    required this.addedAt,
    required this.updatedAt,
    this.friendUserName,
    this.friendUserEmail,
    this.friendUserAvatar,
    this.friendUserTag,
    this.senderUserName,
    this.senderUserEmail,
    this.senderUserAvatar,
    this.senderUserTag,
  });
  
  // ⭐ CORRIGER : displayName pour gérer les 2 cas
  String get displayName {
    // Pour les invitations REÇUES (où je suis friendUserId)
    // L'envoyeur est dans 'user'
    if (isVerified && senderUserName != null && senderUserName!.isNotEmpty) {
      return senderUserName!;
    }
    // Pour les invitations ENVOYÉES (où je suis userId)
    // Le destinataire est dans 'friendUser'
    if (isVerified && friendUserName != null && friendUserName!.isNotEmpty) {
      return friendUserName!;
    }
    // Fallback : nom stocké localement
    return name;
  }
  
  String? get displayEmail {
    if (isVerified && senderUserEmail != null && senderUserEmail!.isNotEmpty) {
      return senderUserEmail;
    }
    if (isVerified && friendUserEmail != null && friendUserEmail!.isNotEmpty) {
      return friendUserEmail;
    }
    return email;
  }
  
  String? get displayTag {
    if (isVerified && senderUserTag != null) {
      return senderUserTag;
    }
    if (isVerified && friendUserTag != null) {
      return friendUserTag;
    }
    return null;
  }
  
  String get initials {
    try {
      final displayedName = displayName;
      if (displayedName.isEmpty) return '??';
      
      final parts = displayedName.split(' ');
      if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      if (displayedName.length >= 2) {
        return displayedName.substring(0, 2).toUpperCase();
      }
      return displayedName[0].toUpperCase();
    } catch (e) {
      return '??';
    }
  }
  
  factory Friend.fromJson(Map<String, dynamic> json) {
    // ⭐ Parse friendUser (pour invitations ENVOYÉES)
    String? friendUserName;
    String? friendUserEmail;
    String? friendUserAvatar;
    String? friendUserTag;
    
    final friendUserData = json['friendUser'];
    if (friendUserData != null && friendUserData is Map<String, dynamic>) {
      friendUserName = friendUserData['name']?.toString();
      friendUserEmail = friendUserData['email']?.toString();
      friendUserAvatar = friendUserData['avatarUrl']?.toString();
      friendUserTag = friendUserData['tag']?.toString();
    }
    
    // ⭐ NOUVEAU : Parse user (pour invitations REÇUES)
    String? senderUserName;
    String? senderUserEmail;
    String? senderUserAvatar;
    String? senderUserTag;
    
    final userData = json['user'];
    if (userData != null && userData is Map<String, dynamic>) {
      senderUserName = userData['name']?.toString();
      senderUserEmail = userData['email']?.toString();
      senderUserAvatar = userData['avatarUrl']?.toString();
      senderUserTag = userData['tag']?.toString();
    }
    
    return Friend(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      friendUserId: json['friendUserId']?.toString(),
      name: json['name']?.toString() ?? 'Inconnu',
      phoneNumber: json['phoneNumber']?.toString(),
      email: json['email']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      status: _parseStatus(json['status']),
      isVerified: json['isVerified'] == true,
      addedAt: _parseDate(json['addedAt']),
      updatedAt: _parseDate(json['updatedAt']),
      friendUserName: friendUserName,
      friendUserEmail: friendUserEmail,
      friendUserAvatar: friendUserAvatar,
      friendUserTag: friendUserTag,
      senderUserName: senderUserName,
      senderUserEmail: senderUserEmail,
      senderUserAvatar: senderUserAvatar,
      senderUserTag: senderUserTag,
    );
  }
  
  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is DateTime) return date;
    try {
      return DateTime.parse(date.toString());
    } catch (e) {
      return DateTime.now();
    }
  }
  
  static FriendStatus _parseStatus(dynamic status) {
    if (status == null) return FriendStatus.accepted;
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'pending':
        return FriendStatus.pending;
      case 'accepted':
        return FriendStatus.accepted;
      case 'blocked':
        return FriendStatus.blocked;
      default:
        return FriendStatus.accepted;
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'friendUserId': friendUserId,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'avatarUrl': avatarUrl,
      'status': status.name,
      'isVerified': isVerified,
      'addedAt': addedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}