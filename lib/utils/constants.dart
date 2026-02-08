import 'package:flutter/material.dart';
import '../models/order_model.dart';

/// App-wide constants for the Order Management app

// App Information
const String kAppName = 'Order Management';
const String kAppVersion = '1.0.0';

// Colors
const Color kPrimaryColor = Color(0xFF000000);
const Color kBackgroundColor = Color(0xFFFFFFFF);
const Color kSurfaceColor = Color(0xFFF9FAFB);
const Color kBorderColor = Color(0xFFE5E7EB);
const Color kTextPrimary = Color(0xFF111827);
const Color kTextSecondary = Color(0xFF6B7280);
const Color kTextTertiary = Color(0xFF9CA3AF);
const Color kErrorColor = Color(0xFFDC2626);
const Color kSuccessColor = Color(0xFF059669);
const Color kWarningColor = Color(0xFFD97706);
const Color kInfoColor = Color(0xFF2563EB);

// Status Colors Configuration
class StatusConfig {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;

  const StatusConfig({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
  });
}

/// Order status configuration with colors and icons
final Map<OrderStatus, StatusConfig> orderStatusConfig = {
  OrderStatus.pending: const StatusConfig(
    label: 'Pending',
    backgroundColor: Color(0xFFFEF3C7),
    textColor: Color(0xFF92400E),
    icon: Icons.access_time_rounded,
  ),
  OrderStatus.processing: const StatusConfig(
    label: 'Processing',
    backgroundColor: Color(0xFFDBEAFE),
    textColor: Color(0xFF1E40AF),
    icon: Icons.sync_rounded,
  ),
  OrderStatus.shipped: const StatusConfig(
    label: 'Shipped',
    backgroundColor: Color(0xFFE9D5FF),
    textColor: Color(0xFF6B21A8),
    icon: Icons.local_shipping_rounded,
  ),
  OrderStatus.delivered: const StatusConfig(
    label: 'Delivered',
    backgroundColor: Color(0xFFD1FAE5),
    textColor: Color(0xFF065F46),
    icon: Icons.check_circle_rounded,
  ),
  OrderStatus.cancelled: const StatusConfig(
    label: 'Cancelled',
    backgroundColor: Color(0xFFFEE2E2),
    textColor: Color(0xFF991B1B),
    icon: Icons.cancel_rounded,
  ),
};

/// Payment status configuration
final Map<PaymentStatus, StatusConfig> paymentStatusConfig = {
  PaymentStatus.pending: const StatusConfig(
    label: 'Pending',
    backgroundColor: Color(0xFFFEF3C7),
    textColor: Color(0xFF92400E),
    icon: Icons.pending_outlined,
  ),
  PaymentStatus.paid: const StatusConfig(
    label: 'Paid',
    backgroundColor: Color(0xFFD1FAE5),
    textColor: Color(0xFF065F46),
    icon: Icons.check_circle_outline_rounded,
  ),
};

// Padding & Spacing
const double kDefaultPadding = 16.0;
const double kSmallPadding = 8.0;
const double kLargePadding = 24.0;
const double kExtraLargePadding = 32.0;

// Border Radius
const double kDefaultRadius = 8.0;
const double kSmallRadius = 4.0;
const double kLargeRadius = 12.0;
const double kExtraLargeRadius = 16.0;

// Card Elevation
const double kDefaultElevation = 1.0;
const double kSmallElevation = 0.5;
const double kLargeElevation = 4.0;

// Animation Durations
const Duration kShortAnimationDuration = Duration(milliseconds: 200);
const Duration kMediumAnimationDuration = Duration(milliseconds: 300);
const Duration kLongAnimationDuration = Duration(milliseconds: 500);

// Pagination
const int kOrdersPerPage = 10;

// Firebase Collections
const String kOrdersCollection = 'orders';
const String kUsersCollection = 'users';

// Error Messages
const String kErrorLoadOrders = 'Unable to load orders. Try again later.';
const String kErrorUpdateStatus = 'Failed to update order status';
const String kErrorLogin = 'Please log in to view your orders';
const String kErrorNoOrders = 'No orders found';
const String kErrorInvalidEmail = 'Please enter a valid email';
const String kErrorInvalidPassword = 'Password must be at least 6 characters';
const String kErrorAuthFailed = 'Authentication failed. Please try again.';
const String kErrorNetworkFailed =
    'Network error. Please check your connection.';

// Success Messages
const String kSuccessStatusUpdated = 'Order status updated successfully';
const String kSuccessPaymentStatusUpdated =
    'Payment status updated successfully';
const String kSuccessLogout = 'Logged out successfully';

// Timeline Steps
const List<String> kOrderTimelineSteps = [
  'Order Placed',
  'Processing',
  'Shipped',
  'Delivered',
];

// Order Status List for Filters
const List<String> kOrderStatusFilters = [
  'All',
  'Pending',
  'Processing',
  'Shipped',
  'Delivered',
  'Cancelled',
];

// Payment Modes
const Map<String, String> kPaymentModes = {
  'cod': 'Cash on Delivery',
  'online': 'Online Payment',
};

// Image Placeholder
const String kPlaceholderImage =
    'https://via.placeholder.com/100x100?text=No+Image';

// Regular Expressions
final RegExp kEmailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');

/// Get StatusConfig for a given OrderStatus
StatusConfig getOrderStatusConfig(OrderStatus status) {
  return orderStatusConfig[status] ?? orderStatusConfig[OrderStatus.pending]!;
}

/// Get StatusConfig for a given PaymentStatus
StatusConfig getPaymentStatusConfig(PaymentStatus status) {
  return paymentStatusConfig[status] ??
      paymentStatusConfig[PaymentStatus.pending]!;
}

/// Check if status transition is valid
bool isValidStatusTransition(OrderStatus from, OrderStatus to) {
  // Allow any transition for cancelled orders (re-activate)
  if (from == OrderStatus.cancelled) return true;

  // Cannot change delivered status
  if (from == OrderStatus.delivered) return false;

  // Cannot go backwards from shipped
  if (from == OrderStatus.shipped &&
      (to == OrderStatus.pending || to == OrderStatus.processing)) {
    return false;
  }

  return true;
}
