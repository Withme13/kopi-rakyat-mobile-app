import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../models/profile.dart';

/// Signed-in users' loyalty profile (tier/points/stamps). Guests have no
/// row and stay `null`, matching the prototype's guest-vs-signed-in split.
class ProfileController extends StateNotifier<AsyncValue<Profile?>> {
  ProfileController(this._ref) : super(const AsyncValue.data(null)) {
    _ref.listen(currentUserProvider, (previous, next) => refresh(), fireImmediately: true);
  }

  final Ref _ref;

  Future<void> refresh() async {
    final user = _ref.read(currentUserProvider);
    if (user == null || user.isAnonymous) {
      state = const AsyncValue.data(null);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final profile = await _ref.read(profileRepositoryProvider).fetchMine(user.id);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(biometricEnabled: enabled));
    await _ref.read(profileRepositoryProvider).setBiometricEnabled(current.id, enabled);
  }

  Future<void> redeemReward(String rewardId, int stampsCost) async {
    final profile = await _ref.read(rewardRepositoryProvider).redeem(rewardId);
    state = AsyncValue.data(profile);
  }
}

final profileControllerProvider = StateNotifierProvider<ProfileController, AsyncValue<Profile?>>(
  (ref) => ProfileController(ref),
);
