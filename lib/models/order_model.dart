import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final DateTime date;
  final double total;
  final String status;
  final List<OrderItem> items;
  final ShippingInfo shipping;
  final PaymentInfo payment;
  final Map<String, dynamic>? metadata;
  
  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.date,
    required this.total,
    required this.status,
    required this.items,
    required this.shipping,
    required this.payment,
    this.metadata,
  });
  
  // Create a copy with updated fields
  OrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    DateTime? date,
    double? total,
    String? status,
    List<OrderItem>? items,
    ShippingInfo? shipping,
    PaymentInfo? payment,
    Map<String, dynamic>? metadata,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      date: date ?? this.date,
      total: total ?? this.total,
      status: status ?? this.status,
      items: items ?? this.items,
      shipping: shipping ?? this.shipping,
      payment: payment ?? this.payment,
      metadata: metadata ?? this.metadata,
    );
  }
  
  // Create from Firestore document
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse items
    List<OrderItem> items = [];
    if (data['items'] != null) {
      items = (data['items'] as List).map((item) => OrderItem.fromMap(item)).toList();
    }
    
    // Parse shipping info
    ShippingInfo shipping = ShippingInfo.fromMap(data['shipping'] ?? {});
    
    // Parse payment info
    PaymentInfo payment = PaymentInfo.fromMap(data['payment'] ?? {});
    
    return OrderModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerEmail: data['customerEmail'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      total: (data['total'] ?? 0).toDouble(),
      status: data['status'] ?? 'Pending',
      items: items,
      shipping: shipping,
      payment: payment,
      metadata: data['metadata'],
    );
  }
  
  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'date': Timestamp.fromDate(date),
      'total': total,
      'status': status,
      'items': items.map((item) => item.toMap()).toList(),
      'shipping': shipping.toMap(),
      'payment': payment.toMap(),
      'metadata': metadata,
    };
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double total;
  final String? imageUrl;
  final Map<String, dynamic>? options;
  
  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
    this.imageUrl,
    this.options,
  });
  
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'],
      options: map['options'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'total': total,
      'imageUrl': imageUrl,
      'options': options,
    };
  }
}

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
