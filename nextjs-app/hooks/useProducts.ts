'use client';

import { useState, useEffect, useCallback, useRef } from 'react';
import {
  collection,
  query,
  where,
  orderBy,
  limit,
  getDocs,
  startAfter,
  deleteDoc,
  doc,
  updateDoc,
  addDoc,
  getDoc,
  DocumentSnapshot,
} from 'firebase/firestore';
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { db, storage } from '@/lib/firebase';
import { useAuth } from '@/contexts/AuthContext';

export interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  rrp?: number;
  salePrice?: number;
  isOnSale: boolean;
  quantity: number;
  barcode?: string;
  type: string;
  availability: string;
  weight: number;
  weightUnit: string;
  dimensions?: string;
  dimensionsUnit?: string;
  packaging?: string;
  material: string[];
  colors: string[];
  tags: string[];
  images: string[];
  vendorId: string;
  status?: string;
  isDraft?: boolean;
}

export function useProducts() {
  const { user } = useAuth();
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(false);
  const [hasMore, setHasMore] = useState(true);
  const [lastDoc, setLastDoc] = useState<DocumentSnapshot | null>(null);
  const [filter, setFilter] = useState<string>('uploads');
  const initialFetchDone = useRef(false);

  const fetchProducts = useCallback(async (refresh = false) => {
    if (!user) return;

    setLoading(true);
    try {
      let q = query(
        collection(db, 'products'),
        where('vendorId', '==', user.uid),
        orderBy('name'),
        limit(10)
      );

      if (filter !== 'uploads' && filter !== 'inventory') {
        q = query(
          collection(db, 'products'),
          where('vendorId', '==', user.uid),
          where('status', '==', filter),
          orderBy('name'),
          limit(10)
        );
      }

      if (lastDoc && !refresh) {
        q = query(q, startAfter(lastDoc));
      }

      const snapshot = await getDocs(q);
      const newProducts = snapshot.docs.map((docSnap) => ({
        id: docSnap.id,
        ...docSnap.data(),
      })) as Product[];

      if (refresh) {
        setProducts(newProducts);
        setLastDoc(snapshot.docs[snapshot.docs.length - 1] || null);
      } else {
        setProducts((prev) => [...prev, ...newProducts]);
        setLastDoc(snapshot.docs[snapshot.docs.length - 1] || null);
      }

      setHasMore(snapshot.docs.length === 10);
    } catch (error) {
      console.error('Error fetching products:', error);
    } finally {
      setLoading(false);
    }
  }, [user, filter, lastDoc]);

  const getProduct = useCallback(async (productId: string): Promise<Product | null> => {
    try {
      const docRef = doc(db, 'products', productId);
      const docSnap = await getDoc(docRef);
      if (docSnap.exists()) {
        return { id: docSnap.id, ...docSnap.data() } as Product;
      }
      return null;
    } catch (error) {
      console.error('Error getting product:', error);
      return null;
    }
  }, []);

  const deleteProduct = async (productId: string) => {
    try {
      await deleteDoc(doc(db, 'products', productId));
      setProducts((prev) => prev.filter((p) => p.id !== productId));
    } catch (error) {
      console.error('Error deleting product:', error);
      throw error;
    }
  };

  const updateInventory = async (productId: string, quantity: number) => {
    try {
      await updateDoc(doc(db, 'products', productId), { quantity });
      setProducts((prev) =>
        prev.map((p) => (p.id === productId ? { ...p, quantity } : p))
      );
    } catch (error) {
      console.error('Error updating inventory:', error);
      throw error;
    }
  };

  const uploadImages = async (files: File[]): Promise<string[]> => {
    const urls: string[] = [];
    for (const file of files) {
      const fileName = `products/${Date.now()}_${file.name}`;
      const storageRef = ref(storage, fileName);
      await uploadBytes(storageRef, file);
      const url = await getDownloadURL(storageRef);
      urls.push(url);
    }
    return urls;
  };

  const addProduct = async (productData: Omit<Product, 'id' | 'vendorId'>) => {
    if (!user) throw new Error('User not authenticated');

    try {
      const docRef = await addDoc(collection(db, 'products'), {
        ...productData,
        vendorId: user.uid,
      });
      return docRef.id;
    } catch (error) {
      console.error('Error adding product:', error);
      throw error;
    }
  };

  const updateProduct = async (
    productId: string,
    productData: Partial<Product>
  ) => {
    try {
      await updateDoc(doc(db, 'products', productId), productData);
      setProducts((prev) =>
        prev.map((p) => (p.id === productId ? { ...p, ...productData } : p))
      );
    } catch (error) {
      console.error('Error updating product:', error);
      throw error;
    }
  };

  // Initial fetch when user is available
  useEffect(() => {
    if (user && !initialFetchDone.current) {
      initialFetchDone.current = true;
      fetchProducts(true);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [user]);

  // Refetch when filter changes
  useEffect(() => {
    if (user && initialFetchDone.current) {
      fetchProducts(true);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [filter]);

  return {
    products,
    loading,
    hasMore,
    filter,
    setFilter,
    fetchProducts,
    getProduct,
    deleteProduct,
    updateInventory,
    uploadImages,
    addProduct,
    updateProduct,
  };
}
