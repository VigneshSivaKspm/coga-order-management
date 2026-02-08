import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/order_items_list.dart';
import '../../widgets/loading_widget.dart';

/// Detailed view of a single order with status update capabilities
class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderStatus _selectedOrderStatus;
  late PaymentStatus _selectedPaymentStatus;
  bool _isUpdatingStatus = false;
  bool _isUpdatingPayment = false;

  @override
  void initState() {
    super.initState();
    _selectedOrderStatus = widget.order.status;
    _selectedPaymentStatus = widget.order.paymentStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Order #${widget.order.shortId}',
          style: const TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
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
            // Order Header
            _buildOrderHeader(),
            const SizedBox(height: 20),

            // Customer Information
            _buildInfoCard(
              title: 'Customer Information',
              icon: Icons.person_outline,
              children: [
                _buildInfoRow('Name', widget.order.customerName),
                _buildInfoRow('Email', widget.order.customerEmail),
              ],
            ),
            const SizedBox(height: 16),

            // Payment Information
            _buildInfoCard(
              title: 'Payment Information',
              icon: Icons.payment_outlined,
              children: [
                _buildInfoRow(
                  'Payment Mode',
                  widget.order.isCOD ? 'Cash on Delivery' : 'Online Payment',
                ),
                if (widget.order.paymentId != null)
                  _buildInfoRow('Payment ID', widget.order.paymentId!),
                _buildInfoRow(
                  'Total Amount',
                  CurrencyFormatter.format(widget.order.totalPrice),
                  isHighlighted: true,
                ),
                _buildInfoRow(
                  'Payment Status',
                  '',
                  trailing: PaymentStatusBadge(
                    status: widget.order.paymentStatus,
                    isSmall: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Shipping Address
            _buildInfoCard(
              title: 'Shipping Address',
              icon: Icons.location_on_outlined,
              children: [
                if (widget.order.shippingAddress.fullName.isNotEmpty)
                  _buildInfoRow('Name', widget.order.shippingAddress.fullName),
                _buildInfoRow('Street', widget.order.shippingAddress.street),
                if (widget.order.shippingAddress.landmark.isNotEmpty)
                  _buildInfoRow(
                    'Landmark',
                    widget.order.shippingAddress.landmark,
                  ),
                _buildInfoRow('City', widget.order.shippingAddress.city),
                _buildInfoRow('State', widget.order.shippingAddress.state),
                _buildInfoRow('Pincode', widget.order.shippingAddress.pincode),
                _buildInfoRow('Phone', widget.order.shippingAddress.phone),
              ],
            ),
            const SizedBox(height: 16),

            // Order Items
            OrderItemsList(
              items: widget.order.items,
              showTotal: true,
              total: widget.order.totalPrice,
            ),
            const SizedBox(height: 24),

            // Update Payment Status (for COD orders)
            if (widget.order.isCOD) ...[
              _buildUpdatePaymentStatusSection(),
              const SizedBox(height: 16),
            ],

            // Update Order Status
            _buildUpdateOrderStatusSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kDefaultRadius),
        border: Border.all(color: kBorderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order ID',
                  style: TextStyle(fontSize: 12, color: kTextSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.order.id,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Order Date',
                  style: TextStyle(fontSize: 12, color: kTextSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatWithTime(widget.order.orderDate),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: kTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(orderStatus: widget.order.status),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kDefaultRadius),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: kTextPrimary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: kBorderColor),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isHighlighted = false,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: kTextSecondary),
            ),
          ),
          Expanded(
            child:
                trailing ??
                Text(
                  value.isNotEmpty ? value : '-',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isHighlighted
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: kTextPrimary,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdatePaymentStatusSection() {
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
          const Row(
            children: [
              Icon(Icons.payment_outlined, size: 20, color: kTextPrimary),
              SizedBox(width: 8),
              Text(
                'Update Payment Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: kBorderColor),
                    borderRadius: BorderRadius.circular(kDefaultRadius),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<PaymentStatus>(
                      value: _selectedPaymentStatus,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: PaymentStatus.values.map((status) {
                        return DropdownMenuItem<PaymentStatus>(
                          value: status,
                          child: Text(status.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedPaymentStatus = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              LoadingButton(
                isLoading: _isUpdatingPayment,
                text: 'Update',
                onPressed: _selectedPaymentStatus != widget.order.paymentStatus
                    ? _updatePaymentStatus
                    : null,
                width: 100,
                height: 44,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateOrderStatusSection() {
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
          const Row(
            children: [
              Icon(Icons.update_outlined, size: 20, color: kTextPrimary),
              SizedBox(width: 8),
              Text(
                'Update Order Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: kBorderColor),
                    borderRadius: BorderRadius.circular(kDefaultRadius),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<OrderStatus>(
                      value: _selectedOrderStatus,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: OrderStatus.values.map((status) {
                        final isValid = isValidStatusTransition(
                          widget.order.status,
                          status,
                        );
                        return DropdownMenuItem<OrderStatus>(
                          value: status,
                          enabled: isValid || status == widget.order.status,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: getOrderStatusConfig(status).textColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                status.label,
                                style: TextStyle(
                                  color:
                                      isValid || status == widget.order.status
                                      ? kTextPrimary
                                      : kTextTertiary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null &&
                            isValidStatusTransition(
                              widget.order.status,
                              value,
                            )) {
                          setState(() {
                            _selectedOrderStatus = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              LoadingButton(
                isLoading: _isUpdatingStatus,
                text: 'Update',
                onPressed: _selectedOrderStatus != widget.order.status
                    ? _updateOrderStatus
                    : null,
                width: 100,
                height: 44,
              ),
            ],
          ),
          if (!isValidStatusTransition(
                widget.order.status,
                _selectedOrderStatus,
              ) &&
              _selectedOrderStatus != widget.order.status)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Invalid status transition',
                style: TextStyle(fontSize: 12, color: kErrorColor),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _updatePaymentStatus() async {
    final confirm = await _showConfirmDialog(
      title: 'Update Payment Status',
      message:
          'Are you sure you want to change the payment status to "${_selectedPaymentStatus.label}"?',
    );

    if (!confirm) return;

    setState(() => _isUpdatingPayment = true);

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final success = await orderProvider.updatePaymentStatus(
      widget.order.id,
      _selectedPaymentStatus,
    );

    setState(() => _isUpdatingPayment = false);

    if (!mounted) return;

    if (success) {
      _showSuccessSnackBar(kSuccessPaymentStatusUpdated);
    } else {
      _showErrorSnackBar(orderProvider.error ?? kErrorUpdateStatus);
      // Reset to original status
      setState(() {
        _selectedPaymentStatus = widget.order.paymentStatus;
      });
    }
  }

  Future<void> _updateOrderStatus() async {
    if (!isValidStatusTransition(widget.order.status, _selectedOrderStatus)) {
      _showErrorSnackBar('Invalid status transition');
      return;
    }

    final confirm = await _showConfirmDialog(
      title: 'Update Order Status',
      message:
          'Are you sure you want to change the order status to "${_selectedOrderStatus.label}"?',
    );

    if (!confirm) return;

    setState(() => _isUpdatingStatus = true);

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final success = await orderProvider.updateOrderStatus(
      widget.order.id,
      _selectedOrderStatus,
    );

    setState(() => _isUpdatingStatus = false);

    if (!mounted) return;

    if (success) {
      _showSuccessSnackBar(kSuccessStatusUpdated);
    } else {
      _showErrorSnackBar(orderProvider.error ?? kErrorUpdateStatus);
      // Reset to original status
      setState(() {
        _selectedOrderStatus = widget.order.status;
      });
    }
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kLargeRadius),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kDefaultRadius),
              ),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: kSuccessColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kDefaultRadius),
        ),
        margin: const EdgeInsets.all(kDefaultPadding),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: kErrorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kDefaultRadius),
        ),
        margin: const EdgeInsets.all(kDefaultPadding),
      ),
    );
  }
}
