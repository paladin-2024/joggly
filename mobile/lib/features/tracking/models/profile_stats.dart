class ProfileStats {
  final int totalActivities;
  final double totalDistanceKm;

  ProfileStats({required this.totalActivities, required this.totalDistanceKm});

  factory ProfileStats.fromJson(Map<String, dynamic> json) => ProfileStats(
        totalActivities: (json['totalActivities'] as num).toInt(),
        totalDistanceKm: (json['totalDistanceKm'] as num).toDouble(),
      );
}
