import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_item_model.dart';

/// Enum representing the possible order statuses
enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled;

  /// Creates OrderStatus from a string value
  static OrderStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  /// Converts OrderStatus to string
  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.processing:
        return 'processing';
      case OrderStatus.shipped:
        return 'shipped';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  /// Gets the display label for the status
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Gets the step index for timeline display
  int get stepIndex {
    switch (this) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.processing:
        return 1;
      case OrderStatus.shipped:
        return 2;
      case OrderStatus.delivered:
        return 3;
      case OrderStatus.cancelled:
        return -1; // Special case
    }
  }
}

/// Enum representing the possible payment statuses
enum PaymentStatus {
  pending,
  paid;

  /// Creates PaymentStatus from a string value
  static PaymentStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'paid':
        return PaymentStatus.paid;
      case 'pending':
      default:
        return PaymentStatus.pending;
    }
  }

  /// Converts PaymentStatus to string
  String get value {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.paid:
        return 'paid';
    }
  }

  /// Gets the display label for the payment status
  String get label {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.paid:
        return 'Paid';
    }
  }
}

/// Represents a shipping address for an order
class ShippingAddress {
  final String firstName;
  final String lastName;
  final String street;
  final String landmark;
  final String city;
  final String state;
  final String pincode;
  final String phone;

  const ShippingAddress({
    this.firstName = '',
    this.lastName = '',
    required this.street,
    this.landmark = '',
    required this.city,
    required this.state,
    required this.pincode,
    required this.phone,
  });

  /// Full name combining first and last name
  String get fullName => '$firstName $lastName'.trim();

  /// Full address as a single string
  String get fullAddress {
    final parts = <String>[];
    if (street.isNotEmpty) parts.add(street);
    if (landmark.isNotEmpty) parts.add(landmark);
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (pincode.isNotEmpty) parts.add(pincode);
    return parts.join(', ');
  }

  /// Creates ShippingAddress from a Map (Firestore document)
  factory ShippingAddress.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const ShippingAddress(
        street: '',
        city: '',
        state: '',
        pincode: '',
        phone: '',
      );
    }
    return ShippingAddress(
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      street: map['streetAddress'] ?? map['street'] ?? '',
      landmark: map['landmark'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode']?.toString() ?? '',
      phone: map['mobileNumber']?.toString() ?? map['phone']?.toString() ?? '',
    );
  }

  /// Converts ShippingAddress to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'streetAddress': street,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'mobileNumber': phone,
    };
  }

  @override
  String toString() {
    return 'ShippingAddress(street: $street, city: $city, state: $state, pincode: $pincode, phone: $phone)';
  }
}

/// Represents a complete order
class Order {
  final String id;
  final String customerName;
  final String customerEmail;
  final double totalPrice;
  final int totalProducts;
  final String paymentMode;
  final String? paymentId;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final DateTime orderDate;
  final List<OrderItem> items;
  final ShippingAddress shippingAddress;
  final String? razorpayOrderId;
  final String? userId;
  final String? firestoreDocId;

  const Order({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.totalPrice,
    required this.totalProducts,
    required this.paymentMode,
    this.paymentId,
    required this.status,
    required this.paymentStatus,
    required this.orderDate,
    required this.items,
    required this.shippingAddress,
    this.razorpayOrderId,
    this.userId,
    this.firestoreDocId,
  });

  /// Checks if this is a COD order
  bool get isCOD => paymentMode.toLowerCase() == 'cod';

  /// Checks if this is an online payment order
  bool get isOnlinePayment => paymentMode.toLowerCase() == 'online';

  /// Checks if order is active (not delivered or cancelled)
  bool get isActive =>
      status != OrderStatus.delivered && status != OrderStatus.cancelled;

  /// Gets a short version of the order ID for display
  String get shortId {
    if (id.length > 8) {
      return '${id.substring(0, 8)}...';
    }
    return id;
  }

  /// Creates Order from a Firestore document
  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse items array
    final itemsList = (data['items'] as List<dynamic>? ?? [])
        .map((item) => OrderItem.fromMap(Map<String, dynamic>.from(item)))
        .toList();

    // Parse address
    final addressData = data['address'] as Map<String, dynamic>?;
    final address = ShippingAddress.fromMap(addressData);

    // Parse order date
    DateTime orderDate;
    if (data['createdAt'] is Timestamp) {
      orderDate = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      orderDate = DateTime.tryParse(data['createdAt']) ?? DateTime.now();
    } else {
      orderDate = DateTime.now();
    }

    // Calculate total products
    final totalProducts = itemsList.fold<int>(
      0,
      // ignore: avoid_types_as_parameter_names
      (sum, item) => sum + item.quantity,
    );

    // Get customer name from address
    final customerName =
        '${addressData?['firstName'] ?? ''} ${addressData?['lastName'] ?? ''}'
            .trim();

    return Order(
      id: doc.id,
      customerName: customerName.isNotEmpty ? customerName : 'Unknown',
      customerEmail: data['customerEmail'] ?? data['userEmail'] ?? '',
      totalPrice: (data['amount'] ?? 0).toDouble(),
      totalProducts: totalProducts,
      paymentMode: data['paymentMode'] ?? 'cod',
      paymentId: data['razorpayPaymentId'],
      status: OrderStatus.fromString(data['status']),
      paymentStatus: PaymentStatus.fromString(data['paymentStatus']),
      orderDate: orderDate,
      items: itemsList,
      shippingAddress: address,
      razorpayOrderId: data['razorpayOrderId'],
      userId: data['userId'],
      firestoreDocId: doc.id,
    );
  }

  /// Converts Order to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'address': shippingAddress.toMap(),
      'amount': totalPrice,
      'status': status.value,
      'paymentStatus': paymentStatus.value,
      'paymentMode': paymentMode,
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': paymentId,
      'createdAt': Timestamp.fromDate(orderDate),
      'customerEmail': customerEmail,
    };
  }

  /// Creates a copy of Order with optional field updates
  Order copyWith({
    String? id,
    String? customerName,
    String? customerEmail,
    double? totalPrice,
    int? totalProducts,
    String? paymentMode,
    String? paymentId,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    DateTime? orderDate,
    List<OrderItem>? items,
    ShippingAddress? shippingAddress,
    String? razorpayOrderId,
    String? userId,
    String? firestoreDocId,
  }) {
    return Order(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      totalPrice: totalPrice ?? this.totalPrice,
      totalProducts: totalProducts ?? this.totalProducts,
      paymentMode: paymentMode ?? this.paymentMode,
      paymentId: paymentId ?? this.paymentId,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderDate: orderDate ?? this.orderDate,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      userId: userId ?? this.userId,
      firestoreDocId: firestoreDocId ?? this.firestoreDocId,
    );
  }

  @override
  String toString() {
    return 'Order(id: $id, customerName: $customerName, totalPrice: $totalPrice, status: ${status.label})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
