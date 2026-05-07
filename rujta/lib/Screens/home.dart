import 'dart:async';

import 'package:flutter/material.dart';
import 'package:Rujta/core/constants.dart';
import 'package:Rujta/models/drug_model.dart';
import 'package:Rujta/view_model/drug_store_home_view_model.dart';
import 'package:Rujta/core/widgets/drug_card.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: kMainColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (i) {
          if (i == 1) {
            Navigator.pushReplacementNamed(context, '/UserProfileScreen');
          }
        },
      ),
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
                                      24,
                                    ),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 12,
                                      childAspectRatio: 0.72,
                                    ),
                                    itemCount: _drugs.length,
                                    itemBuilder: (context, i) {
                                      return DrugCard(drug: _drugs[i]);
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
