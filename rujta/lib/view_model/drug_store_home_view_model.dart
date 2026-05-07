import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:Rujta/models/drug_model.dart';

class DrugStoreHomeViewModel {
  static const String _apiRoot =
      'https://rujta-app-production.up.railway.app/api/v1';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Uri _nearbyUri(double longitude, double latitude, [String? searchKey]) {
    final lng = longitude.toString();
    final lat = latitude.toString();
    if (searchKey == null || searchKey.trim().isEmpty) {
      return Uri.parse('$_apiRoot/user/drugsbylocation/$lng/$lat');
    }
    final key = Uri.encodeComponent(searchKey.trim());
    return Uri.parse('$_apiRoot/user/drugsbylocation/$lng/$lat/$key');
  }

  Future<Position?> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }

  List<DrugModel> _extractDrugList(dynamic decoded) {
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((e) => DrugModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (decoded is! Map<String, dynamic>) return [];

    dynamic listCandidate = decoded['data'];
    if (listCandidate is Map<String, dynamic>) {
      listCandidate =
          listCandidate['result'] ?? listCandidate['drugs'] ?? listCandidate['rows'];
    }
    if (listCandidate is List) {
      return listCandidate
          .whereType<Map>()
          .map((e) => DrugModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<List<DrugModel>> fetchDrugsNearby({
    required double latitude,
    required double longitude,
    String searchQuery = '',
  }) async {
    final token = await _storage.read(key: 'auth_token');
    final uri =
        _nearbyUri(longitude, latitude, searchQuery.trim().isEmpty ? null : searchQuery);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return _extractDrugList(decoded);
    }

    String message =
        response.statusCode == 401 || response.statusCode == 403
            ? 'Please sign in again'
            : 'Could not load drugs (${response.statusCode})';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['message'] != null) {
        message = decoded['message'].toString();
      }
    } catch (_) {}

    throw Exception(message);
  }
}
