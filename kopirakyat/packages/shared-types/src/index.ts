export type FulfilmentMode = 'pickup' | 'delivery' | 'dine_in' | 'preorder';

export interface ProductDto {
  id: string;
  name: string;
  slug: string;
  description?: string;
  price: number;
  imageUrl?: string;
  categoryId?: string;
  isActive: boolean;
  stock: number;
  createdAt?: string;
  updatedAt?: string;
}

export interface OrderItemDto {
  productId: string;
  productName: string;
  qty: number;
  price: number;
  notes?: string;
}

export interface CreateOrderRequestDto {
  source: 'mobile_app' | 'web_admin';
  orderId: string;
  customerId?: string;
  storeId: string;
  fulfilmentMode: FulfilmentMode;
  tableNumber?: string | null;
  paymentMethod: string;
  subtotal: number;
  discount: number;
  deliveryFee: number;
  total: number;
  items: OrderItemDto[];
}

export interface CreateOrderResponseDto {
  success: boolean;
  message: string;
  posOrderId?: string;
  status?: 'queued' | 'accepted' | 'rejected';
}
