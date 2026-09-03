import 'package:flutter/material.dart';
import '../models/camera.dart';
import '../services/api_service.dart';

class CameraProvider extends ChangeNotifier {
  final ApiService api;
  CameraProvider({required this.api});

  List<SurveillanceCamera> _cameras = [];
  bool loading = false;
  String? error;
  String? selectedCameraId;

  List<SurveillanceCamera> get cameras => List.unmodifiable(_cameras);

  SurveillanceCamera get selected => _cameras.firstWhere(
        (c) => c.id == selectedCameraId,
        orElse: () => _cameras.isNotEmpty
            ? _cameras.first
            : SurveillanceCamera(
                id: '0', name: 'No Camera', sector: '-', ip: '-', rtsp: '',
                type: CameraType.fixed, online: false, feedImage: ''),
      );

  void selectCamera(String id) {
    selectedCameraId = id;
    notifyListeners();
  }

  Future<void> fetchAll() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final raw = await api.getCameras();
      _cameras = raw.map((e) => SurveillanceCamera.fromJson(e)).toList();
      if (_cameras.isNotEmpty && selectedCameraId == null) {
        selectedCameraId = _cameras.first.id;
      }
    } catch (e) {
      error = 'Could not reach the backend. Is it running? ($e)';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> addCamera({
    required String name,
    required String sector,
    required String ip,
    required String rtsp,
    required CameraType type,
    required bool online,
    String feedImage = '',
    bool night = false,
  }) async {
    final cam = SurveillanceCamera(
      id: 'temp', name: name, sector: sector, ip: ip,
      rtsp: rtsp.isEmpty ? 'rtsp://$ip:554/stream1' : rtsp,
      type: type, online: online,
      feedImage: feedImage.isEmpty
          ? 'https://images.unsplash.com/photo-1441829266145-0ce8b0a10b32?w=800&q=68'
          : feedImage,
      night: night,
    );
    final result = await api.createCamera(cam.toJson());
    _cameras.add(SurveillanceCamera.fromJson(result));
    notifyListeners();
  }

  Future<void> updateCamera(String id, {
    required String name,
    required String sector,
    required String ip,
    required String rtsp,
    required CameraType type,
    required bool online,
  }) async {
    final cam = _cameras.firstWhere((c) => c.id == id);
    final updated = cam.copyWith(name: name, sector: sector, ip: ip, rtsp: rtsp, type: type, online: online);
    final result = await api.updateCamera(id, updated.toJson());
    final idx = _cameras.indexOf(cam);
    _cameras[idx] = SurveillanceCamera.fromJson(result);
    notifyListeners();
  }

  Future<void> deleteCamera(String id) async {
    await api.deleteCamera(id);
    _cameras.removeWhere((c) => c.id == id);
    if (selectedCameraId == id) {
      selectedCameraId = _cameras.isNotEmpty ? _cameras.first.id : null;
    }
    notifyListeners();
  }
}
