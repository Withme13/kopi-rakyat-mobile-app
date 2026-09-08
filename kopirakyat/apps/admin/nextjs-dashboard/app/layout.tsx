import './globals.css';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Kopi Rakyat Admin',
  description: 'Dashboard admin kopi rakyat',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="id">
      <body>{children}</body>
    </html>
  );
}
