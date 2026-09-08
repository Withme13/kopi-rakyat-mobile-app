import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const port = Number(process.env.PORT || 4000);

app.use(cors());
app.use(express.json());

const authMiddleware = (req, res, next) => {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.replace('Bearer ', '') : '';

  if (token !== process.env.POS_API_KEY) {
    return res.status(401).json({ success: false, message: 'Unauthorized' });
  }

  return next();
};

const orders = [];

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', service: 'kopi-rakyat-pos' });
});

app.get('/api/products', (req, res) => {
  res.json([
    { id: 'P001', name: 'Espresso', price: 15000, stock: 24, isActive: true },
    { id: 'P002', name: 'Cappuccino', price: 29000, stock: 18, isActive: true },
    { id: 'P003', name: 'Matcha Latte', price: 32000, stock: 12, isActive: true },
  ]);
});

app.post('/api/orders', authMiddleware, (req, res) => {
  const payload = req.body || {};

  if (!payload.order_id || !Array.isArray(payload.items) || payload.items.length === 0) {
    return res.status(400).json({
      success: false,
      message: 'Payload tidak valid',
      error_code: 'INVALID_REQUEST',
    });
  }

  const total = Number(payload.total || 0);
  const order = {
    id: `POS-${Date.now()}`,
    order_id: payload.order_id,
    customer_id: payload.customer_id || null,
    store_id: payload.store_id || null,
    fulfilment_mode: payload.fulfilment_mode || 'pickup',
    payment_method: payload.payment_method || 'QRIS',
    total,
    status: 'queued',
    created_at: new Date().toISOString(),
    items: payload.items,
  };

  orders.push(order);

  return res.status(201).json({
    success: true,
    message: 'Order berhasil dibuat',
    pos_order_id: order.id,
    status: 'queued',
  });
});

app.get('/api/orders', authMiddleware, (_req, res) => {
  res.json({ data: orders });
});

app.get('/api/orders/:id', authMiddleware, (req, res) => {
  const order = orders.find((item) => item.id === req.params.id);

  if (!order) {
    return res.status(404).json({ success: false, message: 'Order tidak ditemukan' });
  }

  return res.json({ success: true, data: order });
});

app.patch('/api/orders/:id/status', authMiddleware, (req, res) => {
  const { status } = req.body || {};
  const order = orders.find((item) => item.id === req.params.id);

  if (!order) {
    return res.status(404).json({ success: false, message: 'Order tidak ditemukan' });
  }

  order.status = status || order.status;

  return res.json({ success: true, message: 'Status berhasil diperbarui', data: order });
});

app.listen(port, () => {
  console.log(`POS backend running on http://localhost:${port}`);
});
