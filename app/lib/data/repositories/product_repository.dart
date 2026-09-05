import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/option.dart';
import '../../models/product.dart';

class ProductRepository {
  ProductRepository(this._client);

  final SupabaseClient _client;
  static const _queryTimeout = Duration(seconds: 12);

  Future<List<Product>> fetchDrinks() async {
    try {
      final rows = await _client
          .from('products')
          .select('*, categories(key)')
          .eq('kind', 'drink')
          .eq('active', true)
          .order('sort_order')
          .timeout(_queryTimeout);
      return rows.map((r) => Product.fromMap(r)).toList();
    } on TimeoutException {
      throw Exception('Koneksi ke server terlalu lama saat memuat menu minuman');
    }
  }

  Future<List<Product>> fetchMerch() async {
    try {
      final rows = await _client
          .from('products')
          .select('*, categories(key)')
          .eq('kind', 'merch')
          .eq('active', true)
          .order('sort_order')
          .timeout(_queryTimeout);
      return rows.map((r) => Product.fromMap(r)).toList();
    } on TimeoutException {
      throw Exception('Koneksi ke server terlalu lama saat memuat data merch');
    }
  }

  Future<List<OptionGroup>> fetchOptionGroups() async {
    try {
      final groups = await _client.from('option_groups').select().order('sort_order').timeout(_queryTimeout);
      final values = await _client.from('option_values').select().order('sort_order').timeout(_queryTimeout);
      return (groups as List).map((g) {
        final groupValues = (values as List)
            .where((v) => v['group_id'] == g['id'])
            .map((v) => OptionValue.fromMap(v as Map<String, dynamic>))
            .toList();
        return OptionGroup(key: g['key'] as String, label: g['label'] as String, values: groupValues);
      }).toList();
    } on TimeoutException {
      throw Exception('Koneksi ke server terlalu lama saat memuat opsi produk');
    }
  }
}
