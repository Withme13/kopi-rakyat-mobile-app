import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/option.dart';
import '../../models/product.dart';

/// Backed by the POS's real `menus`/`menu_categories` tables — the
/// prototype's `products`/`option_groups`/`option_values` schema was never
/// built on any Supabase project, so those calls always failed.
class ProductRepository {
  ProductRepository(this._client);

  final SupabaseClient _client;
  static const _queryTimeout = Duration(seconds: 12);

  Future<List<Product>> fetchDrinks() async {
    try {
      final rows = await _client
          .from('menus')
          .select('*, menu_categories(name)')
          .eq('is_active', true)
          .timeout(_queryTimeout);
      return rows.map((r) => Product.fromMenuMap(r)).toList();
    } on TimeoutException {
      throw Exception('Koneksi ke server terlalu lama saat memuat menu minuman');
    }
  }

  // The POS doesn't distinguish drinks/merch — there's no merch catalog yet.
  Future<List<Product>> fetchMerch() async => const [];

  // No option-group/customization schema exists on the POS side yet.
  Future<List<OptionGroup>> fetchOptionGroups() async => const [];
}
