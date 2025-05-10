class FriendRequest {
  final String id;
  final String receiverId;
  final String senderId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FriendRequest({
    required this.id,
    required this.receiverId,
    required this.senderId,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory FriendRequest.fromMap(String id, Map<String, dynamic> map) {
    return FriendRequest(
      id: id,
      receiverId: map['receiverId'] ?? "",
      senderId: map['senderId'] ?? "",
      status: map['status'] ?? "",
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap({
    bool isUpdate = false,
    String updateStatus = "",
  }) {
    return {
      'id': id,
      'receiverId': receiverId,
      'senderId': senderId,
      'status': updateStatus == "" ? status : updateStatus,
      'createdAt': createdAt,
      if (isUpdate) 'updatedAt': DateTime.now(),
    };
  }

  FriendRequest copyWith({String? status}) {
    return FriendRequest(
      id: id,
      receiverId: receiverId,
      senderId: senderId,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
