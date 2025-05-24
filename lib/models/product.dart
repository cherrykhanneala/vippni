import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final String vendorId;
  final String? imageUrl;
  final Map<String, dynamic>? postageInfo;
  final DateTime createdAt;
  
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.vendorId,
    this.imageUrl,
    this.postageInfo,
    required this.createdAt,
  });
  
  // Add this method to fix the fromMap error
  factory Product.fromMap(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 0,
      vendorId: data['vendorId'] ?? '',
      imageUrl: data['imageUrl'],
      postageInfo: data['postageInfo'],
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }
  
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 0,
      vendorId: data['vendorId'] ?? '',
      imageUrl: data['imageUrl'],
      postageInfo: data['postageInfo'],
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'vendorId': vendorId,
      'imageUrl': imageUrl,
      'postageInfo': postageInfo,
      'createdAt': createdAt,
    };
  }
  
  Product copyWith({
    String? name,
    String? description,
    double? price,
    int? quantity,
    String? imageUrl,
    Map<String, dynamic>? postageInfo,
  }) {
    return Product(
      id: this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      vendorId: this.vendorId,
      imageUrl: imageUrl ?? this.imageUrl,
      postageInfo: postageInfo ?? this.postageInfo,
      createdAt: this.createdAt,
    );
  }
}