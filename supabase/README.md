# Kopi Rakyat — Supabase backend

## Setup

1. Create a Supabase project (or run `supabase start` locally with the Supabase CLI).
2. Apply the schema: `supabase db push` (or run `migrations/20260901000000_init.sql` in the SQL editor).
3. Insert your own data manually (the default `seed.sql` is intentionally empty).
4. Enable **Phone** auth under Authentication → Providers, and configure an SMS provider (Twilio, MessageBird, Vonage) to actually deliver OTP codes. Until a provider is configured, use the "Lanjut sebagai guest" flow.
5. Copy the project URL and anon key into `app/.env` (see `app/.env.example`).

## Design notes

- `size` / `milk` / `ice` / `sugar` options are global option groups shared by every drink, matching the prototype (not per-product).
- Cart state lives client-side in the Flutter app; nothing is written to Supabase until checkout, when `place_order()` atomically creates the order + line items, marks it paid (via whatever `payment_provider` the client passed — `simulated` today), and grants +1 loyalty stamp.
- `advance_order_stage()` and `redeem_reward()` are the only other writes the client makes to loyalty/order state, keeping business rules (stamp math, stage transitions) server-side rather than trusting the client.
- Payments are simulated: `place_order` always marks `payment_status = 'paid'`. Swapping in a real gateway later means calling the gateway before `place_order`, or adding a `payment_status = 'pending'` path plus a webhook that flips it to `paid'` — the client's `PaymentGateway` interface (`app/lib/data/repositories/payment_gateway.dart`) is already split out for that.
