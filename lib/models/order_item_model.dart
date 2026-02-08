import 'package:flutter/material.dart';

/// Represents color information for a product variant
class ColorInfo {
  final String name;
  final String hex;

  const ColorInfo({required this.name, required this.hex});

  /// Creates ColorInfo from a Map (Firestore document)
  factory ColorInfo.fromMap(Map<String, dynamic> map) {
    return ColorInfo(name: map['name'] ?? '', hex: map['hex'] ?? '#000000');
  }

  /// Converts ColorInfo to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {'name': name, 'hex': hex};
  }

  /// Returns the Color object from hex string
  Color get color {
    String hexColor = hex.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  @override
  String toString() => 'ColorInfo(name: $name, hex: $hex)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ColorInfo && other.name == name && other.hex == hex;
  }

  @override
  int get hashCode => name.hashCode ^ hex.hashCode;
}

/// Represents an individual item in an order
class OrderItem {
  final String productId;
  final String title;
  final int quantity;
  final String price;
  final String? size;
  final ColorInfo? color;
  final String? image;
  final bool isCombo;
  final String id;
  final String uniqueKey;

  const OrderItem({
    required this.productId,
    required this.title,
    required this.quantity,
    required this.price,
    this.size,
    this.color,
    this.image,
    this.isCombo = false,
    required this.id,
    required this.uniqueKey,
  });

  /// Creates OrderItem from a Map (Firestore document)
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    // Handle color - can be String (hex code) or Map (with name and hex)
    ColorInfo? colorInfo;
    if (map['color'] != null) {
      if (map['color'] is String) {
        // Color is stored as hex string like "#FF0000"
        colorInfo = ColorInfo(name: '', hex: map['color'] as String);
      } else if (map['color'] is Map) {
        // Color is stored as Map with name and hex
        colorInfo = ColorInfo.fromMap(Map<String, dynamic>.from(map['color']));
      }
    }

    return OrderItem(
      productId: map['productId'] ?? map['id'] ?? '',
      title: map['title'] ?? map['name'] ?? '',
      quantity: (map['quantity'] ?? 1) is int
          ? map['quantity'] ?? 1
          : int.tryParse(map['quantity'].toString()) ?? 1,
      price: map['price']?.toString() ?? '0',
      size: map['size'],
      color: colorInfo,
      image: map['image'] ?? map['imageUrl'],
      isCombo: map['isCombo'] ?? false,
      id: map['id'] ?? '',
      uniqueKey:
          map['uniqueKey'] ??
          map['id'] ??
          DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  /// Converts OrderItem to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'quantity': quantity,
      'price': price,
      'size': size,
      'color': color?.toMap(),
      'image': image,
      'isCombo': isCombo,
      'id': id,
      'uniqueKey': uniqueKey,
    };
  }

  /// Gets the numeric price value
  double get priceValue {
    final cleanPrice = price.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanPrice) ?? 0.0;
  }

  /// Gets the total price for this item (price * quantity)
  double get totalPrice => priceValue * quantity;

  /// Creates a copy of OrderItem with optional field updates
  OrderItem copyWith({
    String? productId,
    String? title,
    int? quantity,
    String? price,
    String? size,
    ColorInfo? color,
    String? image,
    bool? isCombo,
    String? id,
    String? uniqueKey,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      title: title ?? this.title,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      size: size ?? this.size,
      color: color ?? this.color,
      image: image ?? this.image,
      isCombo: isCombo ?? this.isCombo,
      id: id ?? this.id,
      uniqueKey: uniqueKey ?? this.uniqueKey,
    );
  }

  @override
  String toString() {
    return 'OrderItem(productId: $productId, title: $title, quantity: $quantity, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderItem && other.uniqueKey == uniqueKey;
  }

  @override
  int get hashCode => uniqueKey.hashCode;
}
