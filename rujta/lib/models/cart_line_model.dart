/// One row in the shopping cart (UI + merge with API when available).
class CartLineModel {
  CartLineModel({
    required this.drugId,
    required this.name,
    required this.unitPrice,
    this.imageUrl = '',
    this.quantity = 1,
  });

  final String drugId;
  final String name;
  final double unitPrice;
  final String imageUrl;
  int quantity;

  double get lineTotal => unitPrice * quantity;
}
