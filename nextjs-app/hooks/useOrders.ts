'use client';

import { useState, useEffect, useCallback } from 'react';
import {
  collection,
  query,
  orderBy,
  getDocs,
} from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { useAuth } from '@/contexts/AuthContext';

export interface OrderItem {
  productId: string;
  productName: string;
  quantity: number;
  price: number;
  vendorId: string;
  status: string;
  imageUrl?: string;
}

export interface Order {
  id: string;
  orderDate: Date;
  items: OrderItem[];
  customerId: string;
  customerName?: string;
  shippingAddress?: string;
  totalAmount: number;
  paymentStatus?: string;
}

export function useOrders() {
  const { user } = useAuth();
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(false);

  const fetchOrders = useCallback(async () => {
    if (!user) return;

    setLoading(true);
    try {
      const q = query(
        collection(db, 'orders'),
        orderBy('orderDate', 'desc')
      );

      const snapshot = await getDocs(q);
      const allOrders = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
        orderDate: doc.data().orderDate?.toDate() || new Date(),
      })) as Order[];

      // Filter orders that have items for this vendor
      const vendorOrders = allOrders.filter((order) =>
        order.items?.some((item) => item.vendorId === user.uid)
      );

      setOrders(vendorOrders);
    } catch (error) {
      console.error('Error fetching orders:', error);
    } finally {
      setLoading(false);
    }
  }, [user]);

  const getOrdersByStatus = useCallback(
    (status: string) => {
      if (!user) return [];
      return orders
        .map((order) => ({
          ...order,
          items: order.items.filter(
            (item) => item.vendorId === user.uid && item.status === status
          ),
        }))
        .filter((order) => order.items.length > 0);
    },
    [orders, user]
  );

  useEffect(() => {
    if (user) {
      fetchOrders();
    }
  }, [user, fetchOrders]);

  return {
    orders,
    loading,
    fetchOrders,
    getOrdersByStatus,
  };
}
