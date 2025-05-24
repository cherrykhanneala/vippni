import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderModel {
  final String id;
  final String orderNumber;
  final String customerId;
  final DateTime date;
  final double totalPrice; // This is what we use throughout
  final String status;
  final List<OrderItem> items;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? payment;
  final Map<String, dynamic>? shipping;

  // Customer details fetched separately
  final String? customerName;
  final String? customerEmail;
  final Map<String, dynamic>? customerAddress;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.date,
    required this.totalPrice, // Changed from total
    required this.status,
    required this.items,
    this.metadata,
    this.payment,
    this.shipping,
    this.customerName,
    this.customerEmail,
    this.customerAddress,
  });

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    DateTime? date,
    double? totalPrice,
    String? status,
    List<OrderItem>? items,
    String? customerName,
    String? customerEmail,
    Map<String, dynamic>? customerAddress,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? payment,
    Map<String, dynamic>? shipping,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      date: date ?? this.date,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      items: items ?? this.items,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerAddress: customerAddress ?? this.customerAddress,
      metadata: metadata ?? this.metadata,
      payment: payment ?? this.payment,
      shipping: shipping ?? this.shipping,
    );
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    List<OrderItem> items = [];
    if (data['items'] != null) {
      items = (data['items'] as List)
          .map((item) => OrderItem.fromMap(item))
          .toList();
    }

    // Get status from first item that matches vendor ID
    final currentVendorId = FirebaseAuth.instance.currentUser?.uid;
    final vendorItems = items.where((item) => item.vendorId == currentVendorId).toList();
    final status = vendorItems.isNotEmpty ? vendorItems.first.status : 'Pending';

    // Add safe type checking for shipping and payment
    Map<String, dynamic>? shippingData;
    if (data['shipping'] != null && data['shipping'] is Map) {
      shippingData = Map<String, dynamic>.from(data['shipping'] as Map);
    }

    Map<String, dynamic>? paymentData;
    if (data['payment'] != null && data['payment'] is Map) {
      paymentData = Map<String, dynamic>.from(data['payment'] as Map);
    }

    return OrderModel(
      id: doc.id,
      orderNumber: data['orderNumber'] ?? '',
      customerId: data['userId'] ?? '',
      date: (data['orderDate'] as Timestamp).toDate(),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      status: status, // Use vendor's item status
      items: items,
      customerName: null,
      customerEmail: null,
      customerAddress: null,
      shipping: shippingData,
      payment: paymentData,
      metadata: data['metadata'] is Map ? Map<String, dynamic>.from(data['metadata'] as Map) : null,
    );
  }

  static Future<OrderModel> fromFirestoreWithCustomer(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    
    // Fetch customer details
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(data['userId'])
        .get();
    
    final userData = userDoc.data();

    List<OrderItem> items = [];
    if (data['items'] != null) {
      items = (data['items'] as List)
          .map((item) => OrderItem.fromMap(item))
          .toList();
    }

    // Get status from first item that matches vendor ID (same logic as fromFirestore)
    final currentVendorId = FirebaseAuth.instance.currentUser?.uid;
    final vendorItems = items.where((item) => item.vendorId == currentVendorId).toList();
    final status = vendorItems.isNotEmpty ? vendorItems.first.status : 'Pending';

    // Add safe type checking for shipping and payment
    Map<String, dynamic>? shippingData;
    if (data['shipping'] != null && data['shipping'] is Map) {
      shippingData = Map<String, dynamic>.from(data['shipping'] as Map);
    }

    Map<String, dynamic>? paymentData;
    if (data['payment'] != null && data['payment'] is Map) {
      paymentData = Map<String, dynamic>.from(data['payment'] as Map);
    }

    return OrderModel(
      id: doc.id,
      orderNumber: data['orderNumber'] ?? '',
      customerId: data['userId'] ?? '',
      date: (data['orderDate'] as Timestamp).toDate(),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      status: status, // Use vendor's item status
      items: items,
      customerName: userData?['fullName'],
      customerEmail: userData?['email'],
      customerAddress: userData?['address'],
      shipping: shippingData,
      payment: paymentData,
      metadata: data['metadata'] is Map ? Map<String, dynamic>.from(data['metadata'] as Map) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderNumber': orderNumber,
      'userId': customerId,
      'orderDate': Timestamp.fromDate(date),
      'totalPrice': totalPrice,
      // Don't include global status in map since we're using per-item status
      'items': items.map((item) => item.toMap()).toList(),
      'metadata': metadata,
      'payment': payment,
      'shipping': shipping,
    };
  }
}

class OrderItem {
  final String productId;
  final String name; // Changed from productName to match Firebase
  final int quantity;
  final double price; // Changed to double to handle both int and double
  final String status;
  final String vendorId;
  final String? trackingNumber;
  final double? weight; // Direct field for weight
  final String? size; // Direct field for size
  final String? shippingCost;

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.status,
    required this.vendorId,
    this.trackingNumber,
    this.weight,
    this.size,
    this.shippingCost,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      status: map['status'] ?? 'Pending',
      vendorId: map['vendorId'] ?? '',
      trackingNumber: map['trackingNumber'],
      weight: map['weight'] != null
          ? (map['weight'] is String
              ? double.tryParse(map['weight']) ?? 0.0
              : (map['weight'] as num).toDouble())
          : null,
      size: map['size'],
      shippingCost: map['shippingCost'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'status': status,
      'vendorId': vendorId,
      'trackingNumber': trackingNumber,
      'weight': weight,
      'size': size,
      'shippingCost': shippingCost,
    };
  }

  Future<void> copyWith({required String status}) async {}
}

// ShippingInfo and PaymentInfo classes can remain, but are not used in your current Firestore structure.

class ShippingInfo {
  final String name;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String? trackingNumber;
  final String? carrier;
  final DateTime? shippedDate;
  final DateTime? estimatedDelivery;

  ShippingInfo({
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.trackingNumber,
    this.carrier,
    this.shippedDate,
    this.estimatedDelivery,
  });

  factory ShippingInfo.fromMap(Map<String, dynamic> map) {
    return ShippingInfo(
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      postalCode: map['postalCode'] ?? '',
      country: map['country'] ?? '',
      trackingNumber: map['trackingNumber'],
      carrier: map['carrier'],
      shippedDate: map['shippedDate'] != null 
          ? (map['shippedDate'] as Timestamp).toDate() 
          : null,
      estimatedDelivery: map['estimatedDelivery'] != null 
          ? (map['estimatedDelivery'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'trackingNumber': trackingNumber,
      'carrier': carrier,
      'shippedDate': shippedDate != null ? Timestamp.fromDate(shippedDate!) : null,
      'estimatedDelivery': estimatedDelivery != null ? Timestamp.fromDate(estimatedDelivery!) : null,
    };
  }
}

class PaymentInfo {
  final String method;
  final String status;
  final String? transactionId;
  final DateTime? paidAt;

  PaymentInfo({
    required this.method,
    required this.status,
    this.transactionId,
    this.paidAt,
  });

  factory PaymentInfo.fromMap(Map<String, dynamic> map) {
    return PaymentInfo(
      method: map['method'] ?? '',
      status: map['status'] ?? '',
      transactionId: map['transactionId'],
      paidAt: map['paidAt'] != null 
          ? (map['paidAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'method': method,
      'status': status,
      'transactionId': transactionId,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
    };
  }
}
