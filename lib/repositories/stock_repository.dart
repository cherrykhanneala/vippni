import 'package:cloud_firestore/cloud_firestore.dart';

class StockRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Fetch all products for a vendor
  Future<List<DocumentSnapshot>> fetchProductsByVendor(String vendorId) async {
    final querySnapshot = await _firestore
        .collection('products')
        .where('vendorId', isEqualTo: vendorId)
        .get();
    
    return querySnapshot.docs;
  }
  
  /// Update the stock quantity for a product
  Future<void> updateStock(String productId, int newQuantity) async {
    await _firestore
        .collection('products')
        .doc(productId)
        .update({'quantity': newQuantity});
  }
  
  /// Get products with low stock (below threshold)
  Future<List<DocumentSnapshot>> getLowStockProducts(String vendorId, int threshold) async {
    final querySnapshot = await _firestore
        .collection('products')
        .where('vendorId', isEqualTo: vendorId)
        .where('quantity', isLessThanOrEqualTo: threshold)
        .get();
    
    return querySnapshot.docs;
  }
  
  /// Record stock movement
  Future<void> recordStockMovement(String productId, String type, int quantity, String? note) async {
    await _firestore.collection('stock_movements').add({
      'productId': productId,
      'type': type, // 'in' or 'out'
      'quantity': quantity,
      'timestamp': FieldValue.serverTimestamp(),
      'note': note,
    });
  }
  
  /// Get stock movement history for a product
  Future<List<DocumentSnapshot>> getStockHistory(String productId) async {
    final querySnapshot = await _firestore
        .collection('stock_movements')
        .where('productId', isEqualTo: productId)
        .orderBy('timestamp', descending: true)
        .get();
    
    return querySnapshot.docs;
  }
}