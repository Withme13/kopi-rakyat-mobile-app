import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/option.dart';
import '../../models/product.dart';

class ProductRepository {
  ProductRepository(this._client);

  final SupabaseClient _client;

  Future<List<Product>> fetchDrinks() async {
    final rows = await _client
        .from('products')
        .select('*, categories(key)')
        .eq('kind', 'drink')
        .eq('active', true)
        .order('sort_order');
    return rows.map((r) => Product.fromMap(r)).toList();
  }

  Future<List<Product>> fetchMerch() async {
    final rows = await _client
        .from('products')
        .select('*, categories(key)')
        .eq('kind', 'merch')
        .eq('active', true)
        .order('sort_order');
    return rows.map((r) => Product.fromMap(r)).toList();
  }

  Future<List<OptionGroup>> fetchOptionGroups() async {
    final groups = await _client.from('option_groups').select().order('sort_order');
    final values = await _client.from('option_values').select().order('sort_order');
    return (groups as List).map((g) {
      final groupValues = (values as List)
          .where((v) => v['group_id'] == g['id'])
          .map((v) => OptionValue.fromMap(v as Map<String, dynamic>))
          .toList();
      return OptionGroup(key: g['key'] as String, label: g['label'] as String, values: groupValues);
    }).toList();
  }
}
