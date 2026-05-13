import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  State<InventoryManagementScreen> createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState
    extends State<InventoryManagementScreen> {
  static const Color _green     = Color(0xFF4CAF50);
  static const Color _darkGreen = Color(0xFF388E3C);
  static const String _base     =
      'https://rujta-app-production.up.railway.app';

  final _storage = const FlutterSecureStorage();

  List<Map<String, dynamic>> _drugs    = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  int  _totalStock    = 0;
  int  _lowStockCount = 0;

  final TextEditingController _searchController = TextEditingController();

  int _currentPage = 1;
  int _totalPages  = 1;

  @override
  void initState() {
    super.initState();
    _fetchDrugs();
    _fetchStats();
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _filtered = List.from(_drugs));
    } else {
      _searchDrugs(q);
    }
  }

  Future<void> _fetchDrugs({int page = 1}) async {
    setState(() => _loading = true);
    try {
      final token = await _storage.read(key: 'auth_token');
      final res = await http.get(
        Uri.parse('$_base/api/v1/admin/alldrugs?page=$page'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List list = body['data']?['drugs'] ?? [];
        setState(() {
          _drugs       = list.cast<Map<String, dynamic>>();
          _filtered    = List.from(_drugs);
          _currentPage = body['currentPage'] ?? 1;
          _totalPages  = body['totalPages']  ?? 1;
        });
      }
    } catch (e) {
      debugPrint('Fetch drugs error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

 Future<void> _fetchStats() async {
  try {
    final token = await _storage.read(key: 'auth_token');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final results = await Future.wait([
      http.get(Uri.parse('$_base/api/v1/admin/drugs/total'), headers: headers),
      http.get(Uri.parse('$_base/api/v1/admin/drugs/low'),   headers: headers),
    ]);

    if (results[0].statusCode == 200) {
      final data = jsonDecode(results[0].body);
      final list = data['data'] as List;
      setState(() =>
          _totalStock = int.tryParse(list[0]['Total_Stock'].toString()) ?? 0);
    }

    if (results[1].statusCode == 200) {
      final data = jsonDecode(results[1].body);
      final list = data['data'] as List;
      setState(() =>
          _lowStockCount = (list[0]['Low_Stock'] as num?)?.toInt() ?? 0);
    }
  } catch (e) {
    debugPrint('Stats error: $e');
  }
}

  Future<void> _searchDrugs(String key) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final res = await http.get(
        Uri.parse('$_base/api/v1/admin/drugs/search/$key'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List list = body['data'] ?? [];
        setState(() => _filtered = list.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      debugPrint('Search error: $e');
    }
  }

  Future<void> _deleteDrug(int branchId, int drugId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final res = await http.delete(
        Uri.parse('$_base/api/v1/admin/drugs/$branchId/$drugId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200 || res.statusCode == 204) {
        await _fetchDrugs(page: _currentPage);
        await _fetchStats();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Drug deleted successfully')));
        }
      }
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  void _showAddDialog() {
    final nameCtrl   = TextEditingController();
    final priceCtrl  = TextEditingController();
    final qtyCtrl    = TextEditingController();
    final expCtrl    = TextEditingController();
    final branchCtrl = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Drug'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(nameCtrl,   'Drug Name'),
              const SizedBox(height: 12),
              _dialogField(branchCtrl, 'Branch ID',  type: TextInputType.number),
              const SizedBox(height: 12),
              _dialogField(priceCtrl,  'Price (EGP)', type: TextInputType.number),
              const SizedBox(height: 12),
              _dialogField(qtyCtrl,    'Quantity',    type: TextInputType.number),
              const SizedBox(height: 12),
              _dialogField(expCtrl,    'Expiry Date (YYYY-MM-DD)'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _green),
            onPressed: () async {
              Navigator.pop(ctx);
              await _addDrug(
                name:     nameCtrl.text.trim(),
                branchId: int.tryParse(branchCtrl.text.trim()) ?? 1,
                price:    priceCtrl.text.trim(),
                quantity: qtyCtrl.text.trim(),
                expDate:  expCtrl.text.trim(),
              );
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(Map<String, dynamic> drug) {
    final branchId  = drug['branchId'] as int? ?? 1;
    final drugId    = drug['drugId']   as int? ?? 0;
    final priceCtrl = TextEditingController(
        text: drug['price']?.toString() ?? '');
    final qtyCtrl   = TextEditingController(
        text: drug['quantity']?.toString() ??
              drug['stock']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update: ${drug['drug_name'] ?? drug['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(priceCtrl, 'New Price (EGP)', type: TextInputType.number),
            const SizedBox(height: 12),
            _dialogField(qtyCtrl,   'New Quantity',    type: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _green),
            onPressed: () async {
              Navigator.pop(ctx);
              await _updateDrug(
                branchId: branchId,
                drugId:   drugId,
                newPrice: priceCtrl.text.trim(),
                quantity: qtyCtrl.text.trim(),
              );
            },
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String label,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(labelText: label),
    );
  }

  Future<void> _addDrug({
    required String name,
    required int    branchId,
    required String price,
    required String quantity,
    required String expDate,
  }) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final req = http.MultipartRequest(
        'POST',
        Uri.parse('$_base/api/v1/admin/drugs'),
      );
      if (token != null) req.headers['Authorization'] = 'Bearer $token';
      req.fields['name']     = name;
      req.fields['branchId'] = branchId.toString();
      req.fields['price']    = price;
      req.fields['quantity'] = quantity;
      req.fields['expDate']  = expDate;

      final streamed = await req.send();
      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        await _fetchDrugs(page: _currentPage);
        await _fetchStats();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Drug added successfully')));
        }
      }
    } catch (e) {
      debugPrint('Add drug error: $e');
    }
  }

  Future<void> _updateDrug({
    required int    branchId,
    required int    drugId,
    required String newPrice,
    required String quantity,
  }) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final res = await http.patch(
        Uri.parse('$_base/api/v1/admin/drugs/$branchId/$drugId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'newPrice': double.tryParse(newPrice) ?? 0,
          'quantity': int.tryParse(quantity)    ?? 0,
        }),
      );
      if (res.statusCode == 200) {
        await _fetchDrugs(page: _currentPage);
        await _fetchStats();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Drug updated successfully')));
        }
      }
    } catch (e) {
      debugPrint('Update error: $e');
    }
  }

  void _confirmDelete(int branchId, int drugId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Drug'),
        content: const Text('Are you sure you want to delete this drug?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              _deleteDrug(branchId, drugId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Inventory Manager',
          style: TextStyle(
            color: _green,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search drugs...',
                        hintStyle:
                            TextStyle(color: Colors.black38, fontSize: 14),
                        prefixIcon: Icon(Icons.search,
                            color: Colors.black38, size: 20),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),

                // Stats row
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label:      'TOTAL STOCK',
                          value:      '$_totalStock Units',
                          valueColor: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label:      'LOW STOCK',
                          value:      '$_lowStockCount Items',
                          valueColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),

                // Drug list
                Expanded(
                  child: _filtered.isEmpty
                      ? const Center(
                          child: Text('No drugs found',
                              style: TextStyle(color: Colors.black45)))
                      : ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          itemCount: _filtered.length,
                          itemBuilder: (ctx, i) {
                            final drug     = _filtered[i];
                            final branchId =
                                drug['branchId'] as int? ?? 0;
                            final drugId =
                                drug['drugId'] as int? ?? 0;
                            final name = drug['drug_name'] ??
                                drug['name'] ??
                                'Unknown';
                            final price =
                                drug['price']?.toString() ?? '0';
                            final stock =
                                (drug['quantity'] as num?)?.toInt() ??
                                (drug['stock'] as num?)?.toInt() ??
                                0;
                            final isLow    = stock < 10;
                            final imageUrl =
                                drug['image_url'] as String?;

                            return Container(
                              margin:
                                  const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        const BorderRadius.vertical(
                                            top: Radius.circular(12)),
                                    child: imageUrl != null &&
                                            imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl,
                                            height: 160,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (_, __, ___) =>
                                                    _PlaceholderImage(
                                                        index: i),
                                          )
                                        : _PlaceholderImage(index: i),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(
                                            14, 12, 14, 14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                name,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color:
                                                      Colors.black87,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isLow
                                                    ? const Color(
                                                        0xFFFFEBEE)
                                                    : const Color(
                                                        0xFFE8F5E9),
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(20),
                                              ),
                                              child: Text(
                                                isLow
                                                    ? 'Low Stock'
                                                    : 'In Stock',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color: isLow
                                                      ? Colors.red
                                                      : _green,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '$price EGP',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: _green,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () =>
                                                    _showUpdateDialog(
                                                        drug),
                                                style: OutlinedButton
                                                    .styleFrom(
                                                  side: const BorderSide(
                                                      color: _green),
                                                  shape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(8),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Update',
                                                  style: TextStyle(
                                                      color: _green,
                                                      fontWeight:
                                                          FontWeight
                                                              .w600),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () =>
                                                    _confirmDelete(
                                                        branchId,
                                                        drugId),
                                                style: OutlinedButton
                                                    .styleFrom(
                                                  side: const BorderSide(
                                                      color: Colors.red),
                                                  shape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(8),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight
                                                              .w600),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                // Pagination
                if (_totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _currentPage > 1
                              ? () =>
                                  _fetchDrugs(page: _currentPage - 1)
                              : null,
                        ),
                        Text('$_currentPage / $_totalPages'),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _currentPage < _totalPages
                              ? () =>
                                  _fetchDrugs(page: _currentPage + 1)
                              : null,
                        ),
                      ],
                    ),
                  ),
              ],
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: _darkGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: _green,
        unselectedItemColor: Colors.black38,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/AdminProfile');
          }
        },
      ),
    );
  }
}

// Helper Widgets

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color  valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black45,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final int index;
  const _PlaceholderImage({required this.index});

  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xFFE8F5E9),
      Color(0xFFE3F2FD),
      Color(0xFFF3E5F5),
      Color(0xFFFFF3E0),
    ];
    return Container(
      height: 160,
      width: double.infinity,
      color: colors[index % colors.length],
      child: const Icon(Icons.medication_outlined,
          size: 60, color: Colors.black26),
    );
  }
}