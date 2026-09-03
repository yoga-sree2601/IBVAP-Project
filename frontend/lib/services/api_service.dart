import 'dart:convert';
import 'package:http/http.dart' as http;

/// Base URL for the IBVAP backend.
///
/// Override at run/build time, e.g.:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.23:8000
///
/// Defaults to 10.0.2.2 (Android emulator's alias for the host laptop's
/// localhost) since that's the most common dev setup in Android Studio.
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000',
);

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  final String baseUrl;
  ApiService({this.baseUrl = kApiBaseUrl});

  Uri _u(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  Future<dynamic> _handle(http.Response res) async {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }
    throw ApiException('API error ${res.statusCode}: ${res.body}');
  }

  Future<bool> ping() async {
    try {
      final res = await http.get(_u('/')).timeout(const Duration(seconds: 4));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> login(String operatorId, String passcode) async {
    final res = await http.post(
      _u('/auth/login'),
      headers: _headers,
      body: jsonEncode({'operator_id': operatorId, 'passcode': passcode}),
    ).timeout(const Duration(seconds: 8));
    return await _handle(res) as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------- Cameras
  Future<List<dynamic>> getCameras() async {
    final res = await http.get(_u('/cameras'), headers: _headers);
    return await _handle(res) as List<dynamic>;
  }

  Future<Map<String, dynamic>> createCamera(Map<String, dynamic> body) async {
    final res = await http.post(_u('/cameras'), headers: _headers, body: jsonEncode(body));
    return await _handle(res) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCamera(String id, Map<String, dynamic> body) async {
    final res = await http.put(_u('/cameras/$id'), headers: _headers, body: jsonEncode(body));
    return await _handle(res) as Map<String, dynamic>;
  }

  Future<void> deleteCamera(String id) async {
    final res = await http.delete(_u('/cameras/$id'));
    await _handle(res);
  }

  // ----------------------------------------------------------------- Alerts
  Future<List<dynamic>> getAlerts() async {
    final res = await http.get(_u('/alerts'), headers: _headers);
    return await _handle(res) as List<dynamic>;
  }

  Future<Map<String, dynamic>> createAlert(Map<String, dynamic> body) async {
    final res = await http.post(_u('/alerts'), headers: _headers, body: jsonEncode(body));
    return await _handle(res) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateAlert(String id, Map<String, dynamic> body) async {
    final res = await http.put(_u('/alerts/$id'), headers: _headers, body: jsonEncode(body));
    return await _handle(res) as Map<String, dynamic>;
  }

  Future<void> deleteAlert(String id) async {
    final res = await http.delete(_u('/alerts/$id'));
    await _handle(res);
  }

  // ------------------------------------------------------------------ Fence
  Future<List<dynamic>> getZones() async {
    final res = await http.get(_u('/fence/zones'), headers: _headers);
    return await _handle(res) as List<dynamic>;
  }

  Future<Map<String, dynamic>> createZone(Map<String, dynamic> body) async {
    final res = await http.post(_u('/fence/zones'), headers: _headers, body: jsonEncode(body));
    return await _handle(res) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateZone(String id, Map<String, dynamic> body) async {
    final res = await http.put(_u('/fence/zones/$id'), headers: _headers, body: jsonEncode(body));
    return await _handle(res) as Map<String, dynamic>;
  }

  Future<void> deleteZone(String id) async {
    final res = await http.delete(_u('/fence/zones/$id'));
    await _handle(res);
  }

  Future<Map<String, dynamic>> getFenceSettings() async {
    final res = await http.get(_u('/fence/settings'), headers: _headers);
    return await _handle(res) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> patchFenceSettings(Map<String, dynamic> body) async {
    final res = await http.patch(_u('/fence/settings'), headers: _headers, body: jsonEncode(body));
    return await _handle(res) as Map<String, dynamic>;
  }
}
