class LeaderboardEntry {
  final int rank;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final double totalDistanceKm;
  final int totalActivities;
  final bool isMe;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.totalDistanceKm,
    required this.totalActivities,
    required this.isMe,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
        rank: json['rank'] as int,
        userId: json['userId'] as String,
        displayName: json['displayName'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        totalDistanceKm: (json['totalDistanceKm'] as num).toDouble(),
        totalActivities: (json['totalActivities'] as num).toInt(),
        isMe: json['isMe'] as bool,
      );
}
