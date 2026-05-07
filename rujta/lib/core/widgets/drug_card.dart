import 'package:flutter/material.dart';
import 'package:Rujta/core/constants.dart';
import 'package:Rujta/models/drug_model.dart';


class DrugCard extends StatelessWidget {
  const DrugCard({super.key, required this.drug});

  final DrugModel drug;

  String _priceLabel(double p) =>
      '${p % 1 == 0 ? p.toStringAsFixed(0) : p.toStringAsFixed(2)} EGP';

  @override
  Widget build(BuildContext context) {
    final original =
        drug.originalPrice != null && drug.originalPrice! > drug.price
            ? drug.originalPrice!
            : null;

    int? badgePct = drug.discountPercent;
    if (badgePct == null && original != null && original > drug.price) {
      badgePct = (((original - drug.price) / original) * 100)
          .round()
          .clamp(1, 99);
    }

    final showDiscountRow =
        (badgePct != null && badgePct > 0) || original != null;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(13)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: drug.imageUrl.isNotEmpty
                      ? Image.network(
                          drug.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _medicationPlaceholder(),
                        )
                      : _medicationPlaceholder(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drug.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _priceLabel(drug.price),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (showDiscountRow) ...[
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (badgePct != null && badgePct > 0) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE9E9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$badgePct%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFE53935),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (original != null)
                            Expanded(
                              child: Text(
                                _priceLabel(original),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            drug.locationLabel.isNotEmpty
                                ? drug.locationLabel
                                : '—',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
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
        ),
      ),
    );
  }

  Widget _medicationPlaceholder() {
    return Container(
      color: const Color(0xFFF5F5F7),
      child: Center(
        child: Icon(
          Icons.medication_outlined,
          size: 40,
          color: kMainColor.withOpacity(0.85),
        ),
      ),
    );
  }
}
