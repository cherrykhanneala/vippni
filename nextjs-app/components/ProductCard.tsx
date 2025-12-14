'use client';

import Image from 'next/image';
import { Product } from '@/hooks/useProducts';

interface ProductCardProps {
  product: Product;
  onDelete: (id: string) => void;
  onEdit: (id: string) => void;
}

export default function ProductCard({ product, onDelete, onEdit }: ProductCardProps) {
  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden">
      <div className="relative h-40 bg-gray-100">
        {product.images && product.images[0] ? (
          <Image
            src={product.images[0]}
            alt={product.name}
            fill
            className="object-cover"
          />
        ) : (
          <div className="flex items-center justify-center h-full text-gray-400">
            <svg className="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
          </div>
        )}
        {product.isOnSale && (
          <span className="absolute top-2 left-2 bg-accent text-white text-xs px-2 py-1 rounded">
            Sale
          </span>
        )}
      </div>
      
      <div className="p-3">
        <h3 className="font-medium text-gray-900 truncate">{product.name}</h3>
        <p className="text-primary font-bold mt-1">
          ${product.price.toFixed(2)}
          {product.rrp && product.rrp > product.price && (
            <span className="ml-2 text-sm text-gray-400 line-through">
              ${product.rrp.toFixed(2)}
            </span>
          )}
        </p>
        <p className="text-sm text-gray-500 mt-1">
          Stock: {product.quantity}
        </p>
        
        <div className="flex gap-2 mt-3">
          <button
            onClick={() => onEdit(product.id)}
            className="flex-1 bg-primary text-white text-sm py-1.5 rounded hover:bg-primary-dark transition"
          >
            Edit
          </button>
          <button
            onClick={() => onDelete(product.id)}
            className="flex-1 bg-red-500 text-white text-sm py-1.5 rounded hover:bg-red-600 transition"
          >
            Delete
          </button>
        </div>
      </div>
    </div>
  );
}
