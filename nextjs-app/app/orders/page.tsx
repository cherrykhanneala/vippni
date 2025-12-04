'use client';

import { useState } from 'react';
import ProtectedRoute from '@/components/ProtectedRoute';
import BottomNavigation from '@/components/BottomNavigation';
import OrderCard from '@/components/OrderCard';
import { useOrders } from '@/hooks/useOrders';

const tabs = [
  { value: 'Pending', label: 'Pending' },
  { value: 'on the way', label: 'On the Way' },
  { value: 'completed', label: 'Completed' },
];

export default function OrdersPage() {
  const [activeTab, setActiveTab] = useState('Pending');
  const { loading, getOrdersByStatus } = useOrders();
  
  const filteredOrders = getOrdersByStatus(activeTab);

  return (
    <ProtectedRoute>
      <div className="min-h-screen bg-gray-50 pb-20">
        {/* Header */}
        <header className="bg-primary text-white">
          <div className="p-4 flex items-center">
            <h1 className="text-lg font-bold">Orders</h1>
          </div>
          
          {/* Tabs */}
          <div className="flex">
            {tabs.map((tab) => (
              <button
                key={tab.value}
                onClick={() => setActiveTab(tab.value)}
                className={`flex-1 py-3 text-center font-medium border-b-2 transition-colors ${
                  activeTab === tab.value
                    ? 'border-white text-white'
                    : 'border-transparent text-white/60'
                }`}
              >
                {tab.label}
              </button>
            ))}
          </div>
        </header>

        {/* Orders List */}
        <div className="p-4">
          {loading ? (
            <div className="flex justify-center py-12">
              <div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin"></div>
            </div>
          ) : filteredOrders.length === 0 ? (
            <div className="text-center py-12">
              <svg className="w-16 h-16 mx-auto text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01" />
              </svg>
              <p className="mt-4 text-gray-500">No orders found.</p>
            </div>
          ) : (
            <div className="space-y-4">
              {filteredOrders.map((order) => (
                <OrderCard key={order.id} order={order} />
              ))}
            </div>
          )}
        </div>

        <BottomNavigation />
      </div>
    </ProtectedRoute>
  );
}
