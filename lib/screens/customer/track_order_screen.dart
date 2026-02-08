import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../utils/constants.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/order_timeline.dart';
import '../../widgets/order_items_list.dart';

/// Screen for tracking a specific order's status
class TrackOrderScreen extends StatelessWidget {
  final Order order;

  const TrackOrderScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kBorderColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status & Summary Card
            _buildOrderStatusCard(),
            const SizedBox(height: 20),

            // Customer Info Card
            _buildCustomerInfoCard(),
            const SizedBox(height: 20),

            // Delivery Address Card
            _buildShippingAddressCard(),
            const SizedBox(height: 20),

            // Order Timeline
            _buildTimelineSection(),
            const SizedBox(height: 20),

            // Order Items
            _buildOrderItemsSection(),
            const SizedBox(height: 20),

            // Payment & Pricing Details
            _buildPaymentDetailsCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Build order status and basic info card
  Widget _buildOrderStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.white],
        ),
        borderRadius: BorderRadius.circular(kDefaultRadius),
        border: Border.all(color: kBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with order ID and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order ID',
                      style: TextStyle(
                        fontSize: 12,
                        color: kTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '#${order.shortId}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: kTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(order.status),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  order.status.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _getStatusColor(order.status),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: kBorderColor),
          const SizedBox(height: 16),

          // Order date and summary info
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'Order Date',
                  value: DateFormatter.formatShort(order.orderDate),
                ),
              ),
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Items',
                  value:
                      '${order.totalProducts} ${order.totalProducts == 1 ? 'item' : 'items'}',
                ),
              ),
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.currency_rupee,
                  label: 'Total Amount',
                  value: CurrencyFormatter.formatNoDecimal(order.totalPrice),
                  valueColor: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build customer information section
  Widget _buildCustomerInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kDefaultRadius),
        border: Border.all(color: kBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(Icons.person_outline, size: 22, color: kTextPrimary),
              SizedBox(width: 10),
              Text(
                'Customer Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: kBorderColor),
          const SizedBox(height: 16),

          // Customer name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Name',
                style: TextStyle(
                  fontSize: 12,
                  color: kTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                order.shippingAddress.fullName.isNotEmpty
                    ? order.shippingAddress.fullName
                    : order.customerName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: kTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Email
          if (order.customerEmail.isNotEmpty) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 12,
                    color: kTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 16,
                      color: kTextTertiary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.customerEmail,
                        style: const TextStyle(
                          fontSize: 14,
                          color: kTextSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Mobile number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mobile Number',
                style: TextStyle(
                  fontSize: 12,
                  color: kTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: kTextTertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.shippingAddress.phone.isNotEmpty
                        ? order.shippingAddress.phone
                        : 'Not provided',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: order.shippingAddress.phone.isNotEmpty
                          ? kTextPrimary
                          : kTextTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build delivery address card with modern design
  Widget _buildShippingAddressCard() {
    final address = order.shippingAddress;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kDefaultRadius),
        border: Border.all(color: kBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(Icons.location_on_outlined, size: 22, color: kTextPrimary),
              SizedBox(width: 10),
              Text(
                'Delivery Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: kBorderColor),
          const SizedBox(height: 16),

          // Street Address
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Street Address',
                style: TextStyle(
                  fontSize: 12,
                  color: kTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                address.street.isNotEmpty ? address.street : 'Not provided',
                style: TextStyle(
                  fontSize: 14,
                  color: address.street.isNotEmpty
                      ? kTextPrimary
                      : kTextTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Landmark (if available)
          if (address.landmark.isNotEmpty) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Landmark',
                  style: TextStyle(
                    fontSize: 12,
                    color: kTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  address.landmark,
                  style: const TextStyle(fontSize: 14, color: kTextSecondary),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],

          // City, State, Pincode in a grid
          Row(
            children: [
              Expanded(
                child: _buildAddressField(
                  label: 'City',
                  value: address.city.isNotEmpty ? address.city : 'N/A',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAddressField(
                  label: 'State',
                  value: address.state.isNotEmpty ? address.state : 'N/A',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _buildAddressField(
                  label: 'Postal Code',
                  value: address.pincode.isNotEmpty ? address.pincode : 'N/A',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAddressField(
                  label: 'Phone',
                  value: address.phone.isNotEmpty ? address.phone : 'N/A',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build individual address field
  Widget _buildAddressField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: kTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: value == 'N/A' ? kTextTertiary : kTextPrimary,
          ),
        ),
      ],
    );
  }

  /// Build order timeline section
  Widget _buildTimelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            'Order Status Timeline',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(kDefaultRadius),
            border: Border.all(color: kBorderColor),
          ),
          child: OrderTimeline(currentStatus: order.status),
        ),
      ],
    );
  }

  /// Build order items section
  Widget _buildOrderItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            'Order Items',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kDefaultRadius),
            border: Border.all(color: kBorderColor),
          ),
          child: OrderItemsList(
            items: order.items,
            showTotal: true,
            total: order.totalPrice,
          ),
        ),
      ],
    );
  }

  /// Build payment and pricing details
  Widget _buildPaymentDetailsCard() {
    final isCOD = order.isCOD;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kDefaultRadius),
        border: Border.all(color: kBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(Icons.payment_outlined, size: 22, color: kTextPrimary),
              SizedBox(width: 10),
              Text(
                'Payment & Pricing',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: kBorderColor),
          const SizedBox(height: 16),

          // Payment Method Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCOD ? Colors.orange.shade50 : Colors.green.shade50,
              borderRadius: BorderRadius.circular(kSmallRadius),
              border: Border.all(
                color: isCOD ? Colors.orange.shade200 : Colors.green.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isCOD ? Icons.local_shipping_outlined : Icons.payment,
                  color: isCOD ? Colors.orange : Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 12,
                          color: kTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCOD ? 'Cash on Delivery (COD)' : 'Online Payment',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isCOD ? Colors.orange : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: order.paymentStatus == PaymentStatus.paid
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.paymentStatus.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: order.paymentStatus == PaymentStatus.paid
                          ? Colors.green
                          : Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Price breakdown
          _buildPriceRow(
            label: 'Subtotal',
            value: CurrencyFormatter.formatNoDecimal(order.totalPrice),
            isTotal: false,
          ),
          const SizedBox(height: 10),
          _buildPriceRow(
            label: 'Delivery charges',
            value: 'Free',
            isTotal: false,
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: kBorderColor),
          const SizedBox(height: 10),
          _buildPriceRow(
            label: 'Order Total',
            value: CurrencyFormatter.formatNoDecimal(order.totalPrice),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  /// Helper to build price rows
  Widget _buildPriceRow({
    required String label,
    required String value,
    required bool isTotal,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: kTextPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? Colors.green.shade700 : kTextPrimary,
          ),
        ),
      ],
    );
  }

  /// Helper to build info tiles
  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: kTextTertiary),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: kTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? kTextPrimary,
          ),
        ),
      ],
    );
  }

  /// Get color based on order status
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.amber;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.cyan;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
