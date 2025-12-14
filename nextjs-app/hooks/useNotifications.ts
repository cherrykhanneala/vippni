'use client';

import { useState, useEffect, useRef, useMemo } from 'react';
import {
  collection,
  query,
  orderBy,
  onSnapshot,
  Unsubscribe,
} from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { useAuth } from '@/contexts/AuthContext';

export interface Notification {
  id: string;
  title: string;
  body: string;
  timestamp: Date;
  read?: boolean;
}

export function useNotifications() {
  const { user } = useAuth();
  const [notificationsData, setNotificationsData] = useState<{
    items: Notification[];
    loading: boolean;
  }>({ items: [], loading: true });
  const unsubscribeRef = useRef<Unsubscribe | null>(null);

  const userId = useMemo(() => user?.uid, [user?.uid]);

  useEffect(() => {
    // Clean up previous subscription
    if (unsubscribeRef.current) {
      unsubscribeRef.current();
      unsubscribeRef.current = null;
    }

    // If no user, return empty state (loading will be set to false via initial state when user is null)
    if (!userId) {
      return;
    }

    const q = query(
      collection(db, 'vendors', userId, 'notifications'),
      orderBy('timestamp', 'desc')
    );

    unsubscribeRef.current = onSnapshot(q, (snapshot) => {
      const notificationData = snapshot.docs.map((docSnap) => ({
        id: docSnap.id,
        ...docSnap.data(),
        timestamp: docSnap.data().timestamp?.toDate() || new Date(),
      })) as Notification[];
      setNotificationsData({ items: notificationData, loading: false });
    }, (error) => {
      console.error('Error fetching notifications:', error);
      setNotificationsData(prev => ({ ...prev, loading: false }));
    });

    return () => {
      if (unsubscribeRef.current) {
        unsubscribeRef.current();
        unsubscribeRef.current = null;
      }
    };
  }, [userId]);

  // Derive the final notifications and loading state
  const notifications = userId ? notificationsData.items : [];
  const loading = userId ? notificationsData.loading : false;

  return {
    notifications,
    loading,
  };
}
