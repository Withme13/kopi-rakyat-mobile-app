import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../env.dart';
import '../models/option.dart';
import '../models/product.dart';
import '../models/reward.dart';
import '../models/store.dart';
import '../models/voucher.dart';
import '../services/geocoding_service.dart';
import '../services/pos_api_service.dart';
import 'repositories/auth_repository.dart';
import 'repositories/order_repository.dart';
import 'repositories/payment_gateway.dart';
import 'repositories/product_repository.dart';
import 'repositories/profile_repository.dart';
import 'repositories/reward_repository.dart';
import 'repositories/store_repository.dart';
import 'repositories/voucher_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository(ref.watch(supabaseClientProvider)));
final productRepositoryProvider =
    Provider<ProductRepository>((ref) => ProductRepository(ref.watch(supabaseClientProvider)));
final storeRepositoryProvider = Provider<StoreRepository>((ref) => StoreRepository());
final voucherRepositoryProvider =
    Provider<VoucherRepository>((ref) => VoucherRepository(ref.watch(supabaseClientProvider)));
final rewardRepositoryProvider =
    Provider<RewardRepository>((ref) => RewardRepository(ref.watch(supabaseClientProvider)));
final profileRepositoryProvider =
    Provider<ProfileRepository>((ref) => ProfileRepository(ref.watch(supabaseClientProvider)));
final paymentGatewayProvider = Provider<PaymentGateway>((ref) => SimulatedPaymentGateway());
final geocodingServiceProvider = Provider<GeocodingService>((ref) => GeocodingService());
final posApiServiceProvider = Provider<PosApiService>(
  (ref) => PosApiService(baseUrl: Env.posBaseUrl, apiKey: Env.posApiKey),
);
final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepository(
    ref.watch(paymentGatewayProvider),
    ref.watch(posApiServiceProvider),
  ),
);

final authStateChangesProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(authRepositoryProvider).onAuthStateChange,
);

final currentUserProvider = Provider<User?>((ref) {
  final auth = ref.watch(authStateChangesProvider);
  return auth.maybeWhen(
    data: (state) => state.session?.user,
    orElse: () => ref.watch(authRepositoryProvider).currentUser,
  );
});

final isGuestProvider = Provider<bool>((ref) => ref.watch(currentUserProvider)?.isAnonymous ?? false);
final isSignedInProvider =
    Provider<bool>((ref) => ref.watch(currentUserProvider) != null && !ref.watch(isGuestProvider));

final drinksProvider =
    FutureProvider<List<Product>>((ref) => ref.watch(productRepositoryProvider).fetchDrinks());
final merchProvider =
    FutureProvider<List<Product>>((ref) => ref.watch(productRepositoryProvider).fetchMerch());
final optionGroupsProvider =
    FutureProvider<List<OptionGroup>>((ref) => ref.watch(productRepositoryProvider).fetchOptionGroups());
final storesProvider = FutureProvider<List<Store>>((ref) => ref.watch(storeRepositoryProvider).fetchStores());
final vouchersProvider =
    FutureProvider<List<Voucher>>((ref) => ref.watch(voucherRepositoryProvider).fetchActiveVouchers());
final rewardsProvider =
    FutureProvider<List<Reward>>((ref) => ref.watch(rewardRepositoryProvider).fetchRewards());
