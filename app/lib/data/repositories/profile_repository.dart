import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/profile.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<Profile?> fetchMine(String userId) async {
    final row = await _client.from('profiles').select().eq('id', userId).maybeSingle();
    return row == null ? null : Profile.fromMap(row);
  }

  Future<void> setBiometricEnabled(String userId, bool enabled) async {
    await _client.from('profiles').update({'biometric_enabled': enabled}).eq('id', userId);
  }
}
