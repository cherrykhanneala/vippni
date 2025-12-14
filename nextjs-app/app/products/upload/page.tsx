'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import ProtectedRoute from '@/components/ProtectedRoute';
import { useProducts } from '@/hooks/useProducts';

const productTypes = [
  'Electronics', 'Clothing', 'Home & Garden', 'Sports', 'Toys', 'Books',
  'Health & Beauty', 'Automotive', 'Food & Beverages', 'Other'
];

const materialTypes = [
  'Cotton', 'Polyester', 'Leather', 'Metal', 'Plastic', 'Wood', 'Glass', 'Paper', 'Other'
];

const packagingTypes = ['Boxed', 'Envelope', 'Bag', 'Wrapped', 'No Packaging'];

export default function ProductUploadPage() {
  const router = useRouter();
  const { uploadImages, addProduct } = useProducts();
  
  const [loading, setLoading] = useState(false);
  const [currentStep, setCurrentStep] = useState(0);
  const [images, setImages] = useState<File[]>([]);
  const [imagePreviews, setImagePreviews] = useState<string[]>([]);
  
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    price: '',
    rrp: '',
    salePrice: '',
    isOnSale: false,
    quantity: '',
    barcode: '',
    type: '',
    availability: 'Available',
    weight: '',
    weightUnit: 'kg',
    dimensions: '',
    dimensionsUnit: 'cm',
    packaging: '',
    material: [] as string[],
    colors: [] as string[],
    tags: [] as string[],
  });

  const [colorInput, setColorInput] = useState('');
  const [tagInput, setTagInput] = useState('');
  const [materialInput, setMaterialInput] = useState('');

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || []);
    setImages((prev) => [...prev, ...files]);
    
    files.forEach((file) => {
      const reader = new FileReader();
      reader.onloadend = () => {
        setImagePreviews((prev) => [...prev, reader.result as string]);
      };
      reader.readAsDataURL(file);
    });
  };

  const removeImage = (index: number) => {
    setImages((prev) => prev.filter((_, i) => i !== index));
    setImagePreviews((prev) => prev.filter((_, i) => i !== index));
  };

  const addColor = () => {
    if (colorInput && !formData.colors.includes(colorInput)) {
      setFormData({ ...formData, colors: [...formData.colors, colorInput] });
      setColorInput('');
    }
  };

  const removeColor = (index: number) => {
    setFormData({
      ...formData,
      colors: formData.colors.filter((_, i) => i !== index),
    });
  };

  const addTag = () => {
    if (tagInput && !formData.tags.includes(tagInput)) {
      setFormData({ ...formData, tags: [...formData.tags, tagInput] });
      setTagInput('');
    }
  };

  const removeTag = (index: number) => {
    setFormData({
      ...formData,
      tags: formData.tags.filter((_, i) => i !== index),
    });
  };

  const addMaterial = () => {
    if (materialInput && !formData.material.includes(materialInput)) {
      setFormData({ ...formData, material: [...formData.material, materialInput] });
      setMaterialInput('');
    }
  };

  const removeMaterial = (index: number) => {
    setFormData({
      ...formData,
      material: formData.material.filter((_, i) => i !== index),
    });
  };

  const handleSubmit = async (isDraft = false) => {
    if (images.length === 0) {
      alert('Please add at least one image');
      return;
    }
    if (!formData.name || !formData.price || !formData.quantity) {
      alert('Please fill in all required fields');
      return;
    }

    setLoading(true);
    try {
      const imageUrls = await uploadImages(images);
      
      await addProduct({
        ...formData,
        price: parseFloat(formData.price),
        rrp: formData.rrp ? parseFloat(formData.rrp) : undefined,
        salePrice: formData.salePrice ? parseFloat(formData.salePrice) : undefined,
        quantity: parseInt(formData.quantity),
        weight: parseFloat(formData.weight) || 0,
        images: imageUrls,
        isDraft,
      });

      if (!isDraft) {
        router.push('/products');
      } else {
        alert('Draft saved successfully');
      }
    } catch (error) {
      console.error('Error saving product:', error);
      alert('Failed to save product');
    } finally {
      setLoading(false);
    }
  };

  const steps = [
    { title: 'Images', isComplete: images.length > 0 },
    { title: 'Details', isComplete: !!formData.name && !!formData.type },
    { title: 'Inventory', isComplete: !!formData.quantity },
    { title: 'Pricing', isComplete: !!formData.price },
    { title: 'Shipping', isComplete: !!formData.packaging && !!formData.weight },
    { title: 'Properties', isComplete: formData.material.length > 0 && formData.colors.length > 0 },
    { title: 'Tags', isComplete: true },
  ];

  return (
    <ProtectedRoute>
      <div className="min-h-screen bg-gray-50 pb-24">
        {/* Header */}
        <header className="bg-primary text-white p-4 flex items-center">
          <Link href="/products" className="p-2 hover:bg-white/10 rounded-lg">
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
            </svg>
          </Link>
          <h1 className="text-lg font-bold ml-4">Upload Product</h1>
        </header>

        {/* Steps Indicator */}
        <div className="p-4 overflow-x-auto">
          <div className="flex gap-2 min-w-max">
            {steps.map((step, index) => (
              <button
                key={index}
                onClick={() => setCurrentStep(index)}
                className={`px-4 py-2 rounded-full text-sm font-medium ${
                  currentStep === index
                    ? 'bg-primary text-white'
                    : step.isComplete
                    ? 'bg-green-100 text-green-700'
                    : 'bg-gray-200 text-gray-600'
                }`}
              >
                {step.title}
              </button>
            ))}
          </div>
        </div>

        {/* Form Content */}
        <div className="p-4">
          {/* Step 0: Images */}
          {currentStep === 0 && (
            <div className="space-y-4">
              <h2 className="text-lg font-semibold text-primary">Upload Images</h2>
              <div className="grid grid-cols-3 gap-4">
                {imagePreviews.map((preview, index) => (
                  <div key={index} className="relative aspect-square">
                    <img
                      src={preview}
                      alt={`Preview ${index + 1}`}
                      className="w-full h-full object-cover rounded-lg"
                    />
                    <button
                      onClick={() => removeImage(index)}
                      className="absolute top-1 right-1 w-6 h-6 bg-red-500 text-white rounded-full flex items-center justify-center"
                    >
                      ×
                    </button>
                  </div>
                ))}
                <label className="aspect-square border-2 border-dashed border-gray-300 rounded-lg flex items-center justify-center cursor-pointer hover:bg-gray-50">
                  <input
                    type="file"
                    accept="image/*"
                    multiple
                    onChange={handleImageChange}
                    className="hidden"
                  />
                  <svg className="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                  </svg>
                </label>
              </div>
            </div>
          )}

          {/* Step 1: Product Details */}
          {currentStep === 1 && (
            <div className="space-y-4">
              <h2 className="text-lg font-semibold text-primary">Product Details</h2>
              <select
                value={formData.type}
                onChange={(e) => setFormData({ ...formData, type: e.target.value })}
                className="w-full p-3 border rounded-xl"
              >
                <option value="">Select Product Type</option>
                {productTypes.map((type) => (
                  <option key={type} value={type}>{type}</option>
                ))}
              </select>
              <input
                type="text"
                placeholder="Product Name *"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                className="w-full p-3 border rounded-xl"
              />
              <textarea
                placeholder="Product Description"
                value={formData.description}
                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                rows={4}
                className="w-full p-3 border rounded-xl"
              />
            </div>
          )}

          {/* Step 2: Inventory */}
          {currentStep === 2 && (
            <div className="space-y-4">
              <h2 className="text-lg font-semibold text-primary">Inventory</h2>
              <input
                type="number"
                placeholder="Quantity *"
                value={formData.quantity}
                onChange={(e) => setFormData({ ...formData, quantity: e.target.value })}
                className="w-full p-3 border rounded-xl"
              />
              <select
                value={formData.availability}
                onChange={(e) => setFormData({ ...formData, availability: e.target.value })}
                className="w-full p-3 border rounded-xl"
              >
                <option value="Available">Available</option>
                <option value="Out of Stock">Out of Stock</option>
                <option value="Pre-order">Pre-order</option>
              </select>
              <input
                type="text"
                placeholder="Barcode (optional)"
                value={formData.barcode}
                onChange={(e) => setFormData({ ...formData, barcode: e.target.value })}
                className="w-full p-3 border rounded-xl"
              />
            </div>
          )}

          {/* Step 3: Pricing */}
          {currentStep === 3 && (
            <div className="space-y-4">
              <h2 className="text-lg font-semibold text-primary">Pricing</h2>
              <input
                type="number"
                step="0.01"
                placeholder="Price *"
                value={formData.price}
                onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                className="w-full p-3 border rounded-xl"
              />
              <input
                type="number"
                step="0.01"
                placeholder="RRP (optional)"
                value={formData.rrp}
                onChange={(e) => setFormData({ ...formData, rrp: e.target.value })}
                className="w-full p-3 border rounded-xl"
              />
              <label className="flex items-center gap-3">
                <input
                  type="checkbox"
                  checked={formData.isOnSale}
                  onChange={(e) => setFormData({ ...formData, isOnSale: e.target.checked })}
                  className="w-5 h-5 rounded"
                />
                <span>On Sale</span>
              </label>
              {formData.isOnSale && (
                <input
                  type="number"
                  step="0.01"
                  placeholder="Sale Price"
                  value={formData.salePrice}
                  onChange={(e) => setFormData({ ...formData, salePrice: e.target.value })}
                  className="w-full p-3 border rounded-xl"
                />
              )}
            </div>
          )}

          {/* Step 4: Shipping */}
          {currentStep === 4 && (
            <div className="space-y-4">
              <h2 className="text-lg font-semibold text-primary">Shipping Information</h2>
              <select
                value={formData.packaging}
                onChange={(e) => setFormData({ ...formData, packaging: e.target.value })}
                className="w-full p-3 border rounded-xl"
              >
                <option value="">Select Packaging Type</option>
                {packagingTypes.map((type) => (
                  <option key={type} value={type}>{type}</option>
                ))}
              </select>
              <div className="flex gap-2">
                <input
                  type="number"
                  step="0.01"
                  placeholder="Weight *"
                  value={formData.weight}
                  onChange={(e) => setFormData({ ...formData, weight: e.target.value })}
                  className="flex-1 p-3 border rounded-xl"
                />
                <select
                  value={formData.weightUnit}
                  onChange={(e) => setFormData({ ...formData, weightUnit: e.target.value })}
                  className="w-24 p-3 border rounded-xl"
                >
                  <option value="kg">kg</option>
                  <option value="g">g</option>
                  <option value="lb">lb</option>
                </select>
              </div>
              <div className="flex gap-2">
                <input
                  type="text"
                  placeholder="Dimensions (L x W x H)"
                  value={formData.dimensions}
                  onChange={(e) => setFormData({ ...formData, dimensions: e.target.value })}
                  className="flex-1 p-3 border rounded-xl"
                />
                <select
                  value={formData.dimensionsUnit}
                  onChange={(e) => setFormData({ ...formData, dimensionsUnit: e.target.value })}
                  className="w-24 p-3 border rounded-xl"
                >
                  <option value="cm">cm</option>
                  <option value="mm">mm</option>
                  <option value="in">in</option>
                </select>
              </div>
            </div>
          )}

          {/* Step 5: Properties */}
          {currentStep === 5 && (
            <div className="space-y-4">
              <h2 className="text-lg font-semibold text-primary">Product Properties</h2>
              
              {/* Materials */}
              <div>
                <label className="block text-sm font-medium mb-2">Materials</label>
                <div className="flex gap-2">
                  <select
                    value={materialInput}
                    onChange={(e) => setMaterialInput(e.target.value)}
                    className="flex-1 p-3 border rounded-xl"
                  >
                    <option value="">Select Material</option>
                    {materialTypes.map((type) => (
                      <option key={type} value={type}>{type}</option>
                    ))}
                  </select>
                  <button
                    onClick={addMaterial}
                    className="px-4 bg-primary text-white rounded-xl"
                  >
                    Add
                  </button>
                </div>
                <div className="flex flex-wrap gap-2 mt-2">
                  {formData.material.map((mat, index) => (
                    <span
                      key={index}
                      className="px-3 py-1 bg-light-bg text-primary rounded-full flex items-center gap-2"
                    >
                      {mat}
                      <button onClick={() => removeMaterial(index)}>×</button>
                    </span>
                  ))}
                </div>
              </div>

              {/* Colors */}
              <div>
                <label className="block text-sm font-medium mb-2">Colors</label>
                <div className="flex gap-2">
                  <input
                    type="text"
                    value={colorInput}
                    onChange={(e) => setColorInput(e.target.value)}
                    placeholder="Enter color"
                    className="flex-1 p-3 border rounded-xl"
                  />
                  <button
                    onClick={addColor}
                    className="px-4 bg-primary text-white rounded-xl"
                  >
                    Add
                  </button>
                </div>
                <div className="flex flex-wrap gap-2 mt-2">
                  {formData.colors.map((color, index) => (
                    <span
                      key={index}
                      className="px-3 py-1 bg-light-bg text-primary rounded-full flex items-center gap-2"
                    >
                      {color}
                      <button onClick={() => removeColor(index)}>×</button>
                    </span>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* Step 6: Tags */}
          {currentStep === 6 && (
            <div className="space-y-4">
              <h2 className="text-lg font-semibold text-primary">Product Tags</h2>
              <div className="flex gap-2">
                <input
                  type="text"
                  value={tagInput}
                  onChange={(e) => setTagInput(e.target.value)}
                  placeholder="Enter tag"
                  className="flex-1 p-3 border rounded-xl"
                />
                <button
                  onClick={addTag}
                  className="px-4 bg-primary text-white rounded-xl"
                >
                  Add
                </button>
              </div>
              <div className="flex flex-wrap gap-2">
                {formData.tags.map((tag, index) => (
                  <span
                    key={index}
                    className="px-3 py-1 bg-light-bg text-primary rounded-full flex items-center gap-2"
                  >
                    #{tag}
                    <button onClick={() => removeTag(index)}>×</button>
                  </span>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* Bottom Actions */}
        <div className="fixed bottom-0 left-0 right-0 bg-white border-t p-4 flex justify-between items-center">
          <button
            onClick={() => handleSubmit(true)}
            disabled={loading}
            className="flex flex-col items-center text-gray-600"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 4l-3 3m0 0l-3-3m3 3V4" />
            </svg>
            <span className="text-xs">Save Draft</span>
          </button>
          
          <button
            onClick={() => handleSubmit(false)}
            disabled={loading}
            className="px-8 py-3 bg-primary text-white rounded-xl font-bold disabled:opacity-50"
          >
            {loading ? 'Saving...' : 'Save Product'}
          </button>
          
          <button
            onClick={() => {
              setFormData({
                name: '',
                description: '',
                price: '',
                rrp: '',
                salePrice: '',
                isOnSale: false,
                quantity: '',
                barcode: '',
                type: '',
                availability: 'Available',
                weight: '',
                weightUnit: 'kg',
                dimensions: '',
                dimensionsUnit: 'cm',
                packaging: '',
                material: [],
                colors: [],
                tags: [],
              });
              setImages([]);
              setImagePreviews([]);
              setCurrentStep(0);
            }}
            className="flex flex-col items-center text-gray-600"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
            <span className="text-xs">Reset</span>
          </button>
        </div>
      </div>
    </ProtectedRoute>
  );
}
