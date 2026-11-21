class Split {
  final int splitNumber;
  final double distanceKm;
  final int durationSeconds;
  final double paceMinPerKm;

  Split({
    required this.splitNumber,
    required this.distanceKm,
    required this.durationSeconds,
    required this.paceMinPerKm,
  });

  factory Split.fromJson(Map<String, dynamic> json) => Split(
        splitNumber: json['splitNumber'] as int,
        distanceKm: (json['distanceKm'] as num).toDouble(),
        durationSeconds: json['durationSeconds'] as int,
        paceMinPerKm: (json['paceMinPerKm'] as num).toDouble(),
      );
}
