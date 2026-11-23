class FeedItem {
  final String activityId;
  final String ownerId;
  final String ownerDisplayName;
  final String? ownerAvatarUrl;
  final DateTime startTime;
  final int durationSeconds;
  final double distanceKm;
  final double averagePaceMinPerKm;
  final int? stepCount;
  final int kudosCount;
  final bool kudosGivenByMe;
  final int commentCount;

  FeedItem({
    required this.activityId,
    required this.ownerId,
    required this.ownerDisplayName,
    this.ownerAvatarUrl,
    required this.startTime,
    required this.durationSeconds,
    required this.distanceKm,
    required this.averagePaceMinPerKm,
    this.stepCount,
    required this.kudosCount,
    required this.kudosGivenByMe,
    required this.commentCount,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) => FeedItem(
        activityId: json['activityId'] as String,
        ownerId: json['ownerId'] as String,
        ownerDisplayName: json['ownerDisplayName'] as String,
        ownerAvatarUrl: json['ownerAvatarUrl'] as String?,
        startTime: DateTime.parse(json['startTime'] as String),
        durationSeconds: json['durationSeconds'] as int,
        distanceKm: (json['distanceKm'] as num).toDouble(),
        averagePaceMinPerKm: (json['averagePaceMinPerKm'] as num).toDouble(),
        stepCount: json['stepCount'] as int?,
        kudosCount: (json['kudosCount'] as num).toInt(),
        kudosGivenByMe: json['kudosGivenByMe'] as bool,
        commentCount: (json['commentCount'] as num).toInt(),
      );
}
