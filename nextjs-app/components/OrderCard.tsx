'use client';

import { Order } from '@/hooks/useOrders';

interface OrderCardProps {
  order: Order;
}

export default function OrderCard({ order }: OrderCardProps) {
  const formatDate = (date: Date) => {
    return new Intl.DateTimeFormat('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    }).format(date);
  };

  return (
    <div className="bg-white rounded-lg shadow-md p-4 mb-4">
      <div className="flex justify-between items-start mb-3">
        <div>
          <p className="text-sm text-gray-500">Order ID</p>
          <p className="font-medium text-primary">{order.id.slice(0, 8)}...</p>
        </div>
        <div className="text-right">
          <p className="text-sm text-gray-500">Date</p>
          <p className="text-sm">{formatDate(order.orderDate)}</p>
        </div>
      </div>

      <div className="border-t pt-3">
        {order.items.map((item, index) => (
          <div key={index} className="flex justify-between items-center py-2">
            <div className="flex-1">
              <p className="font-medium">{item.productName}</p>
              <p className="text-sm text-gray-500">Qty: {item.quantity}</p>
            </div>
            <div className="text-right">
              <p className="font-bold text-primary">${item.price.toFixed(2)}</p>
              <span className={`inline-block px-2 py-1 text-xs rounded ${
                item.status === 'completed' ? 'bg-green-100 text-green-800' :
                item.status === 'on the way' ? 'bg-blue-100 text-blue-800' :
                'bg-yellow-100 text-yellow-800'
              }`}>
                {item.status}
              </span>
            </div>
          </div>
        ))}
      </div>

      {order.shippingAddress && (
        <div className="border-t pt-3 mt-3">
          <p className="text-sm text-gray-500">Shipping Address</p>
          <p className="text-sm">{order.shippingAddress}</p>
        </div>
      )}
    </div>
  );
}
