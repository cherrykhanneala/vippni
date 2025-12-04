'use client';

import { useState, useEffect, useCallback } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import Image from 'next/image';
import ProtectedRoute from '@/components/ProtectedRoute';
import { useProducts, Product } from '@/hooks/useProducts';

export default function ProductDetailPage() {
  const params = useParams();
  const router = useRouter();
  const productId = params.id as string;
  const { getProduct, updateProduct, deleteProduct } = useProducts();
  
  const [product, setProduct] = useState<Product | null>(null);
  const [loading, setLoading] = useState(true);
  const [editing, setEditing] = useState(false);
  const [formData, setFormData] = useState<Partial<Product>>({});
  const [saving, setSaving] = useState(false);

  const loadProduct = useCallback(async () => {
    const productData = await getProduct(productId);
    if (productData) {
      setProduct(productData);
      setFormData(productData);
    }
    setLoading(false);
  }, [productId, getProduct]);

  useEffect(() => {
    loadProduct();
  }, [loadProduct]);

  const handleSave = async () => {
    if (!product) return;
    setSaving(true);
    try {
      await updateProduct(product.id, formData);
      setProduct({ ...product, ...formData });
      setEditing(false);
    } catch (error) {
      console.error('Error updating product:', error);
      alert('Failed to update product');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!product) return;
    if (window.confirm('Are you sure you want to delete this product?')) {
      try {
        await deleteProduct(product.id);
        router.push('/products');
      } catch (error) {
        console.error('Error deleting product:', error);
        alert('Failed to delete product');
      }
    }
  };

  if (loading) {
    return (
      <ProtectedRoute>
        <div className="min-h-screen flex items-center justify-center bg-gray-50">
          <div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin"></div>
        </div>
      </ProtectedRoute>
    );
  }

  if (!product) {
    return (
      <ProtectedRoute>
        <div className="min-h-screen flex flex-col items-center justify-center bg-gray-50">
          <p className="text-gray-500">Product not found</p>
          <Link href="/products" className="mt-4 text-primary">
            Back to Products
          </Link>
        </div>
      </ProtectedRoute>
    );
  }

  return (
    <ProtectedRoute>
      <div className="min-h-screen bg-gray-50 pb-24">
        {/* Header */}
        <header className="bg-primary text-white p-4 flex items-center justify-between">
          <Link href="/products" className="p-2 hover:bg-white/10 rounded-lg">
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
            </svg>
          </Link>
          <h1 className="text-lg font-bold">Product Details</h1>
          <button
            onClick={() => setEditing(!editing)}
            className="p-2 hover:bg-white/10 rounded-lg"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
            </svg>
          </button>
        </header>

        {/* Product Images */}
        <div className="p-4">
          <div className="relative h-64 bg-gray-100 rounded-xl overflow-hidden">
            {product.images && product.images[0] ? (
              <Image
                src={product.images[0]}
                alt={product.name}
                fill
                className="object-cover"
              />
            ) : (
              <div className="flex items-center justify-center h-full text-gray-400">
                <svg className="w-16 h-16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
              </div>
            )}
            {product.isOnSale && (
              <span className="absolute top-4 left-4 bg-accent text-white text-sm px-3 py-1 rounded-full">
                Sale
              </span>
            )}
          </div>

          {/* Thumbnail Images */}
          {product.images && product.images.length > 1 && (
            <div className="flex gap-2 mt-4 overflow-x-auto">
              {product.images.map((img, index) => (
                <div key={index} className="relative w-16 h-16 flex-shrink-0">
                  <Image
                    src={img}
                    alt={`${product.name} ${index + 1}`}
                    fill
                    className="object-cover rounded-lg"
                  />
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Product Info */}
        <div className="p-4 space-y-4">
          {editing ? (
            <>
              <input
                type="text"
                value={formData.name || ''}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                className="w-full text-xl font-bold p-3 border rounded-xl"
                placeholder="Product Name"
              />
              <div className="flex gap-4">
                <input
                  type="number"
                  step="0.01"
                  value={formData.price || ''}
                  onChange={(e) => setFormData({ ...formData, price: parseFloat(e.target.value) })}
                  className="flex-1 p-3 border rounded-xl"
                  placeholder="Price"
                />
                <input
                  type="number"
                  value={formData.quantity || ''}
                  onChange={(e) => setFormData({ ...formData, quantity: parseInt(e.target.value) })}
                  className="flex-1 p-3 border rounded-xl"
                  placeholder="Quantity"
                />
              </div>
              <textarea
                value={formData.description || ''}
                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                className="w-full p-3 border rounded-xl"
                rows={4}
                placeholder="Description"
              />
            </>
          ) : (
            <>
              <h1 className="text-xl font-bold text-primary">{product.name}</h1>
              <div className="flex items-center gap-4">
                <span className="text-2xl font-bold text-primary">
                  ${product.price.toFixed(2)}
                </span>
                {product.rrp && product.rrp > product.price && (
                  <span className="text-gray-400 line-through">
                    ${product.rrp.toFixed(2)}
                  </span>
                )}
              </div>
              <p className="text-gray-600">{product.description}</p>
            </>
          )}

          {/* Details Card */}
          <div className="bg-white rounded-xl p-4 shadow-sm">
            <h2 className="font-semibold text-primary mb-3">Product Details</h2>
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <span className="text-gray-500">Type</span>
                <p className="font-medium">{product.type}</p>
              </div>
              <div>
                <span className="text-gray-500">Stock</span>
                <p className="font-medium">{product.quantity} units</p>
              </div>
              <div>
                <span className="text-gray-500">Availability</span>
                <p className="font-medium">{product.availability}</p>
              </div>
              <div>
                <span className="text-gray-500">Weight</span>
                <p className="font-medium">{product.weight} {product.weightUnit}</p>
              </div>
            </div>
          </div>

          {/* Materials & Colors */}
          {(product.material?.length > 0 || product.colors?.length > 0) && (
            <div className="bg-white rounded-xl p-4 shadow-sm">
              <h2 className="font-semibold text-primary mb-3">Properties</h2>
              {product.material?.length > 0 && (
                <div className="mb-3">
                  <span className="text-gray-500 text-sm">Materials</span>
                  <div className="flex flex-wrap gap-2 mt-1">
                    {product.material.map((mat, index) => (
                      <span key={index} className="px-3 py-1 bg-light-bg text-primary rounded-full text-sm">
                        {mat}
                      </span>
                    ))}
                  </div>
                </div>
              )}
              {product.colors?.length > 0 && (
                <div>
                  <span className="text-gray-500 text-sm">Colors</span>
                  <div className="flex flex-wrap gap-2 mt-1">
                    {product.colors.map((color, index) => (
                      <span key={index} className="px-3 py-1 bg-light-bg text-primary rounded-full text-sm">
                        {color}
                      </span>
                    ))}
                  </div>
                </div>
              )}
            </div>
          )}

          {/* Tags */}
          {product.tags?.length > 0 && (
            <div className="bg-white rounded-xl p-4 shadow-sm">
              <h2 className="font-semibold text-primary mb-3">Tags</h2>
              <div className="flex flex-wrap gap-2">
                {product.tags.map((tag, index) => (
                  <span key={index} className="px-3 py-1 bg-gray-100 text-gray-600 rounded-full text-sm">
                    #{tag}
                  </span>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* Bottom Actions */}
        <div className="fixed bottom-0 left-0 right-0 bg-white border-t p-4 flex gap-4">
          {editing ? (
            <>
              <button
                onClick={() => {
                  setFormData(product);
                  setEditing(false);
                }}
                className="flex-1 py-3 border-2 border-gray-300 text-gray-600 rounded-xl font-bold"
              >
                Cancel
              </button>
              <button
                onClick={handleSave}
                disabled={saving}
                className="flex-1 py-3 bg-primary text-white rounded-xl font-bold disabled:opacity-50"
              >
                {saving ? 'Saving...' : 'Save Changes'}
              </button>
            </>
          ) : (
            <>
              <button
                onClick={handleDelete}
                className="flex-1 py-3 bg-red-500 text-white rounded-xl font-bold"
              >
                Delete
              </button>
              <button
                onClick={() => setEditing(true)}
                className="flex-1 py-3 bg-primary text-white rounded-xl font-bold"
              >
                Edit Product
              </button>
            </>
          )}
        </div>
      </div>
    </ProtectedRoute>
  );
}
