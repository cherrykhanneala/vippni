'use client';

import { usePathname, useRouter } from 'next/navigation';
import { useAuth } from '@/contexts/AuthContext';
import { useState } from 'react';

const navItems = [
  { href: '/dashboard', label: 'Profile', icon: 'person' },
  { href: '/products', label: 'My Products', icon: 'inventory' },
  { href: '/orders', label: 'My Earnings', icon: 'monetization' },
  { href: '/notifications', label: 'Notifications', icon: 'notifications' },
];

export default function BottomNavigation() {
  const pathname = usePathname();
  const { vendorData } = useAuth();
  const router = useRouter();
  const [showToast, setShowToast] = useState(false);

  const handleNavClick = (href: string, e: React.MouseEvent) => {
    if (vendorData?.role !== 'seller' && href !== '/dashboard' && href !== '/notifications') {
      e.preventDefault();
      setShowToast(true);
      setTimeout(() => setShowToast(false), 3000);
      return;
    }
    router.push(href);
  };

  const getIcon = (icon: string, isActive: boolean) => {
    const color = isActive ? 'text-primary' : 'text-gray-500';
    switch (icon) {
      case 'person':
        return (
          <svg className={`w-6 h-6 ${color}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
          </svg>
        );
      case 'inventory':
        return (
          <svg className={`w-6 h-6 ${color}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
          </svg>
        );
      case 'monetization':
        return (
          <svg className={`w-6 h-6 ${color}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        );
      case 'notifications':
        return (
          <svg className={`w-6 h-6 ${color}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
          </svg>
        );
      default:
        return null;
    }
  };

  return (
    <>
      {showToast && (
        <div className="fixed bottom-20 left-1/2 transform -translate-x-1/2 bg-gray-800 text-white px-4 py-2 rounded-lg shadow-lg z-50">
          Your account is under review. Access restricted.
        </div>
      )}
      <nav className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 z-40">
        <div className="flex justify-around items-center h-16">
          {navItems.map((item) => {
            const isActive = pathname === item.href;
            const isRestricted = vendorData?.role !== 'seller' && item.href !== '/dashboard' && item.href !== '/notifications';
            
            return (
              <button
                key={item.href}
                onClick={(e) => handleNavClick(item.href, e)}
                className={`flex flex-col items-center justify-center flex-1 h-full ${
                  isRestricted ? 'opacity-50' : ''
                }`}
              >
                {getIcon(item.icon, isActive)}
                <span className={`text-xs mt-1 ${isActive ? 'text-primary font-medium' : 'text-gray-500'}`}>
                  {item.label}
                </span>
              </button>
            );
          })}
        </div>
      </nav>
    </>
  );
}
