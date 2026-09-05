# Kopi Rakyat

Flutter implementation of the `Kopi Rakyat App.dc.html` Claude Design handoff — an 11-screen
coffee-shop ordering app (onboarding, home, menu, product customization, cart, checkout,
order tracking, merch/loyalty, store locator, profile, QR table scan), backed by Supabase.

## Setup

1. Set up the backend first — see `../supabase/README.md` (schema, seed data, phone auth).
2. Install dependencies: `flutter pub get`
3. Run with your Supabase credentials:

   ```
   flutter run \
     --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
   ```

   Without these, the app shows a setup prompt instead of starting (see `lib/env.dart`).

## Architecture

- **State**: Riverpod. `CartController` (`lib/state/cart_controller.dart`) holds the cart and
  checkout selections client-side, only touching Supabase once at checkout
  (`OrderRepository.placeOrder`, via the `place_order` RPC). `ProfileController` mirrors the
  signed-in user's loyalty profile (tier/points/stamps).
- **Auth**: phone OTP for real accounts, Supabase anonymous sign-in for "Lanjut sebagai guest" —
  guests still get a real backend identity, and `AuthRepository.sendOtp`/`verifyOtp` link that
  same identity to a phone number on upgrade instead of starting over.
- **Payments**: simulated today (`SimulatedPaymentGateway`), behind a `PaymentGateway` interface
  so a real gateway (Midtrans/Xendit) can be swapped in later without touching checkout UI.
- **Design tokens**: `lib/theme/tokens.dart` (colors/radius/spacing) and
  `lib/theme/batik_pattern.dart` (the mega-mendung screen texture), ported 1:1 from the prototype.
- **Promotional copy** (`lib/data/catalog_meta.dart`): the "Spesial Hari Ini"/"Promo & Combo"/
  category-tab groupings are curated display copy over the real `products` catalog, matching how
  the prototype itself hardcodes them — not modeled as backend tables.
- Product photography wasn't part of the handoff, so images are rendered as neutral placeholder
  tiles (`PhotoSlot`) — the prototype's own "drop slot" concept — ready to wire up to
  `image_url` once real photos exist.

## Verified

- `flutter analyze` — no issues.
- `flutter test` — passes.
- `flutter build web` — compiles.

Not verified: a live run against a real Supabase project/device (this sandbox has no Supabase
project to point at), and Android/iOS builds (no Android SDK / Xcode toolchain available here).
