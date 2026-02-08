// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

/// Provider class for managing order state
class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  final NotificationService _notificationService = NotificationService();

  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _statusFilter = 'All';
  int _currentPage = 1;
  bool _hasMore = true;
  StreamSubscription<List<Order>>? _ordersSubscription;
  Set<String> _knownOrderIds = {}; // Track existing orders to detect new ones
  bool _isFirstLoad = true;

  /// All orders
  List<Order> get orders => _orders;

  /// Filtered orders
  List<Order> get filteredOrders => _filteredOrders;

  /// Currently selected order
  Order? get selectedOrder => _selectedOrder;

  /// Loading state
  bool get isLoading => _isLoading;

  /// Error message
  String? get error => _error;

  /// Current search query
  String get searchQuery => _searchQuery;

  /// Current status filter
  String get statusFilter => _statusFilter;

  /// Current page number
  int get currentPage => _currentPage;

  /// Has more pages
  bool get hasMore => _hasMore;

  /// Get current orders (pending, processing, shipped)
  List<Order> get currentOrders =>
      _orderService.getCurrentOrders(_filteredOrders);

  /// Get previous orders (delivered, cancelled)
  List<Order> get previousOrders =>
      _orderService.getPreviousOrders(_filteredOrders);

  /// DEBUG: Get ALL orders (unfiltered)
  List<Order> get debugAllOrders => _orders;

  /// Get paginated current orders
  List<Order> get paginatedCurrentOrders => _orderService.getPaginatedOrders(
    currentOrders,
    _currentPage,
    kOrdersPerPage,
  );

  /// Get paginated previous orders
  List<Order> get paginatedPreviousOrders => _orderService.getPaginatedOrders(
    previousOrders,
    _currentPage,
    kOrdersPerPage,
  );

  /// Get order statistics
  Map<String, int> get orderStats => _orderService.getOrderStats(_orders);

  /// Get total revenue
  double get totalRevenue => _orderService.getTotalRevenue(_orders);

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set error message
  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Load all orders (admin) with real-time updates
  void loadOrders() {
    _setLoading(true);
    _setError(null);
    _isFirstLoad = true;

    // Initialize notification service
    _notificationService.initialize();

    _ordersSubscription?.cancel();
    _ordersSubscription = _orderService.getOrdersStream().listen(
      (orders) {
        // Detect new orders (only after first load)
        if (!_isFirstLoad) {
          for (final order in orders) {
            if (!_knownOrderIds.contains(order.id)) {
              _notificationService.showNewOrderNotification(order);
            }
          }
        }

        // Update known order IDs
        _knownOrderIds = orders.map((o) => o.id).toSet();
        _isFirstLoad = false;

        _orders = orders;
        _applyFilters();
        _setLoading(false);
      },
      onError: (e) {
        _setError('Failed to load orders: $e');
        _setLoading(false);
      },
    );
  }

  /// Load orders for a specific user (customer) with real-time updates
  void loadUserOrders(String userId) {
    _setLoading(true);
    _setError(null);

    _ordersSubscription?.cancel();
    _ordersSubscription = _orderService
        .getUserOrdersStream(userId)
        .listen(
          (orders) {
            _orders = orders;
            _applyFilters();
            _setLoading(false);
          },
          onError: (e) {
            _setError(kErrorLoadOrders);
            _setLoading(false);
          },
        );
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1;
    _applyFilters();
  }

  /// Set status filter
  void setStatusFilter(String status) {
    _statusFilter = status;
    _currentPage = 1;
    _applyFilters();
  }

  /// Apply filters to orders
  void _applyFilters() {
    _filteredOrders = _orderService.filterOrders(
      _orders,
      _searchQuery,
      _statusFilter,
    );
    _updateHasMore();
    notifyListeners();
  }

  /// Update has more pages
  void _updateHasMore() {
    final totalCurrent = currentOrders.length;
    final totalPrevious = previousOrders.length;
    _hasMore =
        _currentPage * kOrdersPerPage < totalCurrent ||
        _currentPage * kOrdersPerPage < totalPrevious;
  }

  /// Load more orders (pagination)
  void loadMore() {
    if (_hasMore) {
      _currentPage++;
      _updateHasMore();
      notifyListeners();
    }
  }

  /// Reset pagination
  void resetPagination() {
    _currentPage = 1;
    _updateHasMore();
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _statusFilter = 'All';
    _currentPage = 1;
    _applyFilters();
  }

  /// Select an order
  void selectOrder(Order? order) {
    _selectedOrder = order;
    notifyListeners();
  }

  /// Load order by ID
  Future<Order?> loadOrderById(String orderId) async {
    _setLoading(true);
    try {
      final order = await _orderService.getOrderById(orderId);
      _selectedOrder = order;
      notifyListeners();
      return order;
    } catch (e) {
      _setError('Failed to load order');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      _setLoading(true);

      // Validate status transition
      final order = _orders.firstWhere(
        (o) => o.id == orderId,
        orElse: () => throw Exception('Order not found'),
      );

      if (!isValidStatusTransition(order.status, status)) {
        _setError('Invalid status transition');
        return false;
      }

      await _orderService.updateOrderStatus(orderId, status);

      // Update local state
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: status);
        _applyFilters();
      }

      if (_selectedOrder?.id == orderId) {
        _selectedOrder = _selectedOrder?.copyWith(status: status);
      }

      return true;
    } catch (e) {
      _setError(kErrorUpdateStatus);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update payment status
  Future<bool> updatePaymentStatus(String orderId, PaymentStatus status) async {
    try {
      _setLoading(true);

      await _orderService.updatePaymentStatus(orderId, status);

      // Update local state
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(paymentStatus: status);
        _applyFilters();
      }

      if (_selectedOrder?.id == orderId) {
        _selectedOrder = _selectedOrder?.copyWith(paymentStatus: status);
      }

      return true;
    } catch (e) {
      _setError(kErrorUpdateStatus);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update both order and payment status
  Future<bool> updateOrderAndPaymentStatus(
    String orderId,
    OrderStatus orderStatus,
    PaymentStatus paymentStatus,
  ) async {
    try {
      _setLoading(true);

      // Validate status transition
      final order = _orders.firstWhere(
        (o) => o.id == orderId,
        orElse: () => throw Exception('Order not found'),
      );

      if (!isValidStatusTransition(order.status, orderStatus)) {
        _setError('Invalid status transition');
        return false;
      }

      await _orderService.updateOrderAndPaymentStatus(
        orderId,
        orderStatus,
        paymentStatus,
      );

      // Update local state
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          status: orderStatus,
          paymentStatus: paymentStatus,
        );
        _applyFilters();
      }

      if (_selectedOrder?.id == orderId) {
        _selectedOrder = _selectedOrder?.copyWith(
          status: orderStatus,
          paymentStatus: paymentStatus,
        );
      }

      return true;
    } catch (e) {
      _setError(kErrorUpdateStatus);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh orders
  Future<void> refresh() async {
    // The stream will automatically update
    // This method can be used for pull-to-refresh UI
    notifyListeners();
  }

  /// Get order by ID from local state
  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (e) {
      return null;
    }
  }

  /// Get orders by date range
  List<Order> getOrdersByDateRange(DateTime startDate, DateTime endDate) {
    return _orderService.getOrdersByDateRange(_orders, startDate, endDate);
  }

  /// Check if more pages available for current orders tab
  bool hasMoreCurrentOrders() {
    return _orderService.hasMorePages(
      currentOrders,
      _currentPage,
      kOrdersPerPage,
    );
  }

  /// Check if more pages available for previous orders tab
  bool hasMorePreviousOrders() {
    return _orderService.hasMorePages(
      previousOrders,
      _currentPage,
      kOrdersPerPage,
    );
  }

  /// Load orders for a guest user by email or phone
  void loadGuestOrders({String? email, String? phone}) {
    _setLoading(true);
    _setError(null);

    _ordersSubscription?.cancel();
    _ordersSubscription = _orderService
        .searchOrdersByContactInfo(email: email, phone: phone)
        .listen(
          (orders) {
            _orders = orders;
            _applyFilters();
            _setLoading(false);
          },
          onError: (e) {
            _setError(kErrorLoadOrders);
            _setLoading(false);
          },
        );
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
