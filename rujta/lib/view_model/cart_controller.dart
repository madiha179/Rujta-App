import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:Rujta/core/constants.dart';
import 'package:Rujta/models/cart_line_model.dart';
import 'package:Rujta/models/drug_model.dart';

/// Cart state + [POST /api/v1/cart](https://rujta-app-production.up.railway.app/api-docs/#/Cart/post_api_v1_cart).
/// Body (JSON): integer `drug_id`, `branch_id`, `quantity` per Swagger.
class CartController extends ChangeNotifier {
  CartController();

  static const String _apiRoot =
      'https://rujta-app-production.up.railway.app/api/v1';

  static const String _cachedBranchKey = 'cart_cached_branch_id';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final List<CartLineModel> _lines = [];

  List<CartLineModel> get lines => List.unmodifiable(_lines);

  int get totalItemCount =>
      _lines.fold<int>(0, (sum, e) => sum + e.quantity);

  double get subtotal =>
      _lines.fold<double>(0, (sum, e) => sum + e.lineTotal);

  bool _loading = false;
  bool get isLoading => _loading;

  Future<String?> _authHeader() async {
    final t = await _storage.read(key: 'auth_token');
    if (t == null || t.isEmpty) return null;
    return 'Bearer $t';
  }

  /// Pull cart from server (GET /cart). Safe no-op if endpoint missing.
  Future<void> refreshFromServer() async {
    final auth = await _authHeader();
    if (auth == null) {
      _lines.clear();
      notifyListeners();
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      final res = await http.get(
        Uri.parse('$_apiRoot/cart'),
        headers: {
          'Accept': 'application/json',
          'Authorization': auth,
        },
      );

      if (res.statusCode != 200) {
        return;
      }

      final decoded = jsonDecode(res.body);
      final parsed = _parseCartPayload(decoded);
      if (parsed.isNotEmpty) {
        _lines
          ..clear()
          ..addAll(parsed);
      }
    } catch (_) {
      // Keep local lines on network/parsing failure.
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  List<CartLineModel> _parseCartPayload(dynamic decoded) {
    dynamic listCandidate;
    if (decoded is List) {
      listCandidate = decoded;
    } else if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is List) {
        listCandidate = data;
      } else if (data is Map<String, dynamic>) {
        listCandidate = data['items'] ??
            data['cartItems'] ??
            data['lines'] ??
            data['rows'];
      } else {
        listCandidate = decoded['items'];
      }
    }

    if (listCandidate is! List) return [];

    final out = <CartLineModel>[];
    for (final raw in listCandidate) {
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw);
      final nested = m['drug'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(m['drug'] as Map)
          : null;

      final id = _str(m['drugId'] ??
          m['drug_id'] ??
          m['id'] ??
          nested?['id']);
      if (id == null) continue;

      final name = _str(m['name'] ?? nested?['name']) ?? 'Item';
      final price = _double(m['price'] ??
          m['unitPrice'] ??
          m['sellPrice'] ??
          nested?['price']);
      final qty = _int(m['quantity'] ?? m['qty']) ?? 1;
      final img = _str(m['imageUrl'] ?? m['image'] ?? nested?['imageUrl']) ?? '';

      out.add(CartLineModel(
        drugId: id,
        name: name,
        unitPrice: price,
        imageUrl: img,
        quantity: qty.clamp(1, 999),
      ));
    }
    return out;
  }

  String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  double _double(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  int? _int(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v.toString());
  }

  void _upsertLocal(DrugModel drug, int addQty) {
    final i = _lines.indexWhere((e) => e.drugId == drug.id);
    if (i >= 0) {
      _lines[i].quantity += addQty;
    } else {
      _lines.add(CartLineModel(
        drugId: drug.id,
        name: drug.name,
        unitPrice: drug.price,
        imageUrl: drug.imageUrl,
        quantity: addQty,
      ));
    }
  }

  /// [POST /api/v1/cart](https://rujta-app-production.up.railway.app/api-docs/#/Cart/post_api_v1_cart)
  /// JSON body uses integer `drug_id`, `branch_id`, `quantity`.
  Future<String?> addDrug(DrugModel drug, {int quantity = 1}) async {
    final auth = await _authHeader();
    if (auth == null) {
      return 'Please sign in to add items to your cart.';
    }

    final drugId = drug.cartDrugId.trim();
    final branchStr = drug.cartBranchId?.trim();

    int? branchIdInt =
        branchStr != null && branchStr.isNotEmpty ? int.tryParse(branchStr) : null;
    branchIdInt ??=
        int.tryParse((await _storage.read(key: _cachedBranchKey)) ?? '');
    branchIdInt ??= kFallbackCartBranchId;

    if (branchIdInt == null) {
      return 'Cannot add to cart: missing branch_id. '
          'Ask backend to include branch_id on each drug (or on the JSON wrapper), '
          'or set kFallbackCartBranchId in lib/core/constants.dart for testing.';
    }

    final drugIdInt = int.tryParse(drugId) ??
        (drug.branchDrugStockId != null
            ? int.tryParse(drug.branchDrugStockId!)
            : null) ??
        int.tryParse(drug.id);

    if (drugIdInt == null) {
      return 'Invalid drug_id for cart (must be integer). Tried: '
          '${drug.cartDrugId} / ${drug.branchDrugStockId ?? '-'} / ${drug.id}';
    }

    try {
      final res = await http
          .post(
            Uri.parse('$_apiRoot/cart'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': auth,
            },
            body: jsonEncode({
              'drug_id': drugIdInt,
              'branch_id': branchIdInt,
              'quantity': quantity,
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (res.statusCode == 200 || res.statusCode == 201 || res.statusCode == 204) {
        _upsertLocal(drug, quantity);
        notifyListeners();
        return null;
      }

      try {
        final map = jsonDecode(res.body);
        if (map is Map && map['message'] != null) {
          return map['message'].toString();
        }
      } catch (_) {}
      return 'Could not add to cart (${res.statusCode}).';
    } catch (e) {
      return e.toString();
    }
  }

  /// Local remove (until DELETE /cart is wired in Swagger).
  void removeLine(String drugId) {
    _lines.removeWhere((e) => e.drugId == drugId);
    notifyListeners();
  }

  void clearLocal() {
    _lines.clear();
    notifyListeners();
  }
}
