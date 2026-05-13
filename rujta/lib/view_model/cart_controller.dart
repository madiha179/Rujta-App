import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:Rujta/core/constants.dart';
import 'package:Rujta/models/cart_line_model.dart';
import 'package:Rujta/models/drug_model.dart';
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

      if (res.statusCode != 200) return;

      final decoded = jsonDecode(res.body);
      final parsed = _parseCartPayload(decoded);
      _lines
        ..clear()
        ..addAll(parsed);
    } catch (_) {
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
      listCandidate = decoded['cart'] ??
          decoded['data'] ??
          decoded['items'];
    }

    if (listCandidate is! List) return [];

    final out = <CartLineModel>[];
    for (final raw in listCandidate) {
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw);

      final cartId = _str(m['id']);

      final drugId = _str(m['drug_id'] ?? m['drugId']);
      if (drugId == null) continue;

      final name = _str(m['drug_name'] ?? m['name']) ?? 'Item';

      final price = _double(m['price']);

      final qty = _int(m['quantity'] ?? m['qty']) ?? 1;

      final img = _str(
            m['image_url'] ??
            m['imgae_url'] ??
            m['imageUrl'] ??
            m['image'],
          ) ??
          '';

      out.add(CartLineModel(
        cartId: cartId,
        drugId: drugId,
        name: name,
        unitPrice: price,
        imageUrl: img,
        quantity: qty.clamp(1, 999),
      ));
    }
    return out;
  }


  Future<String?> addDrug(DrugModel drug, {int quantity = 1}) async {
    final auth = await _authHeader();
    if (auth == null) return 'Please sign in to add items to your cart.';

    final drugId = drug.cartDrugId.trim();
    final branchStr = drug.cartBranchId?.trim();

    int? branchIdInt =
        branchStr != null && branchStr.isNotEmpty
            ? int.tryParse(branchStr)
            : null;
    branchIdInt ??=
        int.tryParse((await _storage.read(key: _cachedBranchKey)) ?? '');
    branchIdInt ??= kFallbackCartBranchId;

    if (branchIdInt == null) {
      return 'Cannot add to cart: missing branch_id. '
          'Set kFallbackCartBranchId in lib/core/constants.dart for testing.';
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

      if (res.statusCode == 200 ||
          res.statusCode == 201 ||
          res.statusCode == 204) {
        await _storage.write(
          key: _cachedBranchKey,
          value: branchIdInt.toString(),
        );
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


  Future<String?> removeLine(String cartId) async {
    final auth = await _authHeader();
    if (auth == null) return 'Please sign in.';

    try {
      final res = await http
          .delete(
            Uri.parse('$_apiRoot/cart/$cartId'),
            headers: {
              'Accept': 'application/json',
              'Authorization': auth,
            },
          )
          .timeout(const Duration(seconds: 25));

      if (res.statusCode == 200 || res.statusCode == 204) {
        _lines.removeWhere((e) => e.cartId == cartId);
        notifyListeners();
        return null;
      }

      try {
        final map = jsonDecode(res.body);
        if (map is Map && map['message'] != null) {
          return map['message'].toString();
        }
      } catch (_) {}
      return 'Could not remove item (${res.statusCode}).';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> clearCart() async {
    final auth = await _authHeader();
    if (auth == null) return 'Please sign in.';

    try {
      final res = await http
          .delete(
            Uri.parse('$_apiRoot/cart'),
            headers: {
              'Accept': 'application/json',
              'Authorization': auth,
            },
          )
          .timeout(const Duration(seconds: 25));

      if (res.statusCode == 200 || res.statusCode == 204) {
        _lines.clear();
        notifyListeners();
        return null;
      }

      try {
        final map = jsonDecode(res.body);
        if (map is Map && map['message'] != null) {
          return map['message'].toString();
        }
      } catch (_) {}
      return 'Could not clear cart (${res.statusCode}).';
    } catch (e) {
      return e.toString();
    }
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

  void clearLocal() {
    _lines.clear();
    notifyListeners();
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
}