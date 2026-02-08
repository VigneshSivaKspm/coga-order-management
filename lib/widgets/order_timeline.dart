import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../utils/constants.dart';

/// Widget that displays order tracking timeline
class OrderTimeline extends StatelessWidget {
  final OrderStatus currentStatus;

  const OrderTimeline({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final isCancelled = currentStatus == OrderStatus.cancelled;
    final currentStep = currentStatus.stepIndex;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kDefaultRadius),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 24),
          if (isCancelled)
            _buildCancelledState()
          else
            _buildTimelineSteps(currentStep),
        ],
      ),
    );
  }

  Widget _buildCancelledState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(kDefaultRadius),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF991B1B),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Cancelled',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF991B1B),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'This order has been cancelled',
                  style: TextStyle(fontSize: 13, color: Color(0xFFB91C1C)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSteps(int currentStep) {
    return Column(
      children: [
        for (int i = 0; i < kOrderTimelineSteps.length; i++) ...[
          _TimelineStep(
            title: kOrderTimelineSteps[i],
            description: _getStepDescription(i),
            isCompleted: i < currentStep,
            isCurrent: i == currentStep,
            isPending: i > currentStep,
            isFirst: i == 0,
            isLast: i == kOrderTimelineSteps.length - 1,
          ),
        ],
      ],
    );
  }

  String _getStepDescription(int step) {
    switch (step) {
      case 0:
        return 'Your order has been placed successfully';
      case 1:
        return 'Your order is being processed';
      case 2:
        return 'Your order has been shipped';
      case 3:
        return 'Your order has been delivered';
      default:
        return '';
    }
  }
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final String description;
  final bool isCompleted;
  final bool isCurrent;
  final bool isPending;
  final bool isFirst;
  final bool isLast;

  const _TimelineStep({
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.isCurrent,
    required this.isPending,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        SizedBox(
          width: 40,
          child: Column(
            children: [
              // Connector line (top)
              if (!isFirst)
                Container(
                  width: 2,
                  height: 12,
                  color: isCompleted || isCurrent
                      ? kSuccessColor
                      : kBorderColor,
                ),
              // Circle
              _buildCircle(),
              // Connector line (bottom)
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: isCompleted ? kSuccessColor : kBorderColor,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              top: isFirst ? 0 : 4,
              bottom: isLast ? 0 : 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCurrent || isCompleted
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: isPending ? kTextTertiary : kTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isPending ? kTextTertiary : kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircle() {
    if (isCompleted) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: kSuccessColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      );
    } else if (isCurrent) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: kInfoColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorderColor, width: 2),
        ),
      );
    }
  }
}

/// Horizontal timeline for compact view
class HorizontalOrderTimeline extends StatelessWidget {
  final OrderStatus currentStatus;

  const HorizontalOrderTimeline({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final isCancelled = currentStatus == OrderStatus.cancelled;
    final currentStep = currentStatus.stepIndex;

    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(kSmallRadius),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel, color: Color(0xFF991B1B), size: 16),
            SizedBox(width: 8),
            Text(
              'Order Cancelled',
              style: TextStyle(
                color: Color(0xFF991B1B),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        for (int i = 0; i < kOrderTimelineSteps.length; i++) ...[
          _HorizontalTimelineStep(
            label: kOrderTimelineSteps[i],
            isCompleted: i < currentStep,
            isCurrent: i == currentStep,
          ),
          if (i < kOrderTimelineSteps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                color: i < currentStep ? kSuccessColor : kBorderColor,
              ),
            ),
        ],
      ],
    );
  }
}

class _HorizontalTimelineStep extends StatelessWidget {
  final String label;
  final bool isCompleted;
  final bool isCurrent;

  const _HorizontalTimelineStep({
    required this.label,
    required this.isCompleted,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isCompleted)
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: kSuccessColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 14),
          )
        else if (isCurrent)
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: kInfoColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          )
        else
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorderColor, width: 2),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isCurrent || isCompleted
                ? FontWeight.w600
                : FontWeight.w500,
            color: isCurrent || isCompleted ? kTextPrimary : kTextTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
