import Link from 'next/link';

const stats = [
  { label: 'Produk', value: '184' },
  { label: 'Order Hari Ini', value: '142' },
  { label: 'Pendapatan', value: 'Rp 18,6M' },
  { label: 'Promo Aktif', value: '12' },
];

const recentOrders = [
  { id: 'ORD-1024', customer: 'Rina', total: 'Rp 58.000', status: 'Ready' },
  { id: 'ORD-1025', customer: 'Budi', total: 'Rp 42.000', status: 'Preparing' },
  { id: 'ORD-1026', customer: 'Sinta', total: 'Rp 76.000', status: 'Completed' },
];

export default function Page() {
  return (
    <div className="dashboard-shell">
      <aside className="sidebar">
        <h2>Kopi Rakyat</h2>
        <nav>
          <Link href="/">Dashboard</Link>
          <Link href="/products">Produk</Link>
          <Link href="/orders">Order</Link>
          <Link href="/promos">Promo</Link>
          <Link href="/stores">Toko</Link>
          <Link href="/settings">Pengaturan</Link>
        </nav>
      </aside>

      <main className="main">
        <div className="container">
          <h1>Dashboard Admin</h1>
          <div className="grid" style={{ marginTop: 20 }}>
            {stats.map((item) => (
              <div key={item.label} className="card">
                <div style={{ color: '#64748b', fontSize: 13 }}>{item.label}</div>
                <h3 style={{ margin: '10px 0 0', fontSize: 30 }}>{item.value}</h3>
              </div>
            ))}
          </div>

          <div className="card" style={{ marginTop: 24 }}>
            <div className="row" style={{ justifyContent: 'space-between', marginBottom: 12 }}>
              <h3 style={{ margin: 0 }}>Order Terbaru</h3>
              <button className="btn secondary">Lihat semua</button>
            </div>

            <table className="table">
              <thead>
                <tr>
                  <th>ID Order</th>
                  <th>Pelanggan</th>
                  <th>Total</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                {recentOrders.map((order) => (
                  <tr key={order.id}>
                    <td>{order.id}</td>
                    <td>{order.customer}</td>
                    <td>{order.total}</td>
                    <td><span className="badge">{order.status}</span></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </main>
    </div>
  );
}
