# Kopi Rakyat Monorepo

Struktur monorepo untuk aplikasi customer, dashboard admin, dan backend POS.

## Struktur

- `apps/mobile/flutter-app` — aplikasi mobile Flutter customer
- `apps/admin/nextjs-dashboard` — dashboard admin untuk mengelola produk, kategori, promo, banner, dan toko
- `apps/pos/pos-backend` — backend API POS untuk menerima order dari mobile dan mengelola transaksi kasir
- `packages/shared-types` — DTO / contract API yang dipakai bersama
- `packages/ui-kit` — komponen reusable UI antar aplikasi
- `docs` — dokumen API, schema database, dan keamanan

## Workflow

1. Admin mengelola produk di dashboard admin.
2. Data disimpan di Supabase / database utama.
3. Mobile app membaca data secara dinamis.
4. Saat checkout, mobile app mengirim order ke API POS.
5. POS backend memproses transaksi dan menampilkan order di web POS.

## Mulai

```bash
npm install
```

Detail per aplikasi bisa dilihat di README masing-masing folder.
