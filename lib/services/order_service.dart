import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../utils/constants.dart';

/// Service class for handling Order operations with Firebase Firestore
class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Reference to orders collection
  CollectionReference<Map<String, dynamic>> get _ordersRef =>
      _firestore.collection(kOrdersCollection);

  /// Reference to users collection
  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection(kUsersCollection);

  /// Reference to bundles collection
  CollectionReference<Map<String, dynamic>> get _bundlesRef =>
      _firestore.collection('bundles');

  /// Reference to products collection
  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection('products');

  /// Get all orders stream (for admin)
  /// Returns a real-time stream of all orders sorted by date
  Stream<List<Order>> getOrdersStream() {
    return _ordersRef
        .snapshots()
        .asyncMap((snapshot) async {
          final orders = <Order>[];

          for (final doc in snapshot.docs) {
            try {
              var order = Order.fromFirestore(doc);

              // Fetch customer email if not present
              if (order.customerEmail.isEmpty && order.userId != null) {
                final email = await fetchUserEmail(order.userId!);
                order = order.copyWith(customerEmail: email);
              }

              // Enrich with bundle details if order contains bundle items
              if (hasOrderBundleItems(order)) {
                order = await enrichOrderWithBundleDetails(order);
              }

              orders.add(order);
            } catch (e) {
              // Silently handle error parsing order
            }
          }

          // Sort by createdAt descending
          orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
          return orders;
        })
        .handleError((e) {
          return <Order>[];
        });
  }

  /// Get orders by user ID stream (for customer)
  /// Returns a real-time stream of orders for a specific user
  Stream<List<Order>> getUserOrdersStream(String userId) {
    return _ordersRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
          final orders = <Order>[];

          for (final doc in snapshot.docs) {
            try {
              var order = Order.fromFirestore(doc);

              // Enrich with bundle details if order contains bundle items
              if (hasOrderBundleItems(order)) {
                order = await enrichOrderWithBundleDetails(order);
              }

              orders.add(order);
            } catch (e) {
              // Silently handle error parsing order
            }
          }

          // Sort by createdAt descending
          orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
          return orders;
        })
        .handleError((e) {
          return <Order>[];
        });
  }

  /// Get a single order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final doc = await _ordersRef.doc(orderId).get();
      if (!doc.exists) return null;

      var order = Order.fromFirestore(doc);

      // Fetch customer email if not present
      if (order.customerEmail.isEmpty && order.userId != null) {
        final email = await fetchUserEmail(order.userId!);
        order = order.copyWith(customerEmail: email);
      }

      // Enrich with bundle details if order contains bundle items
      if (hasOrderBundleItems(order)) {
        order = await enrichOrderWithBundleDetails(order);
      }

      return order;
    } catch (e) {
      return null;
    }
  }

  /// Get a single order stream by ID
  Stream<Order?> getOrderStream(String orderId) {
    return _ordersRef.doc(orderId).snapshots().asyncMap((doc) async {
      if (!doc.exists) return null;

      try {
        var order = Order.fromFirestore(doc);

        // Fetch customer email if not present
        if (order.customerEmail.isEmpty && order.userId != null) {
          final email = await fetchUserEmail(order.userId!);
          order = order.copyWith(customerEmail: email);
        }

        // Enrich with bundle details if order contains bundle items
        if (hasOrderBundleItems(order)) {
          order = await enrichOrderWithBundleDetails(order);
        }

        return order;
      } catch (e) {
        return null;
      }
    });
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      // Get current order to fetch existing statusHistory
      final doc = await _ordersRef.doc(orderId).get();
      if (!doc.exists) {
        throw 'Order not found';
      }

      final data = doc.data() as Map<String, dynamic>;
      final statusHistory = List<Map<String, dynamic>>.from(
        data['statusHistory'] ?? [],
      );

      // Add new status history entry
      statusHistory.add({
        'status': status.value,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Update order with new status and status history
      await _ordersRef.doc(orderId).update({
        'status': status.value,
        'statusHistory': statusHistory,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw kErrorUpdateStatus;
    }
  }

  /// Update payment status
  Future<void> updatePaymentStatus(
    String orderId,
    PaymentStatus paymentStatus,
  ) async {
    try {
      await _ordersRef.doc(orderId).update({
        'paymentStatus': paymentStatus.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw kErrorUpdateStatus;
    }
  }

  /// Update both order and payment status
  Future<void> updateOrderAndPaymentStatus(
    String orderId,
    OrderStatus orderStatus,
    PaymentStatus paymentStatus,
  ) async {
    try {
      // Get current order to fetch existing statusHistory
      final doc = await _ordersRef.doc(orderId).get();
      if (!doc.exists) {
        throw 'Order not found';
      }

      final data = doc.data() as Map<String, dynamic>;
      final statusHistory = List<Map<String, dynamic>>.from(
        data['statusHistory'] ?? [],
      );

      // Add new status history entry
      statusHistory.add({
        'status': orderStatus.value,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Update order with new statuses and status history
      await _ordersRef.doc(orderId).update({
        'status': orderStatus.value,
        'paymentStatus': paymentStatus.value,
        'statusHistory': statusHistory,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw kErrorUpdateStatus;
    }
  }

  /// Fetch user email from users collection
  Future<String> fetchUserEmail(String userId) async {
    try {
      final doc = await _usersRef.doc(userId).get();
      if (doc.exists) {
        return doc.data()?['email'] ?? '';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  /// Fetch product details by product ID
  /// Returns complete product information from the products collection
  Future<Map<String, dynamic>?> fetchProductDetails(String productId) async {
    try {
      final doc = await _productsRef.doc(productId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetch bundle details by bundle ID
  /// Returns the complete bundle document from the bundles collection
  Future<Map<String, dynamic>?> getBundleDetails(String bundleId) async {
    try {
      final doc = await _bundlesRef.doc(bundleId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get all products in a bundle with their details
  Future<List<Map<String, dynamic>>> getBundleProducts(String bundleId) async {
    try {
      final bundleDoc = await _bundlesRef.doc(bundleId).get();
      if (!bundleDoc.exists) return [];

      final bundleData = bundleDoc.data() as Map<String, dynamic>;
      final products = List<Map<String, dynamic>>.from(
        bundleData['products'] ?? [],
      );

      return products;
    } catch (e) {
      return [];
    }
  }

  /// Get all products in a bundle with enriched details including sizes
  /// This method is useful when you need complete product information with sizes
  /// from the order context
  Future<List<Map<String, dynamic>>> getBundleProductsEnriched(
    String bundleId,
    Map<String, String> productSizes,
  ) async {
    try {
      final products = await getBundleProducts(bundleId);

      // Enrich each product with size information
      return products.map((product) {
        final productId = product['productId'] as String?;
        final size = productId != null
            ? productSizes[productId] ?? product['size'] ?? ''
            : product['size'] ?? '';

        return {...product, 'size': size, 'quantity': product['quantity'] ?? 1};
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Check if an order contains bundle items
  bool hasOrderBundleItems(Order order) {
    return order.items.any((item) => item.isBundleItem);
  }

  /// Get all unique bundle IDs from an order
  List<String> getOrderBundleIds(Order order) {
    final bundleIds = <String>{};
    for (final item in order.items) {
      if (item.isBundleItem && item.bundleId != null) {
        bundleIds.add(item.bundleId!);
      }
    }
    return bundleIds.toList();
  }

  /// Get bundle items from an order
  List<Map<String, dynamic>> getBundleItemsFromOrder(Order order) {
    final items = <Map<String, dynamic>>[];

    for (final item in order.items) {
      if (item.isBundleItem) {
        items.add({
          'productId': item.productId,
          'bundleId': item.bundleId,
          'bundleName': item.bundleName,
          'title': item.title,
          'quantity': item.quantity,
          'bundlePrice': item.bundlePrice,
          'originalIndividualPrice': item.originalIndividualPrice,
          'image': item.image,
          'savings': item.bundleSavings,
        });
      }
    }

    return items;
  }

  /// Enrich an order with complete bundle details from bundles collection
  /// This fetches the bundle data and attaches it to bundle items
  /// Also enriches with complete product information and sizes
  Future<Order> enrichOrderWithBundleDetails(Order order) async {
    if (!hasOrderBundleItems(order)) {
      return order; // No bundle items, return original order
    }

    try {
      final enrichedItems = <OrderItem>[];

      for (final item in order.items) {
        if (item.isBundleItem && item.bundleId != null) {
          // Fetch bundle details from bundles collection
          final bundleDetails = await getBundleDetails(item.bundleId!);

          if (bundleDetails != null) {
            // Enrich bundle products with sizes and complete details
            final bundleProducts = await _enrichBundleProductsWithSizes(
              item,
              bundleDetails,
            );

            // Enrich the item with additional bundle data
            final enrichedItem = item.copyWith(
              bundleName: bundleDetails['name'] ?? item.bundleName,
              bundlePrice: (bundleDetails['bundlePrice'] ?? item.bundlePrice)
                  ?.toString(),
              originalIndividualPrice:
                  (bundleDetails['originalTotalPrice'] ??
                          item.originalIndividualPrice)
                      ?.toString(),
              bundleProducts: bundleProducts, // Attach enriched products
            );
            enrichedItems.add(enrichedItem);
          } else {
            // Bundle not found, keep original item
            enrichedItems.add(item);
          }
        } else {
          // Not a bundle item, keep unchanged
          enrichedItems.add(item);
        }
      }

      // Return order with enriched items
      return order.copyWith(items: enrichedItems);
    } catch (e) {
      // On error, return original order
      return order;
    }
  }

  /// Private helper method to enrich bundle products with sizes
  /// Fetches full product details and matches with their sizes
  Future<List<Map<String, dynamic>>> _enrichBundleProductsWithSizes(
    OrderItem bundleItem,
    Map<String, dynamic> bundleDetails,
  ) async {
    try {
      final productsFromBundle = List<Map<String, dynamic>>.from(
        bundleDetails['products'] ?? [],
      );
      final productSizes = bundleItem.bundleProductSizes ?? {};

      final enrichedProducts = <Map<String, dynamic>>[];

      // Enrich each product with full details and size
      for (final product in productsFromBundle) {
        final productId = product['productId'] as String?;
        final size = productId != null
            ? productSizes[productId] ?? product['size'] ?? ''
            : product['size'] ?? '';

        // Fetch full product details from products collection if productId exists
        if (productId != null && productId.isNotEmpty) {
          final fullProductDetails = await fetchProductDetails(productId);

          if (fullProductDetails != null) {
            // Use full product details from products collection
            enrichedProducts.add({
              'productId': productId,
              'title':
                  fullProductDetails['name'] ??
                  fullProductDetails['title'] ??
                  product['title'] ??
                  'Unknown Product',
              'price': fullProductDetails['price'] ?? product['price'] ?? '0',
              'image':
                  fullProductDetails['image'] ??
                  fullProductDetails['imageUrl'] ??
                  product['image'],
              'quantity': product['quantity'] ?? 1,
              'size': size,
            });
          } else {
            // Fallback to bundle product data if full details not found
            enrichedProducts.add({
              ...product,
              'title': product['title'] ?? 'Unknown Product',
              'size': size,
              'quantity': product['quantity'] ?? 1,
            });
          }
        } else {
          // No productId, use bundle data as is
          enrichedProducts.add({
            ...product,
            'title': product['title'] ?? 'Unknown Product',
            'size': size,
            'quantity': product['quantity'] ?? 1,
          });
        }
      }

      return enrichedProducts;
    } catch (e) {
      // Return bundle products from item if enrichment fails
      return bundleItem.bundleProducts ?? [];
    }
  }

  /// Get a summary of bundle information for an order
  /// Returns details about all bundles in the order
  Future<List<Map<String, dynamic>>> getOrderBundleSummary(Order order) async {
    if (!hasOrderBundleItems(order)) {
      return [];
    }

    try {
      final bundleIds = getOrderBundleIds(order);
      final bundleSummary = <Map<String, dynamic>>[];

      for (final bundleId in bundleIds) {
        final bundleDetails = await getBundleDetails(bundleId);
        if (bundleDetails != null) {
          final bundleItems = order.items
              .where((item) => item.bundleId == bundleId)
              .map(
                (item) => ({
                  'productId': item.productId,
                  'title': item.title,
                  'quantity': item.quantity,
                  'image': item.image,
                }),
              )
              .toList();

          bundleSummary.add({
            'bundleId': bundleId,
            'name': bundleDetails['name'],
            'description': bundleDetails['description'],
            'bundlePrice': bundleDetails['bundlePrice'],
            'originalTotalPrice': bundleDetails['originalTotalPrice'],
            'discount': bundleDetails['discount'],
            'image': bundleDetails['image'],
            'itemCount': bundleItems.length,
            'items': bundleItems,
            'category': bundleDetails['category'],
          });
        }
      }

      return bundleSummary;
    } catch (e) {
      return [];
    }
  }

  /// Get product sizes from a bundle item in an order
  /// Returns a map of productId -> size
  Map<String, String> getBundleProductSizes(OrderItem bundleItem) {
    return bundleItem.getAllBundleProductSizes();
  }

  /// Get size for a specific product in a bundle item
  String getProductSizeInBundle(OrderItem bundleItem, String productId) {
    return bundleItem.getProductSizeInBundle(productId);
  }

  /// Get all bundle items with their product sizes from an order
  /// Returns list of maps with bundle info and sizes
  List<Map<String, dynamic>> getBundleItemsWithSizes(Order order) {
    final items = <Map<String, dynamic>>[];

    for (final item in order.items) {
      if (item.isBundleItem) {
        final productSizes = item.getAllBundleProductSizes();
        items.add({
          'productId': item.productId,
          'bundleId': item.bundleId,
          'bundleName': item.bundleName,
          'title': item.title,
          'quantity': item.quantity,
          'bundlePrice': item.bundlePrice,
          'originalIndividualPrice': item.originalIndividualPrice,
          'image': item.image,
          'savings': item.bundleSavings,
          'productSizes': productSizes, // Maps productId -> size
        });
      }
    }

    return items;
  }

  /// Get formatted sizes string for a bundle item
  /// Example: "prod_001: XL, prod_002: M, prod_003: L"
  String formatBundleProductSizes(OrderItem bundleItem) {
    return bundleItem.formatBundleProductSizes();
  }

  /// Get all sizes in an order (both bundle and regular items)
  /// Returns map with bundle items having productSizes field
  Map<String, dynamic> getOrderSizesInfo(Order order) {
    final regularItems = <Map<String, dynamic>>[];
    final bundleItems = <Map<String, dynamic>>[];

    for (final item in order.items) {
      if (item.isBundleItem) {
        bundleItems.add({
          'title': item.title,
          'bundleName': item.bundleName,
          'productSizes': item.getAllBundleProductSizes(),
        });
      } else if (item.size != null && item.size!.isNotEmpty) {
        regularItems.add({
          'title': item.title,
          'size': item.size,
          'quantity': item.quantity,
        });
      }
    }

    return {
      'regularItems': regularItems,
      'bundleItems': bundleItems,
      'hasBundles': bundleItems.isNotEmpty,
      'hasRegularSizedItems': regularItems.isNotEmpty,
    };
  }

  /// Get bundle products with sizes for display
  /// Returns list of products with all details including sizes
  List<Map<String, dynamic>> getBundleProductsWithDetails(
    OrderItem bundleItem,
  ) {
    if (!bundleItem.isBundleItem) return [];

    // First check if bundleProducts are already enriched
    final products = bundleItem.getBundleProducts();
    if (products.isEmpty) return [];

    final sizes = bundleItem.getAllBundleProductSizes();

    return products.map((product) {
      final productId = product['productId'] as String?;
      final storedSize = product['size'] as String? ?? '';

      // Use the size from bundleProductSizes if available, otherwise use stored size
      final finalSize = productId != null && sizes.containsKey(productId)
          ? sizes[productId]!
          : storedSize;

      return {
        ...product,
        'size': finalSize,
        'quantity': product['quantity'] ?? 1,
        'price': product['price'] ?? '0',
        'image': product['image'] ?? '',
        'displayText': _buildProductDisplayText(product, finalSize),
      };
    }).toList();
  }

  /// Build formatted text for product display
  String _buildProductDisplayText(Map<String, dynamic> product, String? size) {
    final title = product['title'] ?? product['productId'] ?? 'Unknown';
    final quantity = product['quantity'] ?? 1;
    final price = product['price'] ?? '0';

    final parts = <String>[title];

    if (quantity > 1) {
      parts.add('(Qty: $quantity)');
    }

    if (size != null && size.isNotEmpty) {
      parts.add('Size: $size');
    }

    parts.add('₹$price');

    return parts.join(' • ');
  }

  /// Get a summary of all products in bundle items from an order
  List<Map<String, dynamic>> getOrderBundleProductsSummary(Order order) {
    final summary = <Map<String, dynamic>>[];

    for (final item in order.items) {
      if (item.isBundleItem) {
        final products = getBundleProductsWithDetails(item);

        summary.add({
          'bundleId': item.bundleId,
          'bundleName': item.bundleName,
          'bundlePrice': item.bundlePrice,
          'originalPrice': item.originalIndividualPrice,
          'products': products,
          'productCount': products.length,
        });
      }
    }

    return summary;
  }

  /// Filter and search orders
  List<Order> filterOrders(
    List<Order> orders,
    String query,
    String statusFilter,
  ) {
    var filteredOrders = orders;

    // Filter by status
    if (statusFilter.isNotEmpty && statusFilter.toLowerCase() != 'all') {
      final status = OrderStatus.fromString(statusFilter);
      filteredOrders = filteredOrders
          .where((order) => order.status == status)
          .toList();
    }

    // Filter by search query
    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filteredOrders = filteredOrders.where((order) {
        return order.customerName.toLowerCase().contains(lowerQuery) ||
            order.customerEmail.toLowerCase().contains(lowerQuery) ||
            order.id.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    return filteredOrders;
  }

  /// Get current orders (pending, processing, shipped)
  List<Order> getCurrentOrders(List<Order> orders) {
    return orders.where((order) {
      return order.status == OrderStatus.pending ||
          order.status == OrderStatus.processing ||
          order.status == OrderStatus.shipped;
    }).toList();
  }

  /// Get previous orders (delivered, cancelled)
  List<Order> getPreviousOrders(List<Order> orders) {
    return orders.where((order) {
      return order.status == OrderStatus.delivered ||
          order.status == OrderStatus.cancelled;
    }).toList();
  }

  /// Get order statistics
  Map<String, int> getOrderStats(List<Order> orders) {
    final stats = {
      'total': orders.length,
      'pending': 0,
      'processing': 0,
      'shipped': 0,
      'delivered': 0,
      'cancelled': 0,
    };

    for (final order in orders) {
      switch (order.status) {
        case OrderStatus.pending:
          stats['pending'] = stats['pending']! + 1;
          break;
        case OrderStatus.processing:
          stats['processing'] = stats['processing']! + 1;
          break;
        case OrderStatus.shipped:
          stats['shipped'] = stats['shipped']! + 1;
          break;
        case OrderStatus.delivered:
          stats['delivered'] = stats['delivered']! + 1;
          break;
        case OrderStatus.cancelled:
          stats['cancelled'] = stats['cancelled']! + 1;
          break;
      }
    }

    return stats;
  }

  /// Get paginated orders
  List<Order> getPaginatedOrders(List<Order> orders, int page, int pageSize) {
    final startIndex = (page - 1) * pageSize;
    if (startIndex >= orders.length) return [];

    final endIndex = startIndex + pageSize;
    return orders.sublist(
      startIndex,
      endIndex > orders.length ? orders.length : endIndex,
    );
  }

  /// Check if more pages available
  bool hasMorePages(List<Order> orders, int page, int pageSize) {
    return page * pageSize < orders.length;
  }

  /// Create a new order (for testing purposes)
  Future<String> createOrder(Order order) async {
    try {
      final docRef = await _ordersRef.add(order.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Failed to create order';
    }
  }

  /// Delete an order
  Future<void> deleteOrder(String orderId) async {
    try {
      await _ordersRef.doc(orderId).delete();
    } catch (e) {
      throw 'Failed to delete order';
    }
  }

  /// Get total revenue from delivered orders
  double getTotalRevenue(List<Order> orders) {
    return orders
        .where((order) => order.status == OrderStatus.delivered)
        .fold(0.0, (total, order) => total + order.totalPrice);
  }

  /// Get orders by date range
  List<Order> getOrdersByDateRange(
    List<Order> orders,
    DateTime startDate,
    DateTime endDate,
  ) {
    return orders.where((order) {
      return order.orderDate.isAfter(startDate) &&
          order.orderDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Search orders by email or phone number (for guest users)
  /// Returns a stream of orders matching the provided email or phone
  Stream<List<Order>> searchOrdersByContactInfo({
    String? email,
    String? phone,
  }) {
    if ((email == null || email.isEmpty) && (phone == null || phone.isEmpty)) {
      return Stream.value([]);
    }

    // Build filter conditions
    final filters = <String, dynamic>{};
    if (email != null && email.isNotEmpty) {
      filters['by_email'] = true;
      filters['value'] = email.toLowerCase();
    } else if (phone != null && phone.isNotEmpty) {
      filters['by_phone'] = true;
      filters['value'] = phone.toString();
    }

    return _ordersRef
        .snapshots()
        .map((snapshot) {
          final orders = <Order>[];

          for (final doc in snapshot.docs) {
            try {
              var order = Order.fromFirestore(doc);

              // Filter by email if provided
              if (email != null && email.isNotEmpty) {
                if (order.customerEmail.toLowerCase() == email.toLowerCase() ||
                    order.shippingAddress.phone == email) {
                  orders.add(order);
                }
              }
              // Filter by phone if provided
              else if (phone != null && phone.isNotEmpty) {
                if (order.shippingAddress.phone == phone) {
                  orders.add(order);
                }
              }
            } catch (e) {
              // Silently handle error parsing order
            }
          }

          // Sort by created date descending
          orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
          return orders;
        })
        .handleError((e) {
          return <Order>[];
        });
  }

  /// Format order details for display
  /// Returns human-readable string representation of order information
  String formatOrderDetailsForDisplay(Order order) {
    final buffer = StringBuffer();

    buffer.writeln('Order ID: ${order.id}');
    buffer.writeln('Customer: ${order.customerName}');
    buffer.writeln('Email: ${order.customerEmail}');
    buffer.writeln('Phone: ${order.shippingAddress.phone}');
    buffer.writeln('Status: ${order.status.label}');
    buffer.writeln('Payment: ${order.paymentStatus.label}');
    buffer.writeln('Amount: ₹${order.totalPrice}');
    buffer.writeln('---');

    for (final item in order.items) {
      if (item.isBundleItem) {
        buffer.writeln('Bundle: ${item.bundleName}');
        buffer.writeln('  Price: ₹${item.bundlePrice}');
        buffer.writeln('  Original: ₹${item.originalIndividualPrice}');
        buffer.writeln('  Savings: ₹${item.bundleSavings}');

        final products = item.getBundleProducts();
        final sizes = item.getAllBundleProductSizes();

        buffer.writeln('  Products:');
        for (final product in products) {
          final productId = product['productId'] as String?;
          final size = productId != null
              ? sizes[productId] ?? product['size'] ?? ''
              : product['size'] ?? '';
          final title = product['title'] ?? 'Unknown';
          final price = product['price'] ?? '0';

          if (size.isNotEmpty) {
            buffer.writeln('    - $title ($size) - ₹$price');
          } else {
            buffer.writeln('    - $title - ₹$price');
          }
        }
      } else {
        buffer.writeln('Item: ${item.title}');
        buffer.writeln('  Quantity: ${item.quantity}');
        buffer.writeln('  Price: ₹${item.price}');
        if (item.size != null && item.size!.isNotEmpty) {
          buffer.writeln('  Size: ${item.size}');
        }
      }
    }

    return buffer.toString();
  }
}
