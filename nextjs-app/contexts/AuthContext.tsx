'use client';

import React, { createContext, useContext, useEffect, useState } from 'react';
import {
  User,
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut as firebaseSignOut,
  onAuthStateChanged,
  sendPasswordResetEmail,
  GoogleAuthProvider,
  signInWithPopup,
} from 'firebase/auth';
import { doc, setDoc, getDoc } from 'firebase/firestore';
import { auth, db } from '@/lib/firebase';

interface VendorData {
  fullName: string;
  email: string;
  shopName: string;
  shopAddress: string;
  homeAddress: string;
  postageType: string;
  productTypes: string[];
  role: string;
}

interface AuthContextType {
  user: User | null;
  vendorData: VendorData | null;
  loading: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  signUp: (email: string, password: string, vendorInfo: Omit<VendorData, 'email' | 'role'>) => Promise<void>;
  signOut: () => Promise<void>;
  resetPassword: (email: string) => Promise<void>;
  signInWithGoogle: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [vendorData, setVendorData] = useState<VendorData | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      setUser(user);
      if (user) {
        const vendorDoc = await getDoc(doc(db, 'vendors', user.uid));
        if (vendorDoc.exists()) {
          setVendorData(vendorDoc.data() as VendorData);
        }
      } else {
        setVendorData(null);
      }
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const signIn = async (email: string, password: string) => {
    await signInWithEmailAndPassword(auth, email, password);
  };

  const signUp = async (
    email: string,
    password: string,
    vendorInfo: Omit<VendorData, 'email' | 'role'>
  ) => {
    const result = await createUserWithEmailAndPassword(auth, email, password);
    const vendorData: VendorData = {
      ...vendorInfo,
      email,
      role: 'pending',
    };
    await setDoc(doc(db, 'vendors', result.user.uid), vendorData);
    setVendorData(vendorData);
  };

  const signOut = async () => {
    await firebaseSignOut(auth);
    setVendorData(null);
  };

  const resetPassword = async (email: string) => {
    await sendPasswordResetEmail(auth, email);
  };

  const signInWithGoogle = async () => {
    const provider = new GoogleAuthProvider();
    await signInWithPopup(auth, provider);
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        vendorData,
        loading,
        signIn,
        signUp,
        signOut,
        resetPassword,
        signInWithGoogle,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
