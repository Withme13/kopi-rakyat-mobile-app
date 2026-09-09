import '../../models/store.dart';

/// The POS has no `stores` table — it's a single physical location. Return
/// one hardcoded store instead of querying a table that doesn't exist.
/// `key` must stay 'Kemang' to match `CartState`'s default `storeKey`.
class StoreRepository {
  Future<List<Store>> fetchStores() async => const [
        Store(
          id: 'store-kemang',
          key: 'Kemang',
          name: 'Kopi Rakyat Kemang',
          address: 'Jl. Kemang Raya, Jakarta Selatan',
          distanceKm: 0.0,
          isOpen: true,
          hoursNote: '07.00 - 22.00',
          mapX: 50,
          mapY: 50,
        ),
      ];
}
