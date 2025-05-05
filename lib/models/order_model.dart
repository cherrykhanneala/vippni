import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String customerId;
  final DateTime date;
  final double total;
  final String status;
  final List<OrderItem> items;
  final Map<String, dynamic>? metadata;

  // These fields are not present in your Firestore, so make them nullable
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final ShippingInfo? shipping;
  final PaymentInfo? payment;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.date,
    required this.total,
    required this.status,
    required this.items,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.shipping,
    this.payment,
    this.metadata,
  });

  OrderModel copyWith({
    String? id,
    String? customerId,
    DateTime? date,
    double? total,
    String? status,
    List<OrderItem>? items,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    ShippingInfo? shipping,
    PaymentInfo? payment,
    Map<String, dynamic>? metadata,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      date: date ?? this.date,
      total: total ?? this.total,
      status: status ?? this.status,
      items: items ?? this.items,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      shipping: shipping ?? this.shipping,
      payment: payment ?? this.payment,
      metadata: metadata ?? this.metadata,
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

    return OrderModel(
      id: doc.id,
      customerId: data['userId'] ?? '',
      date: (data['orderDate'] as Timestamp).toDate(),
      total: (data['totalPrice'] ?? 0).toDouble(),
      status: items.isNotEmpty ? items.first.status : 'Pending',
      items: items,
      // These fields are not present in your Firestore, so set as null
      customerName: null,
      customerEmail: null,
      customerPhone: null,
      shipping: null,
      payment: null,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': customerId,
      'orderDate': Timestamp.fromDate(date),
      'totalPrice': total,
      'items': items.map((item) => item.toMap()).toList(),
      'metadata': metadata,
    };
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String status;
  final String vendorId;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.status,
    required this.vendorId,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      status: map['status'] ?? '',
      vendorId: map['vendorId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': productName,
      'quantity': quantity,
      'price': price,
      'status': status,
      'vendorId': vendorId,
    };
  }
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
