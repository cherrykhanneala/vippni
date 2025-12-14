'use client';

import Link from 'next/link';
import { useAuth } from '@/contexts/AuthContext';

interface SidebarProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function Sidebar({ isOpen, onClose }: SidebarProps) {
  const { signOut, vendorData } = useAuth();

  const menuItems = [
    { href: '/profile', label: 'Edit Profile', icon: 'edit' },
    { href: '/profile/shop', label: 'Shop Information', icon: 'store' },
    { href: '/profile/terms', label: 'Terms & Conditions', icon: 'document' },
    { href: '/profile/privacy', label: 'Privacy Policy', icon: 'shield' },
    { href: '/profile/contact', label: 'Contact Us', icon: 'mail' },
  ];

  const handleSignOut = async () => {
    try {
      await signOut();
    } catch (error) {
      console.error('Error signing out:', error);
    }
  };

  return (
    <>
      {/* Backdrop */}
      {isOpen && (
        <div
          className="fixed inset-0 bg-black/50 z-40"
          onClick={onClose}
        />
      )}
      
      {/* Sidebar */}
      <div
        className={`fixed top-0 left-0 h-full w-72 bg-white z-50 transform transition-transform duration-300 ${
          isOpen ? 'translate-x-0' : '-translate-x-full'
        }`}
      >
        <div className="p-6 bg-primary text-white">
          <h2 className="text-xl font-bold">{vendorData?.shopName || 'Guest'}</h2>
          <p className="text-sm opacity-80">{vendorData?.email}</p>
        </div>

        <nav className="py-4">
          {menuItems.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              onClick={onClose}
              className="flex items-center px-6 py-3 hover:bg-gray-100"
            >
              <span className="text-gray-700">{item.label}</span>
            </Link>
          ))}
        </nav>

        <div className="absolute bottom-0 left-0 right-0 p-6 border-t">
          <button
            onClick={handleSignOut}
            className="flex items-center w-full px-4 py-3 text-red-600 hover:bg-red-50 rounded-lg"
          >
            <svg className="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
            </svg>
            Sign Out
          </button>
        </div>
      </div>
    </>
  );
}
