import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/profile.dart';
import '../../models/reward.dart';

class RewardRepository {
  RewardRepository(this._client);

  final SupabaseClient _client;

  Future<List<Reward>> fetchRewards() async {
    final rows = await _client.from('rewards').select().eq('active', true).order('sort_order');
    return rows.map((r) => Reward.fromMap(r)).toList();
  }

  /// Deducts stamps and logs the redemption via the `redeem_reward` RPC,
  /// which enforces the stamp balance server-side. Returns the updated profile.
  Future<Profile> redeem(String rewardId) async {
    final row = await _client.rpc('redeem_reward', params: {'p_reward_id': rewardId});
    return Profile.fromMap(row as Map<String, dynamic>);
  }
}
