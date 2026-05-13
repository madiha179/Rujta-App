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
      return Uri.parse('$_apiRoot/users/drugsbylocation/$lng/$lat');
    }
    final key = Uri.encodeComponent(searchKey.trim());
    return Uri.parse('$_apiRoot/users/drugsbylocation/$lng/$lat/$key');
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

  /// Branch / pharmacy id from a response envelope (used when each drug row omits `branch_id`).
  static String? _branchFromMap(Map<String, dynamic>? m) {
    if (m == null) return null;
    for (final k in [
      'branch_id',
      'branchId',
      'pharmacy_branch_id',
      'PharmacyBranchId',
      'pharmacy_id',
      'pharmacyId',
      'nearest_branch_id',
      'nearestBranchId',
      'default_branch_id',
      'defaultBranchId',
    ]) {
      final v = m[k];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString().trim();
      }
    }
    final b = m['branch'];
    if (b is num) return b.toString();
    if (b is Map) {
      final id = b['id'] ?? b['branch_id'];
      if (id != null && id.toString().trim().isNotEmpty) {
        return id.toString().trim();
      }
    }
    final p = m['pharmacy'];
    if (p is num) return p.toString();
    if (p is Map) {
      final id = p['id'] ?? p['branch_id'];
      if (id != null && id.toString().trim().isNotEmpty) {
        return id.toString().trim();
      }
    }
    return null;
  }

  static bool _itemHasBranch(Map<String, dynamic> map) {
    if (map['branch_id'] != null ||
        map['branchId'] != null ||
        map['pharmacy_id'] != null ||
        map['pharmacyId'] != null ||
        map['pharmacy_branch_id'] != null ||
        map['PharmacyBranchId'] != null) {
      return true;
    }
    // Stock line often carries branch as nested object, not a flat `branch_id`.
    if (map['branch'] != null ||
        map['pharmacy'] != null ||
        map['nearest_pharmacy'] != null ||
        map['nearestPharmacy'] != null ||
        map['pharmacy_branch'] != null) {
      return true;
    }
    final drug = map['drug'];
    if (drug is Map) {
      final dm = Map<String, dynamic>.from(drug);
      return dm['branch_id'] != null ||
          dm['branchId'] != null ||
          dm['pharmacy_id'] != null ||
          dm['pharmacyId'] != null ||
          dm['branch'] != null ||
          dm['pharmacy'] != null;
    }
    return false;
  }

  /// Branch id on wrapper objects (root, `data`, `data.result`, etc.) — not inside each drug.
  static String? _branchFromEnvelope(Map<String, dynamic> root) {
    final maps = <Map<String, dynamic>>[Map<String, dynamic>.from(root)];
    final data = root['data'];
    if (data is Map<String, dynamic>) {
      final dm = Map<String, dynamic>.from(data);
      maps.add(dm);
      for (final key in ['result', 'meta', 'pagination', 'envelope', 'response']) {
        final sub = dm[key];
        if (sub is Map<String, dynamic>) {
          maps.add(Map<String, dynamic>.from(sub));
        }
      }
    }
    for (final m in maps) {
      final b = _branchFromMap(m);
      if (b != null) return b;
    }
    return null;
  }

  static bool _isBranchLikeKey(String rawKey) {
    final k = rawKey.toLowerCase().replaceAll(' ', '');
    const exact = {
      'branch_id',
      'branchid',
      'pharmacy_branch_id',
      'pharmacybranchid',
      'nearest_branch_id',
      'nearestbranchid',
      'default_branch_id',
      'defaultbranchid',
      'location_branch_id',
      'locationbranchid',
    };
    if (exact.contains(k)) return true;
    return k.endsWith('_branch_id');
  }

  static bool _looksLikeNumericId(String s) {
    final t = s.trim();
    return t.isNotEmpty && int.tryParse(t) != null;
  }

  static String _normKey(String raw) =>
      raw.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');

  /// JSON often nests the branch as `"branch": { "id": 3 }` (no `branch_id` key).
  static bool _isBranchContainerKey(String rawKey) {
    final k = _normKey(rawKey);
    return k == 'branch' ||
        k == 'pharmacy' ||
        k == 'nearestpharmacy' ||
        k == 'pharmacybranch' ||
        k == 'selectedpharmacy' ||
        k == 'nearestbranch';
  }

  static String? _idFromBranchNestedMap(Map<String, dynamic> inner) {
    for (final ik in [
      'branch_id',
      'branchId',
      'id',
      'pharmacy_id',
      'pharmacyId',
      'pharmacy_branch_id',
    ]) {
      final v = inner[ik];
      if (v == null) continue;
      if (v is num) return v.toString();
      final s = v.toString().trim();
      if (_looksLikeNumericId(s)) return s;
    }
    return null;
  }

  /// DFS: first numeric-looking value on a branch-like key (handles odd JSON shapes).
  static String? _findBranchIdDeep(dynamic node, [int depth = 0]) {
    if (node == null || depth > 35) return null;
    if (node is Map) {
      final m = Map<String, dynamic>.from(node);
      for (final e in m.entries) {
        final key = e.key.toString();
        final v = e.value;
        if (_isBranchContainerKey(key)) {
          if (v is num) return v.toString();
          if (v is Map) {
            final nested = _idFromBranchNestedMap(
              Map<String, dynamic>.from(v),
            );
            if (nested != null) return nested;
          }
        }
        if (!_isBranchLikeKey(key)) continue;
        if (v == null) continue;
        if (v is num) return v.toString();
        final s = v.toString().trim();
        if (_looksLikeNumericId(s)) return s;
      }
      for (final v in m.values) {
        final r = _findBranchIdDeep(v, depth + 1);
        if (r != null) return r;
      }
    } else if (node is List) {
      for (final v in node) {
        final r = _findBranchIdDeep(v, depth + 1);
        if (r != null) return r;
      }
    }
    return null;
  }

  List<DrugModel> _extractDrugList(dynamic decoded) {
    if (decoded is List) {
      final deep = _findBranchIdDeep(decoded);
      return decoded
          .whereType<Map>()
          .map((e) {
            final map = Map<String, dynamic>.from(e);
            if (deep != null && !_itemHasBranch(map)) {
              map['branch_id'] = deep;
            }
            return DrugModel.fromJson(map);
          })
          .toList();
    }
    if (decoded is! Map<String, dynamic>) return [];

    final root = Map<String, dynamic>.from(decoded);
    final envelopeBranch = _branchFromEnvelope(root);

    dynamic listCandidate = root['data'];

    if (listCandidate is List) {
      return listCandidate
          .whereType<Map>()
          .map((e) {
            final map = Map<String, dynamic>.from(e);
            if (envelopeBranch != null && !_itemHasBranch(map)) {
              map['branch_id'] = envelopeBranch;
            }
            return DrugModel.fromJson(map);
          })
          .toList();
    }

    String? dataBranch;
    if (listCandidate is Map<String, dynamic>) {
      final dataMap = Map<String, dynamic>.from(listCandidate);
      dataBranch = _branchFromMap(dataMap);
      listCandidate = dataMap['data'] ??
          dataMap['result'] ??
          dataMap['drugs'] ??
          dataMap['rows'] ??
          dataMap['list'];
    }

    if (listCandidate is Map<String, dynamic>) {
      final mid = Map<String, dynamic>.from(listCandidate);
      dataBranch = dataBranch ?? _branchFromMap(mid);
      listCandidate =
          mid['rows'] ?? mid['drugs'] ?? mid['list'] ?? mid['items'] ?? mid['data'];
    }

    if (listCandidate is! List) {
      listCandidate = root['drugs'] ?? root['result'] ?? root['rows'];
    }

    if (listCandidate is! List) return [];

    final deepBranch = _findBranchIdDeep(decoded);
    final inheritedBranch =
        dataBranch ?? envelopeBranch ?? _branchFromMap(root) ?? deepBranch;

    return listCandidate
        .whereType<Map>()
        .map((e) {
          final map = Map<String, dynamic>.from(e);
          if (inheritedBranch != null && !_itemHasBranch(map)) {
            map['branch_id'] = inheritedBranch;
          }
          return DrugModel.fromJson(map);
        })
        .toList();
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
      final anyBranch = _findBranchIdDeep(decoded);
      if (anyBranch != null) {
        await _storage.write(key: 'cart_cached_branch_id', value: anyBranch);
      }
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
