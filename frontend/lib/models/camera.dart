enum CameraType { fixed, ptz, thermal, dome }

extension CameraTypeLabel on CameraType {
  String get label {
    switch (this) {
      case CameraType.fixed:
        return 'Fixed IP';
      case CameraType.ptz:
        return 'PTZ';
      case CameraType.thermal:
        return 'Thermal';
      case CameraType.dome:
        return 'Dome';
    }
  }
}

CameraType cameraTypeFromLabel(String label) {
  switch (label) {
    case 'PTZ':
      return CameraType.ptz;
    case 'Thermal':
      return CameraType.thermal;
    case 'Dome':
      return CameraType.dome;
    default:
      return CameraType.fixed;
  }
}

class SurveillanceCamera {
  final String id; // backend id, as string for UI convenience
  String name;
  String sector;
  String ip;
  String rtsp;
  CameraType type;
  bool online;
  String feedImage;
  bool night;

  SurveillanceCamera({
    required this.id,
    required this.name,
    required this.sector,
    required this.ip,
    required this.rtsp,
    required this.type,
    required this.online,
    required this.feedImage,
    this.night = false,
  });

  factory SurveillanceCamera.fromJson(Map<String, dynamic> json) {
    return SurveillanceCamera(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      sector: json['sector'] ?? '',
      ip: json['ip'] ?? '',
      rtsp: json['rtsp'] ?? '',
      type: cameraTypeFromLabel(json['type'] ?? 'Fixed IP'),
      online: (json['status'] ?? 'Online') == 'Online',
      feedImage: json['img'] ?? '',
      night: json['night'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'sector': sector,
        'ip': ip,
        'rtsp': rtsp,
        'type': type.label,
        'status': online ? 'Online' : 'Offline',
        'img': feedImage,
        'night': night,
      };

  SurveillanceCamera copyWith({
    String? name,
    String? sector,
    String? ip,
    String? rtsp,
    CameraType? type,
    bool? online,
    String? feedImage,
    bool? night,
  }) {
    return SurveillanceCamera(
      id: id,
      name: name ?? this.name,
      sector: sector ?? this.sector,
      ip: ip ?? this.ip,
      rtsp: rtsp ?? this.rtsp,
      type: type ?? this.type,
      online: online ?? this.online,
      feedImage: feedImage ?? this.feedImage,
      night: night ?? this.night,
    );
  }
}
