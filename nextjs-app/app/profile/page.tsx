'use client';

import { useState } from 'react';
import ProtectedRoute from '@/components/ProtectedRoute';
import BottomNavigation from '@/components/BottomNavigation';
import Sidebar from '@/components/Sidebar';
import { useAuth } from '@/contexts/AuthContext';

export default function ProfilePage() {
  const { user, vendorData, signOut } = useAuth();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [editing, setEditing] = useState(false);

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
          <h1 className="text-lg font-bold">Profile</h1>
          <button
            onClick={() => setEditing(!editing)}
            className="p-2 hover:bg-white/10 rounded-lg"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
            </svg>
          </button>
        </header>

        <Sidebar isOpen={sidebarOpen} onClose={() => setSidebarOpen(false)} />

        {/* Profile Content */}
        <div className="p-4 space-y-6">
          {/* Avatar & Basic Info */}
          <div className="bg-white rounded-xl p-6 shadow-sm text-center">
            <div className="w-24 h-24 bg-primary rounded-full flex items-center justify-center mx-auto">
              <span className="text-4xl font-bold text-white">
                {vendorData?.shopName?.charAt(0) || 'V'}
              </span>
            </div>
            <h2 className="text-xl font-bold text-primary mt-4">
              {vendorData?.shopName || 'Guest'}
            </h2>
            <p className="text-gray-500">{user?.email}</p>
            <span className={`inline-block mt-2 px-3 py-1 rounded-full text-sm ${
              vendorData?.role === 'seller'
                ? 'bg-green-100 text-green-700'
                : 'bg-yellow-100 text-yellow-700'
            }`}>
              {vendorData?.role === 'seller' ? 'Verified Seller' : 'Pending Verification'}
            </span>
          </div>

          {/* Vendor Information */}
          <div className="bg-white rounded-xl p-6 shadow-sm">
            <h3 className="font-semibold text-primary mb-4">Vendor Information</h3>
            <div className="space-y-4">
              <div>
                <label className="text-gray-500 text-sm">Full Name</label>
                <p className="font-medium">{vendorData?.fullName || '-'}</p>
              </div>
              <div>
                <label className="text-gray-500 text-sm">Shop Name</label>
                <p className="font-medium">{vendorData?.shopName || '-'}</p>
              </div>
              <div>
                <label className="text-gray-500 text-sm">Shop Address</label>
                <p className="font-medium">{vendorData?.shopAddress || '-'}</p>
              </div>
              <div>
                <label className="text-gray-500 text-sm">Home Address</label>
                <p className="font-medium">{vendorData?.homeAddress || '-'}</p>
              </div>
              <div>
                <label className="text-gray-500 text-sm">Postage Type</label>
                <p className="font-medium">{vendorData?.postageType || '-'}</p>
              </div>
              <div>
                <label className="text-gray-500 text-sm">Product Types</label>
                <div className="flex flex-wrap gap-2 mt-1">
                  {vendorData?.productTypes?.map((type, index) => (
                    <span
                      key={index}
                      className="px-3 py-1 bg-light-bg text-primary rounded-full text-sm"
                    >
                      {type}
                    </span>
                  )) || '-'}
                </div>
              </div>
            </div>
          </div>

          {/* Quick Links */}
          <div className="bg-white rounded-xl p-6 shadow-sm">
            <h3 className="font-semibold text-primary mb-4">Quick Links</h3>
            <div className="space-y-2">
              <a href="/profile/terms" className="flex items-center justify-between p-3 hover:bg-gray-50 rounded-lg">
                <span>Terms & Conditions</span>
                <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                </svg>
              </a>
              <a href="/profile/privacy" className="flex items-center justify-between p-3 hover:bg-gray-50 rounded-lg">
                <span>Privacy Policy</span>
                <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                </svg>
              </a>
              <a href="/profile/contact" className="flex items-center justify-between p-3 hover:bg-gray-50 rounded-lg">
                <span>Contact Us</span>
                <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                </svg>
              </a>
            </div>
          </div>

          {/* Sign Out Button */}
          <button
            onClick={() => signOut()}
            className="w-full py-4 bg-red-500 text-white font-bold rounded-xl hover:bg-red-600 transition-colors"
          >
            Sign Out
          </button>
        </div>

        <BottomNavigation />
      </div>
    </ProtectedRoute>
  );
}
