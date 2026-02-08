import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/order_item_model.dart';
import '../utils/constants.dart';
import '../utils/currency_formatter.dart';

/// Widget that displays a list of order items
class OrderItemsList extends StatelessWidget {
  final List<OrderItem> items;
  final bool showTotal;
  final double? total;

  const OrderItemsList({
    super.key,
    required this.items,
    this.showTotal = false,
    this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kDefaultRadius),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: kBorderColor)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 20,
                  color: kTextPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Order Items (${items.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kTextPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: kBorderColor),
            itemBuilder: (context, index) {
              return _OrderItemRow(item: items[index], index: index + 1);
            },
          ),

          // Total
          if (showTotal && total != null) ...[
            const Divider(height: 1, color: kBorderColor),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Total: ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: kTextPrimary,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(total),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final OrderItem item;
  final int index;

  const _OrderItemRow({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.image != null && item.image!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: item.image!,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 70,
                      height: 70,
                      color: kSurfaceColor,
                      child: const Icon(
                        Icons.image_outlined,
                        color: kTextTertiary,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 70,
                      height: 70,
                      color: kSurfaceColor,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: kTextTertiary,
                      ),
                    ),
                  )
                : Container(
                    width: 70,
                    height: 70,
                    color: kSurfaceColor,
                    child: const Icon(
                      Icons.image_outlined,
                      color: kTextTertiary,
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kTextPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Size and Color
                Row(
                  children: [
                    if (item.size != null && item.size!.isNotEmpty) ...[
                      _buildTag('Size: ${item.size}'),
                      const SizedBox(width: 8),
                    ],
                    if (item.color != null) ...[_buildColorTag(item.color!)],
                  ],
                ),
                const SizedBox(height: 8),

                // Price and Quantity
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${CurrencyFormatter.formatString(item.price)} × ${item.quantity}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: kTextSecondary,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(item.totalPrice),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kTextPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: kTextSecondary),
      ),
    );
  }

  Widget _buildColorTag(ColorInfo color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color.color,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: kBorderColor, width: 1),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            color.name,
            style: const TextStyle(fontSize: 12, color: kTextSecondary),
          ),
        ],
      ),
    );
  }
}

/// Table view for order items (used in admin detail screen)
class OrderItemsTable extends StatelessWidget {
  final List<OrderItem> items;

  const OrderItemsTable({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kDefaultRadius),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: kBorderColor)),
            ),
            child: const Row(
              children: [
                Icon(Icons.list_alt_outlined, size: 20, color: kTextPrimary),
                SizedBox(width: 8),
                Text(
                  'Order Items',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kTextPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: kSurfaceColor,
            child: const Row(
              children: [
                SizedBox(width: 80, child: Text('Image', style: _headerStyle)),
                Expanded(flex: 3, child: Text('Product', style: _headerStyle)),
                Expanded(child: Text('Size', style: _headerStyle)),
                Expanded(child: Text('Color', style: _headerStyle)),
                Expanded(
                  child: Text(
                    'Qty',
                    style: _headerStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Price',
                    style: _headerStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Total',
                    style: _headerStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: kBorderColor),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Image
                    SizedBox(
                      width: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: item.image != null && item.image!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: item.image!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    _buildPlaceholder(),
                                errorWidget: (context, url, error) =>
                                    _buildPlaceholder(),
                              )
                            : _buildPlaceholder(),
                      ),
                    ),
                    // Product
                    Expanded(
                      flex: 3,
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 13,
                          color: kTextPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Size
                    Expanded(
                      child: Text(
                        item.size ?? '-',
                        style: const TextStyle(
                          fontSize: 13,
                          color: kTextSecondary,
                        ),
                      ),
                    ),
                    // Color
                    Expanded(
                      child: item.color != null
                          ? Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: item.color!.color,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: kBorderColor),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    item.color!.name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: kTextSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              '-',
                              style: TextStyle(
                                fontSize: 13,
                                color: kTextSecondary,
                              ),
                            ),
                    ),
                    // Quantity
                    Expanded(
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: kTextPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Price
                    Expanded(
                      child: Text(
                        CurrencyFormatter.formatString(item.price),
                        style: const TextStyle(
                          fontSize: 13,
                          color: kTextSecondary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    // Total
                    Expanded(
                      child: Text(
                        CurrencyFormatter.format(item.totalPrice),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kTextPrimary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 50,
      height: 50,
      color: kSurfaceColor,
      child: const Icon(Icons.image_outlined, color: kTextTertiary, size: 20),
    );
  }

  static const _headerStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: kTextSecondary,
  );
}
