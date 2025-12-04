'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { useAuth } from '@/contexts/AuthContext';

export default function SignUpPage() {
  const [formData, setFormData] = useState({
    fullName: '',
    shopName: '',
    shopAddress: '',
    homeAddress: '',
    postageType: '',
    productTypes: '',
    email: '',
    password: '',
    confirmPassword: '',
  });
  const [acceptTerms, setAcceptTerms] = useState(false);
  const [acceptPrivacy, setAcceptPrivacy] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  
  const { signUp } = useAuth();
  const router = useRouter();

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const validateForm = () => {
    if (!formData.fullName) return 'Please enter your full name';
    if (!formData.shopName) return 'Please enter your shop name';
    if (!formData.shopAddress) return 'Please enter your shop address';
    if (!formData.homeAddress) return 'Please enter your home address';
    if (!formData.postageType) return 'Please enter your postage type';
    if (!formData.productTypes) return 'Please enter your product types';
    if (!formData.email) return 'Please enter your email';
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) return 'Please enter a valid email';
    if (!formData.password || formData.password.length < 8) return 'Password must be at least 8 characters';
    if (formData.password !== formData.confirmPassword) return 'Passwords do not match';
    if (!acceptTerms) return 'Please accept the Terms and Conditions';
    if (!acceptPrivacy) return 'Please accept the Privacy Policy';
    return null;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    const validationError = validateForm();
    if (validationError) {
      setError(validationError);
      return;
    }

    setLoading(true);
    try {
      const productTypes = formData.productTypes.split(',').map((t) => t.trim());
      await signUp(formData.email, formData.password, {
        fullName: formData.fullName,
        shopName: formData.shopName,
        shopAddress: formData.shopAddress,
        homeAddress: formData.homeAddress,
        postageType: formData.postageType,
        productTypes,
      });
      router.push('/dashboard');
    } catch (error: unknown) {
      if (error && typeof error === 'object' && 'code' in error) {
        const authError = error as { code: string; message?: string };
        switch (authError.code) {
          case 'auth/email-already-in-use':
            setError('The email address is already in use by another account.');
            break;
          case 'auth/weak-password':
            setError('The password provided is too weak.');
            break;
          case 'auth/invalid-email':
            setError('The email address is not valid.');
            break;
          default:
            setError('Failed to sign up. Please try again.');
        }
      } else {
        setError('An error occurred. Please try again.');
      }
    } finally {
      setLoading(false);
    }
  };

  const inputFields = [
    { name: 'fullName', label: 'Full Name *', icon: 'person', type: 'text' },
    { name: 'shopName', label: 'Shop Name *', icon: 'store', type: 'text' },
    { name: 'shopAddress', label: 'Shop Address *', icon: 'location', type: 'text' },
    { name: 'homeAddress', label: 'Home Address *', icon: 'home', type: 'text' },
    { name: 'postageType', label: 'Postage Type *', icon: 'shipping', type: 'text' },
    { name: 'productTypes', label: 'Product Types (comma-separated) *', icon: 'category', type: 'text' },
    { name: 'email', label: 'Email *', icon: 'email', type: 'email' },
    { name: 'password', label: 'Password *', icon: 'lock', type: 'password' },
    { name: 'confirmPassword', label: 'Confirm Password *', icon: 'lock', type: 'password' },
  ];

  const getIcon = (iconName: string) => {
    switch (iconName) {
      case 'person':
        return <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />;
      case 'store':
        return <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />;
      case 'location':
        return <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />;
      case 'home':
        return <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />;
      case 'shipping':
        return <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4" />;
      case 'category':
        return <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z" />;
      case 'email':
        return <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />;
      case 'lock':
        return <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />;
      default:
        return null;
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 py-8 px-4">
      <div className="max-w-md mx-auto">
        {/* Header */}
        <div className="flex items-center mb-6">
          <Link href="/login" className="p-2 hover:bg-gray-100 rounded-lg">
            <svg className="w-6 h-6 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
            </svg>
          </Link>
          <h1 className="text-xl font-bold text-primary ml-4">Vendor Sign Up</h1>
        </div>

        {error && (
          <div className="mb-4 p-4 bg-red-50 border border-red-200 text-red-600 rounded-lg">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          {inputFields.map((field) => (
            <div key={field.name} className="relative">
              <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                <svg className="h-5 w-5 text-secondary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  {getIcon(field.icon)}
                </svg>
              </div>
              <input
                type={field.type === 'password' ? (showPassword ? 'text' : 'password') : field.type}
                name={field.name}
                value={formData[field.name as keyof typeof formData]}
                onChange={handleChange}
                placeholder={field.label}
                className="block w-full pl-12 pr-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-secondary focus:border-transparent"
              />
              {field.type === 'password' && (
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute inset-y-0 right-0 pr-4 flex items-center"
                >
                  <svg className="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    {showPassword ? (
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21" />
                    ) : (
                      <>
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                      </>
                    )}
                  </svg>
                </button>
              )}
            </div>
          ))}

          {/* Terms and Conditions */}
          <label className="flex items-start gap-3 p-3 bg-white rounded-lg border border-gray-200">
            <input
              type="checkbox"
              checked={acceptTerms}
              onChange={(e) => setAcceptTerms(e.target.checked)}
              className="mt-1 h-4 w-4 text-secondary rounded"
            />
            <span className="text-sm text-gray-600">
              I accept the{' '}
              <Link href="/terms" className="text-secondary underline">
                Terms and Conditions
              </Link>
              {' *'}
            </span>
          </label>

          {/* Privacy Policy */}
          <label className="flex items-start gap-3 p-3 bg-white rounded-lg border border-gray-200">
            <input
              type="checkbox"
              checked={acceptPrivacy}
              onChange={(e) => setAcceptPrivacy(e.target.checked)}
              className="mt-1 h-4 w-4 text-secondary rounded"
            />
            <span className="text-sm text-gray-600">
              I accept the{' '}
              <Link href="/privacy" className="text-secondary underline">
                Privacy Policy
              </Link>
              {' *'}
            </span>
          </label>

          {/* Submit Button */}
          <button
            type="submit"
            disabled={loading}
            className="w-full py-4 bg-secondary text-white font-bold rounded-xl hover:bg-primary transition-colors disabled:opacity-50"
          >
            {loading ? 'Signing Up...' : 'Sign Up'}
          </button>

          <p className="text-center text-gray-600">
            Already have an account?{' '}
            <Link href="/login" className="text-secondary font-semibold">
              Sign In
            </Link>
          </p>
        </form>
      </div>
    </div>
  );
}
