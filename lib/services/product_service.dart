import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Fetch products for a vendor
  Future<QuerySnapshot> getProductsByVendor(String vendorId, {int limit = 10, DocumentSnapshot? lastDocument}) {
    Query query = _firestore
        .collection('products')
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('name')
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return query.get();
  }

  // Fetch a single product by ID
  Future<DocumentSnapshot> getProductById(String productId) {
    return _firestore.collection('products').doc(productId).get();
  }

  // Create a new product
  Future<String> createProduct(Map<String, dynamic> productData, List<File> images) async {
    // Upload images first
    List<String> imageUrls = await _uploadImages(images);
    productData['images'] = imageUrls;
    
    // Create the product document
    DocumentReference docRef = await _firestore.collection('products').add(productData);
    return docRef.id;
  }

  // Update an existing product
  Future<void> updateProduct(String productId, Map<String, dynamic> productData, {List<File>? newImages}) async {
    if (newImages != null && newImages.isNotEmpty) {
      List<String> imageUrls = await _uploadImages(newImages);
      productData['images'] = imageUrls;
    }
    
    await _firestore.collection('products').doc(productId).update(productData);
  }

  // Delete a product
  Future<void> deleteProduct(String productId) async {
    // Get the product to delete its images
    DocumentSnapshot product = await _firestore.collection('products').doc(productId).get();
    
    // Delete images from storage if they exist
    if (product.exists) {
      Map<String, dynamic> data = product.data() as Map<String, dynamic>;
      if (data['images'] != null) {
        List<dynamic> images = data['images'];
        for (String imageUrl in List<String>.from(images)) {
          try {
            // Extract the path from the URL
            Uri uri = Uri.parse(imageUrl);
            String path = uri.path;
            if (path.startsWith('/')) path = path.substring(1);
            
            // Delete the file
            await _storage.ref(path).delete();
          } catch (e) {
            print('Error deleting image: $e');
            // Continue even if image delete fails
          }
        }
      }
    }
    
    // Delete the product document
    await _firestore.collection('products').doc(productId).delete();
  }

  // Update product inventory
  Future<void> updateInventory(String productId, int quantity) {
    return _firestore
        .collection('products')
        .doc(productId)
        .update({'quantity': quantity});
  }

  // Upload multiple images and return their URLs
  Future<List<String>> _uploadImages(List<File> images) async {
    List<String> imageUrls = [];
    
    for (File image in images) {
      String fileName = 'products/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
      UploadTask uploadTask = _storage.ref().child(fileName).putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    
    return imageUrls;
  }
}