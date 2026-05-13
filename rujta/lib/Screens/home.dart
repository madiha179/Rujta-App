import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Rujta/core/constants.dart';
import 'package:Rujta/core/widgets/drug_card.dart';
import 'package:Rujta/models/drug_model.dart';
import 'package:Rujta/view_model/cart_controller.dart';
import 'package:Rujta/view_model/drug_store_home_view_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DrugStoreHomeViewModel _viewModel = DrugStoreHomeViewModel();
  late final TextEditingController _searchController;
  Timer? _searchDebounce;
  int _fetchToken = 0;
  List<DrugModel> _drugs = [];
  bool _loadingBoot = true;
  bool _loadingList = false;
  String? _error;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _bootstrap();
    _searchController.addListener(() {
      if (_latitude == null || _longitude == null) return;
      _searchDebounce?.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 420), () {
        _reloadDrugs(_searchController.text);
      });
    });
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loadingBoot = true;
      _error = null;
    });
    try {
      final position = await _viewModel.getCurrentPosition();
      if (!mounted) return;
      if (position == null) {
        setState(() {
          _loadingBoot = false;
          _error =
              'Location is unavailable. Enable GPS and grant permission to browse nearby drugs.';
        });
        return;
      }
      _latitude = position.latitude;
      _longitude = position.longitude;
      await _reloadDrugs(_searchController.text, silent: true);
      if (!mounted) return;
      setState(() {
        _loadingBoot = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingBoot = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _reloadDrugs(String query, {bool silent = false}) async {
    final lat = _latitude;
    final lng = _longitude;
    if (lat == null || lng == null) return;

    final token = ++_fetchToken;
    if (!silent && mounted) {
      setState(() {
        _loadingList = true;
        _error = null;
      });
    }

    try {
      final list = await _viewModel.fetchDrugsNearby(
        latitude: lat,
        longitude: lng,
        searchQuery: query.trim(),
      );
      if (!mounted || token != _fetchToken) return;
      setState(() {
        _drugs = list;
        _loadingList = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted || token != _fetchToken) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _drugs = [];
        _loadingList = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _showAddToCartSheet(BuildContext context, DrugModel drug) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(sheetCtx).viewPadding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: drug.imageUrl.isNotEmpty
                          ? Image.network(
                              drug.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => ColoredBox(
                                color: const Color(0xFFF5F5F7),
                                child: Icon(Icons.medication_outlined,
                                    color: kMainColor, size: 36),
                              ),
                            )
                          : ColoredBox(
                              color: const Color(0xFFF5F5F7),
                              child: Icon(Icons.medication_outlined,
                                  color: kMainColor, size: 36),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          drug.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${drug.price % 1 == 0 ? drug.price.toStringAsFixed(0) : drug.price.toStringAsFixed(2)} EGP',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: kMainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: kMainColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final cart = sheetCtx.read<CartController>();
                  final err = await cart.addDrug(drug);
                  if (!sheetCtx.mounted) return;
                  Navigator.of(sheetCtx).pop();
                  if (!context.mounted) return;
                  if (err != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(err)),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to cart')),
                    );
                  }
                },
                child: const Text('Add to cart'),
              ),
              TextButton(
                onPressed: () => Navigator.of(sheetCtx).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: _loadingBoot
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Text(
                      'Drug store',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search meds here',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon:
                            Icon(Icons.search, color: Colors.grey.shade600),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: const BorderSide(color: kMainColor),
                        ),
                      ),
                      onSubmitted: (_) =>
                          _reloadDrugs(_searchController.text),
                    ),
                  ),
                  if (_error != null && _drugs.isEmpty)
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: _bootstrap,
                                style: FilledButton.styleFrom(
                                  backgroundColor: kMainColor,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          RefreshIndicator(
                            color: kMainColor,
                            onRefresh: () =>
                                _reloadDrugs(_searchController.text),
                            child: _drugs.isEmpty && !_loadingList
                                ? ListView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.only(top: 80),
                                    children: [
                                      Center(
                                        child: Text(
                                          'No medicines found.',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : GridView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      0,
                                      16,
                                      12,
                                    ),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 6,
                                      crossAxisSpacing: 12,
                                      // Match ~intrinsic DrugCard height (image + text block).
                                      childAspectRatio: 0.62,
                                    ),
                                    itemCount: _drugs.length,
                                    itemBuilder: (context, i) {
                                      // Loose max height so the card only uses intrinsic
                                      // height — avoids empty strip below the last row.
                                      return Align(
                                        alignment: Alignment.topCenter,
                                        child: DrugCard(
                                          drug: _drugs[i],
                                          onTap: () => _showAddToCartSheet(
                                            context,
                                            _drugs[i],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          if (_loadingList)
                            const LinearProgressIndicator(
                              minHeight: 3,
                              color: kMainColor,
                              backgroundColor: Color(0xFFE8E8E8),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
