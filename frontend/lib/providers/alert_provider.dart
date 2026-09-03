import 'package:flutter/material.dart';
import '../models/alert_item.dart';
import '../services/api_service.dart';

class AlertProvider extends ChangeNotifier {
  final ApiService api;
  AlertProvider({required this.api});

  List<AlertItem> _alerts = [];
  bool loading = false;
  String? error;

  List<AlertItem> get alerts => List.unmodifiable(_alerts);

  Future<void> fetchAll() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final raw = await api.getAlerts();
      _alerts = raw.map((e) => AlertItem.fromJson(e)).toList();
    } catch (e) {
      error = 'Could not reach the backend. Is it running? ($e)';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> addAlert({
    required AlertSeverity severity,
    required String title,
    required String description,
  }) async {
    final result = await api.createAlert({
      'severity': severity.apiValue,
      'title': title,
      'description': description,
    });
    _alerts.insert(0, AlertItem.fromJson(result));
    notifyListeners();
  }

  Future<void> updateAlert(String id, {
    required AlertSeverity severity,
    required String title,
    required String description,
  }) async {
    final result = await api.updateAlert(id, {
      'severity': severity.apiValue,
      'title': title,
      'description': description,
    });
    final idx = _alerts.indexWhere((a) => a.id == id);
    if (idx != -1) _alerts[idx] = AlertItem.fromJson(result);
    notifyListeners();
  }

  Future<void> deleteAlert(String id) async {
    await api.deleteAlert(id);
    _alerts.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}