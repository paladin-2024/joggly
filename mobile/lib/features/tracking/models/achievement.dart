class Achievement {
  final String code;
  final String title;
  final String description;
  final bool unlocked;

  Achievement({required this.code, required this.title, required this.description, required this.unlocked});

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        code: json['code'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        unlocked: json['unlocked'] as bool,
      );
}
