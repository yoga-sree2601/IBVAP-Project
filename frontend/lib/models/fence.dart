class FenceZone {
  final String id;
  String name;
  String status; // 'teal' (normal) | 'amber' (elevated)

  FenceZone({required this.id, required this.name, required this.status});

  factory FenceZone.fromJson(Map<String, dynamic> json) {
    return FenceZone(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      status: json['status'] ?? 'teal',
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'status': status};
}

class FenceSettings {
  int sensitivity;
  bool humanDetection;
  bool animalFilter;
  bool directionalAlert;
  bool armed;

  FenceSettings({
    required this.sensitivity,
    required this.humanDetection,
    required this.animalFilter,
    required this.directionalAlert,
    required this.armed,
  });

  factory FenceSettings.fromJson(Map<String, dynamic> json) {
    return FenceSettings(
      sensitivity: json['sensitivity'] ?? 3,
      humanDetection: json['human_detection'] ?? true,
      animalFilter: json['animal_filter'] ?? true,
      directionalAlert: json['directional_alert'] ?? false,
      armed: json['armed'] ?? false,
    );
  }
}
