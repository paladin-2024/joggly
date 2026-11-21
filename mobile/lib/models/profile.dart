class Profile {
  final String userId;
  final String displayName;
  final String? bio;
  final String? avatarUrl;
  final double? paceMinPerKm;
  final double? preferredDistanceKm;
  final double? latitude;
  final double? longitude;
  final bool discoverable;

  Profile({
    required this.userId,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    this.paceMinPerKm,
    this.preferredDistanceKm,
    this.latitude,
    this.longitude,
    required this.discoverable,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        userId: json['userId'] as String,
        displayName: json['displayName'] as String,
        bio: json['bio'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        paceMinPerKm: (json['paceMinPerKm'] as num?)?.toDouble(),
        preferredDistanceKm: (json['preferredDistanceKm'] as num?)?.toDouble(),
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        discoverable: json['discoverable'] as bool,
      );
}
