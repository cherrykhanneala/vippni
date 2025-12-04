'use client';

import { useState, useEffect, useCallback } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import ProtectedRoute from '@/components/ProtectedRoute';
import BottomNavigation from '@/components/BottomNavigation';
import ProductCard from '@/components/ProductCard';
import { useProducts } from '@/hooks/useProducts';

const filterOptions = [
  { value: 'uploads', label: 'All Uploads' },
  { value: 'under_review', label: 'Under Review' },
  { value: 'sold', label: 'Sold' },
  { value: 'on_sale', label: 'On Sale' },
  { value: 'in_process', label: 'In Process' },
  { value: 'cancelled', label: 'Cancelled' },
  { value: 'inventory', label: 'Inventory' },
];

export default function ProductsPage() {
  const router = useRouter();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const {
    products,
    loading,
    hasMore,
    filter,
    setFilter,
    fetchProducts,
    deleteProduct,
  } = useProducts();

  const handleDelete = async (productId: string) => {
    if (window.confirm('Are you sure you want to delete this product?')) {
      try {
        await deleteProduct(productId);
      } catch (error) {
        console.error('Error deleting product:', error);
        alert('Failed to delete product');
      }
    }
  };

  const handleEdit = (productId: string) => {
    router.push(`/products/${productId}`);
  };

  const handleScroll = useCallback(() => {
    if (
      window.innerHeight + document.documentElement.scrollTop >=
        document.documentElement.offsetHeight - 200 &&
      hasMore &&
      !loading
    ) {
      fetchProducts();
    }
  }, [hasMore, loading, fetchProducts]);

  useEffect(() => {
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, [handleScroll]);

  return (
    <ProtectedRoute>
      <div className="min-h-screen bg-gray-50 pb-20">
        {/* Header */}
        <header className="bg-primary text-white p-4 flex items-center justify-between">
          <button
            onClick={() => setSidebarOpen(!sidebarOpen)}
            className="p-2 hover:bg-white/10 rounded-lg"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>
          <h1 className="text-lg font-bold">My Products</h1>
          <Link href="/products/upload" className="p-2 hover:bg-white/10 rounded-lg">
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
            </svg>
          </Link>
        </header>

        {/* Filter Drawer */}
        {sidebarOpen && (
          <>
            <div
              className="fixed inset-0 bg-black/50 z-40"
              onClick={() => setSidebarOpen(false)}
            />
            <div className="fixed top-0 left-0 h-full w-64 bg-white z-50 shadow-xl">
              <div className="p-6 bg-primary text-white">
                <h2 className="text-xl font-bold">Filter Products</h2>
              </div>
              <nav className="py-4">
                {filterOptions.map((option) => (
                  <button
                    key={option.value}
                    onClick={() => {
                      setFilter(option.value);
                      setSidebarOpen(false);
                    }}
                    className={`w-full text-left px-6 py-3 hover:bg-gray-100 ${
                      filter === option.value ? 'bg-light-bg text-primary font-medium' : ''
                    }`}
                  >
                    {option.label}
                  </button>
                ))}
              </nav>
            </div>
          </>
        )}

        {/* Products Grid */}
        <div className="p-4">
          {products.length === 0 && !loading ? (
            <div className="text-center py-12">
              <svg className="w-16 h-16 mx-auto text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
              </svg>
              <p className="mt-4 text-gray-500">No products found.</p>
              <Link
                href="/products/upload"
                className="mt-4 inline-block bg-primary text-white px-6 py-2 rounded-lg"
              >
                Add Your First Product
              </Link>
            </div>
          ) : (
            <div className="grid grid-cols-2 gap-4">
              {products.map((product) => (
                <ProductCard
                  key={product.id}
                  product={product}
                  onDelete={handleDelete}
                  onEdit={handleEdit}
                />
              ))}
            </div>
          )}

          {loading && (
            <div className="flex justify-center py-8">
              <div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin"></div>
            </div>
          )}
        </div>

        <BottomNavigation />
      </div>
    </ProtectedRoute>
  );
}
