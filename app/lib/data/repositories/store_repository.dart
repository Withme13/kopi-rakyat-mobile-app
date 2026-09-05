import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/store.dart';

class StoreRepository {
  StoreRepository(this._client);

  final SupabaseClient _client;

  Future<List<Store>> fetchStores() async {
    final rows = await _client.from('stores').select().order('sort_order');
    return rows.map((r) => Store.fromMap(r)).toList();
  }
}
