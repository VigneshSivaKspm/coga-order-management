import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../utils/constants.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import 'status_badge.dart';

/// Widget that displays an order summary in a card format
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;
  final VoidCallback? onViewPressed;
  final bool showViewButton;
  final int? serialNumber;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onViewPressed,
    this.showViewButton = true,
    this.serialNumber,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(kDefaultRadius),
          border: Border.all(color: kBorderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (serialNumber != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: kSurfaceColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '#$serialNumber',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: kTextSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                order.customerName.isNotEmpty
                                    ? order.customerName
                                    : 'Unknown Customer',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: kTextPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.customerEmail.isNotEmpty
                              ? order.customerEmail
                              : 'No email',
                          style: const TextStyle(
                            fontSize: 13,
                            color: kTextSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  StatusBadge(orderStatus: order.status),
                ],
              ),

              const SizedBox(height: 16),

              // Divider
              Container(height: 1, color: kBorderColor),

              const SizedBox(height: 16),

              // Info Row
              Row(
                children: [
                  _buildInfoItem(
                    icon: Icons.shopping_bag_outlined,
                    label:
                        '${order.totalProducts} ${order.totalProducts == 1 ? 'item' : 'items'}',
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    icon: Icons.payment_outlined,
                    label: order.isCOD ? 'COD' : 'Online',
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    icon: Icons.calendar_today_outlined,
                    label: DateFormatter.formatShort(order.orderDate),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Footer Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(fontSize: 12, color: kTextSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.format(order.totalPrice),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (showViewButton)
                    ElevatedButton(
                      onPressed: onViewPressed ?? onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'View',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: kTextTertiary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: kTextSecondary),
        ),
      ],
    );
  }
}

/// Compact order card for customer view
class CompactOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTrackPressed;

  const CompactOrderCard({super.key, required this.order, this.onTrackPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kDefaultRadius),
        border: Border.all(color: kBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.shortId}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kTextPrimary,
                  ),
                ),
                StatusBadge(orderStatus: order.status, isSmall: true),
              ],
            ),

            const SizedBox(height: 12),

            // Date and Items
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: kTextTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormatter.formatShort(order.orderDate),
                  style: const TextStyle(fontSize: 13, color: kTextSecondary),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 14,
                  color: kTextTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${order.totalProducts} ${order.totalProducts == 1 ? 'item' : 'items'}',
                  style: const TextStyle(fontSize: 13, color: kTextSecondary),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Divider
            Container(height: 1, color: kBorderColor),

            const SizedBox(height: 12),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CurrencyFormatter.format(order.totalPrice),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: onTrackPressed,
                  icon: const Icon(Icons.track_changes, size: 16),
                  label: const Text('Track Order'),
                  style: TextButton.styleFrom(
                    foregroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
