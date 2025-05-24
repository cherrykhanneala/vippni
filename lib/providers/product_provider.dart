import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/product.dart';
import '../services/cache_service.dart';
import '../services/logging_service.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CacheService _cacheService = CacheService();
  final LoggingService _logger = LoggingService();
  
  List<DocumentSnapshot> _products = []; // Change from QueryDocumentSnapshot
  bool _isLoading = false;
  String? _error;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  
  // Getters
  List<DocumentSnapshot> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  
  // Get product by ID with caching
  Future<Product?> getProductById(String productId) async {
    try {
      // Try to get from cache first
      final cachedProduct = await _cacheService.getCachedData('product_$productId');
      if (cachedProduct != null) {
        return Product.fromMap(cachedProduct, productId);
      }
      
      // If not in cache, get from Firestore
      final docSnapshot = await _firestore.collection('products').doc(productId).get();
      
      if (!docSnapshot.exists) {
        _logger.warn('Product $productId not found');
        return null;
      }
      
      // Cache the result
      await _cacheService.cacheData(
        'product_$productId', 
        docSnapshot.data(),
        expiry: Duration(hours: 1)
      );
      
      return Product.fromFirestore(docSnapshot);
    } catch (e) {
      _logger.error('Error fetching product: $e');
      throw Exception('Failed to fetch product: $e');
    }
  }
  
  // Create new product with image upload
  Future<void> createProduct(Map<String, dynamic> productData, File? imageFile) async {
    try {
      // 1. Upload image if provided
      if (imageFile != null) {
        final imageUrl = await _uploadImage(imageFile);
        productData['imageUrl'] = imageUrl;
      }
      
      // 2. Add product to Firestore
      final docRef = await _firestore.collection('products').add(productData);
      
      _logger.info('Product created with ID: ${docRef.id}');
      
      // 3. Clear cache to refresh product lists
      await _cacheService.clearCache('products_${productData['vendorId']}');
      
      notifyListeners();
    } catch (e) {
      _logger.error('Error creating product: $e');
      throw Exception('Failed to create product: $e');
    }
  }
  
  // Update existing product
  Future<void> updateProduct(String productId, Map<String, dynamic> productData, File? imageFile) async {
    try {
      // 1. Upload new image if provided
      if (imageFile != null) {
        final imageUrl = await _uploadImage(imageFile);
        productData['imageUrl'] = imageUrl;
      }
      
      // 2. Update Firestore document
      await _firestore.collection('products').doc(productId).update(productData);
      
      _logger.info('Product updated: $productId');
      
      // 3. Update cache
      await _cacheService.clearCache('product_$productId');
      await _cacheService.clearCache('products_${productData['vendorId']}');
      
      // 4. Update local products list if needed
      final index = _products.indexWhere((doc) => doc.id == productId);
      if (index != -1) {
        // Refresh the products list
        await fetchProducts();
      }
      
      notifyListeners();
    } catch (e) {
      _logger.error('Error updating product: $e');
      throw Exception('Failed to update product: $e');
    }
  }
  
  // Upload image to Firebase Storage
  Future<String> _uploadImage(File imageFile) async {
    try {
      // Create unique file name
      final fileName = 'products/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final storageRef = _storage.ref().child(fileName);
      
      // Upload file
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;
      
      // Get download URL
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      _logger.error('Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }
  
  // Fetch products with pagination and caching
  Future<void> fetchProducts({
    String? vendorId,
    int limit = 10,
    bool refresh = false,
  }) async {
    if (_isLoading) return;
    
    if (refresh) {
      _lastDocument = null;
      _products = [];
      _hasMore = true;
    }
    
    if (!_hasMore) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final String cacheKey = vendorId != null ? 'products_$vendorId' : 'all_products';
      
      // Try to get from cache first if not refreshing
      if (!refresh) {
        final cachedProducts = await _cacheService.getCachedData(cacheKey);
        if (cachedProducts != null) {
          // Process cached data
          _logger.info('Using cached products data');
          // We'd need to convert the cached data back to QueryDocumentSnapshot format
          // For simplicity, we'll continue with Firestore query for now
        }
      }
      
      // Build query
      Query query = _firestore.collection('products').orderBy('name').limit(limit);
      
      if (vendorId != null) {
        query = query.where('vendorId', isEqualTo: vendorId);
      }
      
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }
      
      // Execute query
      final querySnapshot = await query.get();
      
      if (querySnapshot.docs.isEmpty) {
        _hasMore = false;
      } else {
        _lastDocument = querySnapshot.docs.last;
        
        if (refresh) {
          _products = querySnapshot.docs;
        } else {
          _products.addAll(querySnapshot.docs);
        }
        
        // Cache the results
        await _cacheService.cacheData(
          cacheKey, 
          querySnapshot.docs.map((doc) => doc.data()).toList(),
          expiry: Duration(minutes: 30)
        );
      }
    } catch (e) {
      _error = e.toString();
      _logger.error('Error fetching products: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}