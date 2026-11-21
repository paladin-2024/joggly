class RunEvent {
  final String id;
  final String hostId;
  final String hostDisplayName;
  final String title;
  final String? description;
  final DateTime startTime;
  final double startLatitude;
  final double startLongitude;
  final String? startAddress;
  final double? distanceKm;
  final double? paceMinPerKm;
  final int maxParticipants;
  final int joinedCount;
  final String status;
  final bool currentUserJoined;

  RunEvent({
    required this.id,
    required this.hostId,
    required this.hostDisplayName,
    required this.title,
    this.description,
    required this.startTime,
    required this.startLatitude,
    required this.startLongitude,
    this.startAddress,
    this.distanceKm,
    this.paceMinPerKm,
    required this.maxParticipants,
    required this.joinedCount,
    required this.status,
    required this.currentUserJoined,
  });

  factory RunEvent.fromJson(Map<String, dynamic> json) => RunEvent(
        id: json['id'] as String,
        hostId: json['hostId'] as String,
        hostDisplayName: json['hostDisplayName'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        startTime: DateTime.parse(json['startTime'] as String),
        startLatitude: (json['startLatitude'] as num).toDouble(),
        startLongitude: (json['startLongitude'] as num).toDouble(),
        startAddress: json['startAddress'] as String?,
        distanceKm: (json['distanceKm'] as num?)?.toDouble(),
        paceMinPerKm: (json['paceMinPerKm'] as num?)?.toDouble(),
        maxParticipants: json['maxParticipants'] as int,
        joinedCount: (json['joinedCount'] as num).toInt(),
        status: json['status'] as String,
        currentUserJoined: json['currentUserJoined'] as bool,
      );
}

class NearbyRunEvent {
  final String id;
  final String hostDisplayName;
  final String title;
  final DateTime startTime;
  final double startLatitude;
  final double startLongitude;
  final String? startAddress;
  final double? paceMinPerKm;
  final int maxParticipants;
  final int joinedCount;
  final double distanceFromSearchKm;

  NearbyRunEvent({
    required this.id,
    required this.hostDisplayName,
    required this.title,
    required this.startTime,
    required this.startLatitude,
    required this.startLongitude,
    this.startAddress,
    this.paceMinPerKm,
    required this.maxParticipants,
    required this.joinedCount,
    required this.distanceFromSearchKm,
  });

  factory NearbyRunEvent.fromJson(Map<String, dynamic> json) => NearbyRunEvent(
        id: json['id'] as String,
        hostDisplayName: json['hostDisplayName'] as String,
        title: json['title'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        startLatitude: (json['startLatitude'] as num).toDouble(),
        startLongitude: (json['startLongitude'] as num).toDouble(),
        startAddress: json['startAddress'] as String?,
        paceMinPerKm: (json['paceMinPerKm'] as num?)?.toDouble(),
        maxParticipants: json['maxParticipants'] as int,
        joinedCount: (json['joinedCount'] as num).toInt(),
        distanceFromSearchKm: (json['distanceFromSearchKm'] as num).toDouble(),
      );
}
