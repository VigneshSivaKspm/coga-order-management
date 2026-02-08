import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order_model.dart';
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

              orders.add(order);
            } catch (e) {
              print('Error parsing order ${doc.id}: $e');
            }
          }

          // Sort by createdAt descending
          orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
          return orders;
        })
        .handleError((e) {
          print('Error fetching orders: $e');
          return <Order>[];
        });
  }

  /// Get orders by user ID stream (for customer)
  /// Returns a real-time stream of orders for a specific user
  Stream<List<Order>> getUserOrdersStream(String userId) {
    return _ordersRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final orders = <Order>[];

          for (final doc in snapshot.docs) {
            try {
              orders.add(Order.fromFirestore(doc));
            } catch (e) {
              print('Error parsing order ${doc.id}: $e');
            }
          }

          // Sort by createdAt descending
          orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
          return orders;
        })
        .handleError((e) {
          print('Error fetching user orders for $userId: $e');
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
              print('Error parsing order ${doc.id}: $e');
            }
          }

          // Sort by created date descending
          orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
          return orders;
        })
        .handleError((e) {
          print('Error searching orders: $e');
          return <Order>[];
        });
  }
}
