class DrugModel {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final int? discountPercent;
  final String imageUrl;
  final String locationLabel;

  const DrugModel({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    this.imageUrl = '',
    this.locationLabel = '',
  });

  bool get hasDiscount =>
      discountPercent != null ||
      (originalPrice != null && originalPrice! > price);

  static double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v.toString());
  }

  static String? _firstNonEmptyString(List<dynamic> candidates) {
    for (final c in candidates) {
      if (c is String && c.trim().isNotEmpty) return c.trim();
    }
    return null;
  }

  factory DrugModel.fromJson(Map<String, dynamic> json) {
    final nested = json['drug'];
    final Map<String, dynamic> d = {...json};
    final nestedMap =
        nested is Map<String, dynamic> ? nested : null;

    double priceNum() =>
        _asDouble(
              d['price'] ??
                  d['sell_price'] ??
                  d['sellPrice'] ??
                  d['current_price'] ??
                  d['currentPrice'] ??
                  (nestedMap != null ? nestedMap['price'] : null),
            ) ??
            0;

    double? originalNum() => _asDouble(
          d['original_price'] ??
              d['originalPrice'] ??
              d['old_price'] ??
              d['mrp'],
        );

    final name =
        _firstNonEmptyString([
              d['name'],
              d['drug_name'],
              d['drugName'],
              d['title'],
              nestedMap?['name'],
            ]) ??
            'Unknown drug';

    final imageUrl =
        _firstNonEmptyString([
              d['image'],
              d['image_url'],
              d['imageUrl'],
              d['photo'],
              d['photo_url'],
              nestedMap?['image_url'],
              nestedMap?['image'],
            ]) ??
        '';

    final locationLabel =
        _firstNonEmptyString([
              d['location'],
              d['city'],
              d['branch_name'],
              d['branchName'],
              d['address'],
              d['region'],
            ]) ??
        '';

    String resolveId() {
      for (final key in ['id', 'drug_id', 'branch_drug_id']) {
        final v = d[key];
        if (v != null && v.toString().isNotEmpty) return v.toString();
      }
      return name;
    }

    final id = resolveId();

    final discountPct = _asInt(
      d['discount_percent'] ?? d['discountPercent'] ?? d['discount'],
    );

    return DrugModel(
      id: id,
      name: name,
      price: priceNum(),
      originalPrice: originalNum(),
      discountPercent: discountPct,
      imageUrl: imageUrl,
      locationLabel: locationLabel,
    );
  }
}
