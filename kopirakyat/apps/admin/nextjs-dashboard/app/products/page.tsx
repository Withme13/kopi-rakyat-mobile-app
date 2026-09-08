const products = [
  { id: 'P001', name: 'Espresso', price: 'Rp 15.000', stock: 24, status: 'Aktif' },
  { id: 'P002', name: 'Cappuccino', price: 'Rp 29.000', stock: 18, status: 'Aktif' },
  { id: 'P003', name: 'Matcha Latte', price: 'Rp 32.000', stock: 12, status: 'Draft' },
];

export default function ProductsPage() {
  return (
    <main className="container" style={{ paddingTop: 40 }}>
      <div className="row" style={{ justifyContent: 'space-between', marginBottom: 18 }}>
        <h1 style={{ margin: 0 }}>Manajemen Produk</h1>
        <button className="btn">Tambah Produk</button>
      </div>

      <div className="card">
        <table className="table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Nama</th>
              <th>Harga</th>
              <th>Stok</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            {products.map((product) => (
              <tr key={product.id}>
                <td>{product.id}</td>
                <td>{product.name}</td>
                <td>{product.price}</td>
                <td>{product.stock}</td>
                <td><span className="badge">{product.status}</span></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </main>
  );
}
