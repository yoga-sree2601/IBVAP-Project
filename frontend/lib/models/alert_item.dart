enum AlertSeverity { critical, warning, info }

extension AlertSeverityLabel on AlertSeverity {
  String get label {
    switch (this) {
      case AlertSeverity.critical:
        return 'CRITICAL';
      case AlertSeverity.warning:
        return 'WARNING';
      case AlertSeverity.info:
        return 'INFO';
    }
  }

  String get apiValue => name; // critical | warning | info — matches backend
}

AlertSeverity alertSeverityFromApi(String value) {
  switch (value) {
    case 'critical':
      return AlertSeverity.critical;
    case 'info':
      return AlertSeverity.info;
    default:
      return AlertSeverity.warning;
  }
}

class AlertItem {
  final String id;
  String refCode;
  AlertSeverity severity;
  String title;
  String description;
  String timestamp;

  AlertItem({
    required this.id,
    required this.refCode,
    required this.severity,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  factory AlertItem.fromJson(Map<String, dynamic> json) {
    return AlertItem(
      id: json['id'].toString(),
      refCode: json['ref_code'] ?? '',
      severity: alertSeverityFromApi(json['severity'] ?? 'warning'),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'severity': severity.apiValue,
        'title': title,
        'description': description,
      };
}
