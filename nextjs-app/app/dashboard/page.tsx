'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useAuth } from '@/contexts/AuthContext';
import ProtectedRoute from '@/components/ProtectedRoute';
import BottomNavigation from '@/components/BottomNavigation';
import Sidebar from '@/components/Sidebar';

export default function DashboardPage() {
  const { vendorData } = useAuth();
  const [sidebarOpen, setSidebarOpen] = useState(false);

  const menuItems = [
    { href: '/orders', label: 'Orders', icon: 'cart' },
    { href: '/wallet', label: 'Wallet', icon: 'wallet' },
    { href: '/products', label: 'Products', icon: 'products' },
    { href: '/stock', label: 'Stock Management', icon: 'inventory' },
  ];

  const getIcon = (icon: string) => {
    switch (icon) {
      case 'cart':
        return (
          <svg className="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
          </svg>
        );
      case 'wallet':
        return (
          <svg className="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z" />
          </svg>
        );
      case 'products':
        return (
          <svg className="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
          </svg>
        );
      case 'inventory':
        return (
          <svg className="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01" />
          </svg>
        );
      default:
        return null;
    }
  };

  return (
    <ProtectedRoute>
      <div className="min-h-screen bg-gray-50 pb-20">
        {/* Header */}
        <header className="bg-primary text-white p-4 flex items-center justify-between">
          <button
            onClick={() => setSidebarOpen(true)}
            className="p-2 hover:bg-white/10 rounded-lg"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>
          <div>
            <h1 className="text-xl font-bold">{vendorData?.shopName || 'Guest'}</h1>
          </div>
          <div className="w-10"></div>
        </header>

        <Sidebar isOpen={sidebarOpen} onClose={() => setSidebarOpen(false)} />

        {/* Add Product Button */}
        <div className="p-4">
          <Link
            href="/products/upload"
            className="block w-full py-4 bg-primary text-white text-center font-bold rounded-2xl hover:bg-primary-dark transition-colors"
          >
            Add Product
          </Link>
        </div>

        {/* Stats/Graph Placeholder */}
        <div className="mx-4 bg-white rounded-2xl p-6 shadow-sm">
          <h2 className="text-lg font-semibold text-primary mb-4">Upload Statistics</h2>
          <div className="h-40 bg-light-bg rounded-xl flex items-center justify-center text-gray-500">
            <div className="text-center">
              <svg className="w-12 h-12 mx-auto text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
              </svg>
              <p className="mt-2">Upload products to see statistics</p>
            </div>
          </div>
        </div>

        {/* Menu Grid */}
        <div className="p-4 grid grid-cols-2 gap-4">
          {menuItems.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="bg-primary rounded-2xl p-6 flex flex-col items-center justify-center hover:bg-primary-dark transition-colors"
            >
              {getIcon(item.icon)}
              <span className="mt-3 text-white font-medium">{item.label}</span>
            </Link>
          ))}
        </div>

        {/* Quick Stats */}
        <div className="px-4 grid grid-cols-2 gap-4">
          <div className="bg-white rounded-2xl p-4 shadow-sm">
            <div className="text-gray-500 text-sm">Total Products</div>
            <div className="text-2xl font-bold text-primary">0</div>
          </div>
          <div className="bg-white rounded-2xl p-4 shadow-sm">
            <div className="text-gray-500 text-sm">Pending Orders</div>
            <div className="text-2xl font-bold text-accent">0</div>
          </div>
        </div>

        <BottomNavigation />
      </div>
    </ProtectedRoute>
  );
}
