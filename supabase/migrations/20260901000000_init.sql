-- Kopi Rakyat schema
-- Mirrors the dummy data model from `project/Kopi Rakyat App.dc.html`:
-- menu items with size/milk/ice/sugar options, merch, stores, vouchers,
-- loyalty stamps/points, and orders across 4 fulfilment modes.

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------
-- Profiles (one row per auth.users id; guests never get a row here)
-- ---------------------------------------------------------------------
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null default 'Pengguna',
  phone text,
  avatar_url text,
  tier text not null default 'Silver' check (tier in ('Silver', 'Gold')),
  points integer not null default 1200,
  stamps integer not null default 6 check (stamps between 0 and 10),
  biometric_enabled boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "profiles are self-readable" on public.profiles
  for select using (auth.uid() = id);
create policy "profiles are self-updatable" on public.profiles
  for update using (auth.uid() = id);
create policy "profiles are self-insertable" on public.profiles
  for insert with check (auth.uid() = id);

create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, phone)
  values (new.id, new.phone);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ---------------------------------------------------------------------
-- Stores
-- ---------------------------------------------------------------------
create table public.stores (
  id uuid primary key default gen_random_uuid(),
  key text unique not null,
  name text not null,
  address text not null,
  distance_km numeric(4, 1),
  is_open boolean not null default true,
  hours_note text not null,
  map_x numeric(4, 1) not null, -- percentage position on the locator placeholder map
  map_y numeric(4, 1) not null,
  sort_order integer not null default 0
);

alter table public.stores enable row level security;
create policy "stores are publicly readable" on public.stores for select using (true);

-- ---------------------------------------------------------------------
-- Categories & products (drinks + merch share one catalog)
-- ---------------------------------------------------------------------
create table public.categories (
  id uuid primary key default gen_random_uuid(),
  key text unique not null,
  name text not null,
  sort_order integer not null default 0
);

alter table public.categories enable row level security;
create policy "categories are publicly readable" on public.categories for select using (true);

create table public.products (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name text not null,
  kind text not null check (kind in ('drink', 'merch')),
  category_id uuid references public.categories (id),
  base_price integer not null,
  description text not null default '',
  origin text not null default '',
  badge text,
  image_url text,
  active boolean not null default true,
  sort_order integer not null default 0
);

alter table public.products enable row level security;
create policy "products are publicly readable" on public.products for select using (true);

-- Global customization options for drinks (size / milk / ice / sugar).
create table public.option_groups (
  id uuid primary key default gen_random_uuid(),
  key text unique not null, -- size | milk | ice | sugar
  label text not null,
  sort_order integer not null default 0
);

create table public.option_values (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.option_groups (id) on delete cascade,
  key text not null, -- e.g. 'M', 'Oat', 'Sedikit'
  sub_label text not null default '',
  price_delta integer not null default 0,
  sort_order integer not null default 0,
  unique (group_id, key)
);

alter table public.option_groups enable row level security;
alter table public.option_values enable row level security;
create policy "option groups are publicly readable" on public.option_groups for select using (true);
create policy "option values are publicly readable" on public.option_values for select using (true);

-- ---------------------------------------------------------------------
-- Vouchers (promo codes + claimable loyalty vouchers)
-- ---------------------------------------------------------------------
create table public.vouchers (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  title text not null,
  note text not null default '',
  discount_type text not null check (discount_type in ('percent', 'fixed')),
  discount_value numeric not null,
  scope text not null default 'cart' check (scope in ('cart', 'merch')),
  valid_until date,
  active boolean not null default true
);

alter table public.vouchers enable row level security;
create policy "vouchers are publicly readable" on public.vouchers for select using (true);

create table public.user_vouchers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  voucher_id uuid not null references public.vouchers (id),
  claimed_at timestamptz not null default now(),
  used_at timestamptz,
  unique (user_id, voucher_id)
);

alter table public.user_vouchers enable row level security;
create policy "users manage their own claimed vouchers" on public.user_vouchers
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ---------------------------------------------------------------------
-- Addresses (delivery mode)
-- ---------------------------------------------------------------------
create table public.addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  label text not null default 'Rumah',
  recipient text not null,
  line1 text not null,
  city text not null default 'Jakarta Selatan',
  is_default boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.addresses enable row level security;
create policy "users manage their own addresses" on public.addresses
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ---------------------------------------------------------------------
-- Rewards (stamp-card redemptions)
-- ---------------------------------------------------------------------
create table public.rewards (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  stamps_cost integer not null,
  active boolean not null default true,
  sort_order integer not null default 0
);

alter table public.rewards enable row level security;
create policy "rewards are publicly readable" on public.rewards for select using (true);

-- ---------------------------------------------------------------------
-- Orders
-- ---------------------------------------------------------------------
create table public.orders (
  id uuid primary key default gen_random_uuid(),
  order_no text unique not null,
  user_id uuid references auth.users (id) on delete set null,
  store_id uuid references public.stores (id),
  fulfilment_mode text not null check (fulfilment_mode in ('delivery', 'pickup', 'dine_in', 'pre_order')),
  table_number text,
  address_id uuid references public.addresses (id),
  scheduled_for timestamptz,
  payment_method text not null,
  payment_provider text not null default 'simulated',
  payment_status text not null default 'pending' check (payment_status in ('pending', 'paid', 'failed')),
  subtotal integer not null,
  discount integer not null default 0,
  delivery_fee integer not null default 0,
  total integer not null,
  voucher_code text,
  status text not null default 'received' check (status in ('received', 'preparing', 'on_the_way', 'ready', 'completed')),
  stage integer not null default 0,
  pickup_code text,
  created_at timestamptz not null default now(),
  paid_at timestamptz
);

alter table public.orders enable row level security;
create policy "users manage their own orders" on public.orders
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create table public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_id uuid references public.products (id),
  name_snapshot text not null,
  size text,
  milk text,
  ice text,
  sugar text,
  extra_shot boolean not null default false,
  note text,
  unit_price integer not null,
  qty integer not null default 1,
  line_total integer not null
);

alter table public.order_items enable row level security;
create policy "users manage their own order items" on public.order_items
  for all using (
    exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid())
  ) with check (
    exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid())
  );

-- ---------------------------------------------------------------------
-- Loyalty ledger (stamps + points history, driven by paid orders / redemptions)
-- ---------------------------------------------------------------------
create table public.loyalty_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  order_id uuid references public.orders (id),
  reward_id uuid references public.rewards (id),
  delta_stamps integer not null default 0,
  delta_points integer not null default 0,
  reason text not null,
  created_at timestamptz not null default now()
);

alter table public.loyalty_ledger enable row level security;
create policy "users read their own loyalty ledger" on public.loyalty_ledger
  for select using (auth.uid() = user_id);
create policy "users insert their own loyalty ledger" on public.loyalty_ledger
  for insert with check (auth.uid() = user_id);

-- ---------------------------------------------------------------------
-- RPCs used by the app instead of raw multi-table writes from the client
-- ---------------------------------------------------------------------

-- Places an order with its line items in one transaction, marks payment as
-- paid via the given provider (simulated today, a real gateway later),
-- and grants +1 loyalty stamp / points. Returns the new order row.
create function public.place_order(
  p_store_id uuid,
  p_fulfilment_mode text,
  p_table_number text,
  p_address_id uuid,
  p_scheduled_for timestamptz,
  p_payment_method text,
  p_payment_provider text,
  p_subtotal integer,
  p_discount integer,
  p_delivery_fee integer,
  p_total integer,
  p_voucher_code text,
  p_items jsonb -- array of {product_id, name_snapshot, size, milk, ice, sugar, extra_shot, note, unit_price, qty, line_total}
) returns public.orders
language plpgsql
security definer set search_path = public
as $$
declare
  v_order public.orders;
  v_item jsonb;
  v_order_no text;
  v_pickup_code text;
begin
  if auth.uid() is null then
    raise exception 'Must be signed in to place an order';
  end if;

  v_order_no := '#KR-' || to_char(nextval('public.order_no_seq'), 'FM0000');
  v_pickup_code := chr(65 + (random() * 25)::int) || '-' || lpad((floor(random() * 99))::text, 2, '0');

  insert into public.orders (
    order_no, user_id, store_id, fulfilment_mode, table_number, address_id,
    scheduled_for, payment_method, payment_provider, payment_status,
    subtotal, discount, delivery_fee, total, voucher_code, status, stage,
    pickup_code, paid_at
  ) values (
    v_order_no, auth.uid(), p_store_id, p_fulfilment_mode, p_table_number, p_address_id,
    p_scheduled_for, p_payment_method, p_payment_provider, 'paid',
    p_subtotal, p_discount, p_delivery_fee, p_total, p_voucher_code, 'received', 0,
    v_pickup_code, now()
  ) returning * into v_order;

  for v_item in select * from jsonb_array_elements(p_items) loop
    insert into public.order_items (
      order_id, product_id, name_snapshot, size, milk, ice, sugar,
      extra_shot, note, unit_price, qty, line_total
    ) values (
      v_order.id,
      nullif(v_item ->> 'product_id', '')::uuid,
      v_item ->> 'name_snapshot',
      v_item ->> 'size', v_item ->> 'milk', v_item ->> 'ice', v_item ->> 'sugar',
      coalesce((v_item ->> 'extra_shot')::boolean, false),
      v_item ->> 'note',
      (v_item ->> 'unit_price')::integer,
      (v_item ->> 'qty')::integer,
      (v_item ->> 'line_total')::integer
    );
  end loop;

  update public.profiles
    set stamps = least(10, stamps + 1), points = points + greatest(0, p_total / 1000)
    where id = auth.uid();

  insert into public.loyalty_ledger (user_id, order_id, delta_stamps, delta_points, reason)
  values (auth.uid(), v_order.id, 1, greatest(0, p_total / 1000), 'Pesanan ' || v_order_no);

  return v_order;
end;
$$;

create sequence public.order_no_seq start 4471;

-- Advances a tracking order to the next stage (used by the client-side
-- auto-advance timer so state survives app restarts).
create function public.advance_order_stage(p_order_id uuid)
returns public.orders
language plpgsql
security definer set search_path = public
as $$
declare
  v_order public.orders;
begin
  select * into v_order from public.orders where id = p_order_id and user_id = auth.uid();
  if not found then
    raise exception 'Order not found';
  end if;
  update public.orders
    set stage = least(3, stage + 1),
        status = case least(3, stage + 1)
          when 1 then 'preparing'
          when 2 then case fulfilment_mode when 'delivery' then 'on_the_way' else 'ready' end
          when 3 then 'completed'
          else status
        end
    where id = p_order_id
    returning * into v_order;
  return v_order;
end;
$$;

-- Redeems a stamp-card reward: deducts stamps and issues a one-time voucher.
create function public.redeem_reward(p_reward_id uuid)
returns public.profiles
language plpgsql
security definer set search_path = public
as $$
declare
  v_reward public.rewards;
  v_profile public.profiles;
begin
  select * into v_reward from public.rewards where id = p_reward_id and active;
  if not found then
    raise exception 'Reward not found';
  end if;

  select * into v_profile from public.profiles where id = auth.uid() for update;
  if v_profile.stamps < v_reward.stamps_cost then
    raise exception 'Not enough stamps';
  end if;

  update public.profiles set stamps = stamps - v_reward.stamps_cost
    where id = auth.uid() returning * into v_profile;

  insert into public.loyalty_ledger (user_id, reward_id, delta_stamps, reason)
  values (auth.uid(), p_reward_id, -v_reward.stamps_cost, 'Tukar: ' || v_reward.name);

  return v_profile;
end;
$$;
