class NearbyRunner {
  final String userId;
  final String displayName;
  final String? bio;
  final String? avatarUrl;
  final double? paceMinPerKm;
  final double? preferredDistanceKm;
  final double distanceKm;

  /// Snapped to a coarse grid by the backend — not this runner's exact GPS fix.
  final double approxLatitude;
  final double approxLongitude;

  NearbyRunner({
    required this.userId,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    this.paceMinPerKm,
    this.preferredDistanceKm,
    required this.distanceKm,
    required this.approxLatitude,
    required this.approxLongitude,
  });

  factory NearbyRunner.fromJson(Map<String, dynamic> json) => NearbyRunner(
        userId: json['userId'] as String,
        displayName: json['displayName'] as String,
        bio: json['bio'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        paceMinPerKm: (json['paceMinPerKm'] as num?)?.toDouble(),
        preferredDistanceKm: (json['preferredDistanceKm'] as num?)?.toDouble(),
        distanceKm: (json['distanceKm'] as num).toDouble(),
        approxLatitude: (json['approxLatitude'] as num).toDouble(),
        approxLongitude: (json['approxLongitude'] as num).toDouble(),
      );
}
