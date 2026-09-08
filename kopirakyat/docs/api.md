# API Contract

## Base URL

```text
https://api.example.com
```

## Endpoints

### GET /api/products
Mengambil daftar produk aktif.

### GET /api/stores
Mengambil daftar toko.

### GET /api/promos
Mengambil promo aktif.

### POST /api/orders
Menerima order dari mobile app untuk diproses di POS.

### GET /api/orders/:id
Mendapatkan detail order.

### PATCH /api/orders/:id/status
Update status order.

## Payload order

```json
{
  "source": "mobile_app",
  "order_id": "ORD-20260908-001",
  "customer_id": "cust_123",
  "store_id": "store_001",
  "fulfilment_mode": "pickup",
  "table_number": null,
  "payment_method": "QRIS",
  "subtotal": 64000,
  "discount": 5000,
  "delivery_fee": 0,
  "total": 59000,
  "items": [
    {
      "product_id": "P001",
      "product_name": "Espresso",
      "qty": 2,
      "price": 15000
    }
  ]
}
```
