/// Curated marketing copy (promo blurbs, category tab grouping) that the
/// prototype hardcodes client-side (`SPECIALS`, `PROMO_CARDS`, `GROUPS`,
/// `CATS`) rather than modeling as its own backend table — these are
/// display copy over the real `products` catalog, not transactional data.
class PromoCard {
  const PromoCard({required this.name, required this.priceLabel, required this.productSlug, this.sub});
  final String name;
  final String? sub;
  final String priceLabel;
  final String productSlug;
}

const categoryLabels = {
  'signature': 'Signature',
  'espresso': 'Espresso',
  'manual_brew': 'Manual Brew',
  'non_coffee': 'Non-Coffee',
  'snack': 'Snack',
};

const catFilters = ['Semua', 'Signature', 'Espresso', 'Manual Brew', 'Non-Coffee', 'Snack'];

const menuTabs = ['Promo & Combo', 'Baru!', 'Coffee', 'Non Coffee', 'Snack'];

const menuGroups = {
  'Coffee': ['signature', 'espresso', 'manual_brew'],
  'Non Coffee': ['non_coffee'],
  'Snack': ['snack'],
};

const specialsToday = [
  PromoCard(name: 'Roti Discount 20%', sub: 'Assorted pastry, panggang harian', priceLabel: 'Rp22.950', productSlug: 'croissant'),
  PromoCard(name: 'Beli 3 Hanya 47RB', sub: 'Trio es kopi susu signature', priceLabel: 'Rp47.000', productSlug: 'aren'),
  PromoCard(name: 'Paket Kerja Duo', sub: 'Dua kopi + banana bread', priceLabel: 'Rp58.000', productSlug: 'latte-aren'),
];

const promoCombo = [
  PromoCard(name: '2 Kopi Hanya 29rb', priceLabel: 'Rp29.900', productSlug: 'aren'),
  PromoCard(name: 'Beli 3 Hanya 47rb', priceLabel: 'Rp47.000', productSlug: 'pandan'),
  PromoCard(name: 'Beli 1 Gratis 1', priceLabel: 'Rp27.000', productSlug: 'latte-aren'),
];

const baruItem = PromoCard(name: 'Sweet Honey Soft Baked Cookie', priceLabel: 'Rp17.000', productSlug: 'croissant');
