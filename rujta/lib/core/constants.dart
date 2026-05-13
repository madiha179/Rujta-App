import 'package:flutter/material.dart';

const kMainColor = Color(0xFF69A03A);
const subtitleColor = Color(0xFF7D848D);

/// If the drugs-by-location response has **no** `branch_id`, set this to a real
/// pharmacy branch id (from DB) so POST `/api/v1/cart` works until the API is fixed.
/// The app also saves `cart_cached_branch_id` in secure storage when it finds any
/// branch-like field anywhere in the drugs JSON (see `DrugStoreHomeViewModel`).
/// Example: `const int? kFallbackCartBranchId = 2;`
const int? kFallbackCartBranchId = null;