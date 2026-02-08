import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../utils/constants.dart';

/// Widget that displays a colored status badge
class StatusBadge extends StatelessWidget {
  final OrderStatus? orderStatus;
  final PaymentStatus? paymentStatus;
  final bool isSmall;

  const StatusBadge({
    super.key,
    this.orderStatus,
    this.paymentStatus,
    this.isSmall = false,
  }) : assert(
         orderStatus != null || paymentStatus != null,
         'Either orderStatus or paymentStatus must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final StatusConfig config;

    if (orderStatus != null) {
      config = getOrderStatusConfig(orderStatus!);
    } else {
      config = getPaymentStatusConfig(paymentStatus!);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(isSmall ? 4 : 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isSmall) ...[
            Icon(config.icon, size: 14, color: config.textColor),
            const SizedBox(width: 4),
          ],
          Text(
            config.label,
            style: TextStyle(
              color: config.textColor,
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget that displays an order status badge
class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;
  final bool isSmall;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return StatusBadge(orderStatus: status, isSmall: isSmall);
  }
}

/// Widget that displays a payment status badge
class PaymentStatusBadge extends StatelessWidget {
  final PaymentStatus status;
  final bool isSmall;

  const PaymentStatusBadge({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return StatusBadge(paymentStatus: status, isSmall: isSmall);
  }
}
