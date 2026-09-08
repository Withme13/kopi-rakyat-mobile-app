# Security

## Prinsip dasar

- Mobile app tidak boleh memegang credential admin atau secret backend.
- Admin dashboard dan POS backend harus memiliki auth yang terpisah.
- Role-based access control harus diterapkan.
- Semua endpoint sensitif harus menggunakan HTTPS.
- Semua request ke API harus divalidasi.

## Recommended roles

- `customer`
- `admin`
- `cashier`
- `manager`

## RLS / ACL

- Customer hanya bisa membaca data user dan order miliknya.
- Admin bisa melakukan CRUD produk, promo, banner, toko.
- Cashier hanya bisa melihat dan mengubah order yang relevan.
- Manager bisa melihat laporan dan performa.
