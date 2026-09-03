import 'package:flutter/material.dart';
import '../models/fence.dart';
import '../services/api_service.dart';

class FenceProvider extends ChangeNotifier {
  final ApiService api;
  FenceProvider({required this.api});

  List<FenceZone> _zones = [];
  FenceSettings settings = FenceSettings(
    sensitivity: 3, humanDetection: true, animalFilter: true,
    directionalAlert: false, armed: false,
  );
  bool loading = false;
  String? error;

  List<FenceZone> get zones => List.unmodifiable(_zones);

  Future<void> fetchAll() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final rawZones = await api.getZones();
      _zones = rawZones.map((e) => FenceZone.fromJson(e)).toList();
      final rawSettings = await api.getFenceSettings();
      settings = FenceSettings.fromJson(rawSettings);
    } catch (e) {
      error = 'Could not reach the backend. Is it running? ($e)';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> addZone(String name, String status) async {
    final result = await api.createZone({'name': name, 'status': status});
    _zones.add(FenceZone.fromJson(result));
    notifyListeners();
  }

  Future<void> updateZone(String id, String name, String status) async {
    final result = await api.updateZone(id, {'name': name, 'status': status});
    final idx = _zones.indexWhere((z) => z.id == id);
    if (idx != -1) _zones[idx] = FenceZone.fromJson(result);
    notifyListeners();
  }

  Future<void> deleteZone(String id) async {
    await api.deleteZone(id);
    _zones.removeWhere((z) => z.id == id);
    notifyListeners();
  }

  Future<void> patchSettings(Map<String, dynamic> patch) async {
    final result = await api.patchFenceSettings(patch);
    settings = FenceSettings.fromJson(result);
    notifyListeners();
  }

  Future<void> setSensitivity(int v) => patchSettings({'sensitivity': v});
  Future<void> toggleHuman(bool v) => patchSettings({'human_detection': v});
  Future<void> toggleAnimal(bool v) => patchSettings({'animal_filter': v});
  Future<void> toggleDirectional(bool v) => patchSettings({'directional_alert': v});
  Future<void> toggleArmed() => patchSettings({'armed': !settings.armed});
}
