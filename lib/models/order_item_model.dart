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
  // Bundle-specific fields
  final String? bundleId;
  final bool isBundleItem;
  final String? bundlePrice;
  final String? bundleName;
  final String? originalIndividualPrice;
  final Map<String, String>?
  bundleProductSizes; // Maps productId -> size for bundle items
  final List<Map<String, dynamic>>?
  bundleProducts; // List of products in the bundle with details

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
    this.bundleId,
    this.isBundleItem = false,
    this.bundlePrice,
    this.bundleName,
    this.originalIndividualPrice,
    this.bundleProductSizes,
    this.bundleProducts,
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
      bundleId: map['bundleId'],
      isBundleItem: map['isBundleItem'] ?? false,
      bundlePrice: map['bundlePrice']?.toString(),
      bundleName: map['bundleName'],
      originalIndividualPrice: map['originalIndividualPrice']?.toString(),
      bundleProductSizes: map['bundleProductSizes'] != null
          ? Map<String, String>.from(map['bundleProductSizes'])
          : null,
      bundleProducts: map['bundleProducts'] != null
          ? List<Map<String, dynamic>>.from(
              (map['bundleProducts'] as List).map(
                (item) => Map<String, dynamic>.from(item),
              ),
            )
          : null,
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
      'bundleId': bundleId,
      'isBundleItem': isBundleItem,
      'bundlePrice': bundlePrice,
      'bundleName': bundleName,
      'originalIndividualPrice': originalIndividualPrice,
      'bundleProductSizes': bundleProductSizes,
      'bundleProducts': bundleProducts,
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
    String? bundleId,
    bool? isBundleItem,
    String? bundlePrice,
    String? bundleName,
    String? originalIndividualPrice,
    Map<String, String>? bundleProductSizes,
    List<Map<String, dynamic>>? bundleProducts,
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
      bundleId: bundleId ?? this.bundleId,
      isBundleItem: isBundleItem ?? this.isBundleItem,
      bundlePrice: bundlePrice ?? this.bundlePrice,
      bundleName: bundleName ?? this.bundleName,
      originalIndividualPrice:
          originalIndividualPrice ?? this.originalIndividualPrice,
      bundleProductSizes: bundleProductSizes ?? this.bundleProductSizes,
      bundleProducts: bundleProducts ?? this.bundleProducts,
    );
  }

  /// Gets the numeric bundle price value
  double get bundlePriceValue {
    if (bundlePrice == null) return 0.0;
    final cleanPrice = bundlePrice!.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanPrice) ?? 0.0;
  }

  /// Gets the numeric original individual price value
  double get originalIndividualPriceValue {
    if (originalIndividualPrice == null) return 0.0;
    final cleanPrice = originalIndividualPrice!.replaceAll(
      RegExp(r'[^\d.]'),
      '',
    );
    return double.tryParse(cleanPrice) ?? 0.0;
  }

  /// Gets the savings from bundle discount
  double get bundleSavings =>
      (originalIndividualPriceValue - bundlePriceValue) * quantity;

  /// Gets the size for a specific product in the bundle
  /// Returns the size if found, or empty string if not available
  String getProductSizeInBundle(String productId) {
    if (bundleProductSizes == null) return '';
    return bundleProductSizes![productId] ?? '';
  }

  /// Gets all product sizes in the bundle
  /// Returns a map of productId -> size
  Map<String, String> getAllBundleProductSizes() {
    return bundleProductSizes ?? {};
  }

  /// Gets a formatted string of all bundle product sizes
  /// Format: "Product1: XL, Product2: M"
  String formatBundleProductSizes() {
    if (bundleProductSizes == null || bundleProductSizes!.isEmpty) {
      return '';
    }
    return bundleProductSizes!.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
  }

  /// Gets all products in the bundle
  /// Returns list of product maps with productId, title, quantity, price, image, size
  List<Map<String, dynamic>> getBundleProducts() {
    return bundleProducts ?? [];
  }

  /// Gets the count of products in the bundle
  int getBundleProductCount() {
    return bundleProducts?.length ?? 0;
  }

  /// Gets a product from the bundle by productId
  Map<String, dynamic>? getBundleProduct(String productId) {
    if (bundleProducts == null) return null;
    try {
      return bundleProducts!.firstWhere(
        (product) => product['productId'] == productId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Gets formatted bundle products list for display
  /// Format: "Product1 (XL), Product2 (M), Product3 (L)"
  String formatBundleProductsList() {
    if (bundleProducts == null || bundleProducts!.isEmpty) {
      return '';
    }
    return bundleProducts!
        .map((p) {
          final title = p['title'] ?? p['productId'] ?? 'Unknown';
          final size = p['size'] ?? bundleProductSizes?[p['productId']] ?? '';
          return size.isNotEmpty ? '$title ($size)' : title;
        })
        .join(', ');
  }

  @override
  String toString() {
    return 'OrderItem(productId: $productId, title: $title, quantity: $quantity, price: $price, isBundleItem: $isBundleItem, bundleName: $bundleName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderItem && other.uniqueKey == uniqueKey;
  }

  @override
  int get hashCode => uniqueKey.hashCode;
}
