import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/voucher.dart';

class VoucherRepository {
  VoucherRepository(this._client);

  final SupabaseClient _client;

  Future<List<Voucher>> fetchActiveVouchers() async {
    final rows = await _client.from('vouchers').select().eq('active', true);
    return rows.map((r) => Voucher.fromMap(r)).toList();
  }

  Future<Voucher?> findByCode(String code) async {
    final row = await _client
        .from('vouchers')
        .select()
        .eq('active', true)
        .ilike('code', code)
        .maybeSingle();
    return row == null ? null : Voucher.fromMap(row);
  }

  Future<void> claim(String userId, String voucherId) async {
    await _client.from('user_vouchers').upsert({
      'user_id': userId,
      'voucher_id': voucherId,
    }, onConflict: 'user_id,voucher_id');
  }
}
