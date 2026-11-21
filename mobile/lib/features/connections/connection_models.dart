class Connection {
  final String id;
  final String requesterId;
  final String requesterDisplayName;
  final String recipientId;
  final String recipientDisplayName;
  final String status;

  Connection({
    required this.id,
    required this.requesterId,
    required this.requesterDisplayName,
    required this.recipientId,
    required this.recipientDisplayName,
    required this.status,
  });

  factory Connection.fromJson(Map<String, dynamic> json) => Connection(
        id: json['id'] as String,
        requesterId: json['requesterId'] as String,
        requesterDisplayName: json['requesterDisplayName'] as String,
        recipientId: json['recipientId'] as String,
        recipientDisplayName: json['recipientDisplayName'] as String,
        status: json['status'] as String,
      );
}
