# Bundle Orders UI Implementation Guide

## Display Bundle Information in Order Details

### 1. Simple Bundle Item Card

Display bundle items differently from regular items in the order:

```dart
Widget buildOrderItem(OrderItem item) {
  if (item.isBundleItem) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bundle indicator
            Row(
              children: [
                Icon(Icons.card_giftcard, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bundle Order',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        item.bundleName ?? 'Bundle',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            
            // Product details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                if (item.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      item.image!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(width: 12),
                
                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Qty: ${item.quantity}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            
            // Pricing
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Original: ₹${item.originalIndividualPrice}',
                      style: TextStyle(
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Bundle: ₹${item.bundlePrice}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                // Savings badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Save ₹${item.bundleSavings.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
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
  
  // Regular item display for non-bundle items
  return buildRegularOrderItem(item);
}
```

### 2. Bundle Summary Widget

Show comprehensive bundle information at the top of order:

```dart
Future<Widget> buildBundleSummaryWidget(
  Order order,
  OrderService orderService,
) async {
  if (!orderService.hasOrderBundleItems(order)) {
    return SizedBox.shrink();
  }

  final bundleSummary = await orderService.getOrderBundleSummary(order);

  return Column(
    children: bundleSummary.map((bundle) {
      final originalPrice = bundle['originalTotalPrice'] as num;
      final bundlePrice = bundle['bundlePrice'] as num;
      final savings = originalPrice - bundlePrice;
      final discount = bundle['discount'];

      return Container(
        margin: EdgeInsets.all(12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(8),
          color: Colors.blue.shade50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bundle header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.card_giftcard,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bundle['name'] ?? 'Bundle',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (bundle['description'] != null)
                        Text(
                          bundle['description'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Products in bundle
            Text(
              'Products (${bundle['itemCount']})',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            ...((bundle['items'] as List).map(
              (item) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item['title']} (x${item['quantity']})',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    if (item['image'] != null)
                      Image.network(
                        item['image'],
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                      ),
                  ],
                ),
              ),
            )),
            SizedBox(height: 12),
            
            // Pricing summary
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Original Total:'),
                      Text(
                        '₹${originalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bundle Price:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '₹${bundlePrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'You Saved:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                      Text(
                        '₹${savings.toStringAsFixed(0)} ($discount% off)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.orange[800],
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
    }).toList(),
  );
}
```

### 3. Order Details Screen with Bundle Support

```dart
class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  final OrderService _orderService = OrderService();

  OrderDetailsScreen({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: StreamBuilder<Order?>(
        stream: _orderService.getOrderStream(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Order not found'));
          }

          final order = snapshot.data!;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order header
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${order.shortId}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Bundle indicator badge
                            if (_orderService.hasOrderBundleItems(order))
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.card_giftcard,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Bundle Order',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Date: ${order.orderDate.toString().split(' ')[0]}',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                
                // Bundle summary if present
                if (_orderService.hasOrderBundleItems(order))
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _orderService.getOrderBundleSummary(order),
                    builder: (context, bundleSnapshot) {
                      if (bundleSnapshot.hasData) {
                        return buildBundleSummaryWidget(order, _orderService)
                            as Widget;
                      }
                      return SizedBox.shrink();
                    },
                  ),
                SizedBox(height: 16),
                
                // Order items
                Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                ...order.items.map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: buildOrderItem(item),
                  ),
                ),
                SizedBox(height: 16),
                
                // Price breakdown
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Subtotal:'),
                            Text('₹${order.totalPrice}'),
                          ],
                        ),
                        if (_orderService.hasOrderBundleItems(order)) ...[
                          SizedBox(height: 4),
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _orderService.getOrderBundleSummary(order),
                            builder: (context, bundleSnapshot) {
                              if (bundleSnapshot.hasData) {
                                final totalSavings = bundleSnapshot.data!.fold(
                                  0.0,
                                  (sum, bundle) =>
                                      sum +
                                      ((bundle['originalTotalPrice'] as num) -
                                          (bundle['bundlePrice'] as num)),
                                );
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Bundle Savings:',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '-₹${totalSavings.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return SizedBox.shrink();
                            },
                          ),
                        ],
                        Divider(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₹${order.totalPrice}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

### 4. Mixed Orders List (Bundle + Regular Items)

```dart
Widget buildOrdersList(List<Order> orders, OrderService orderService) {
  return ListView.builder(
    itemCount: orders.length,
    itemBuilder: (context, index) {
      final order = orders[index];
      final hasBundles = orderService.hasOrderBundleItems(order);

      return Card(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: hasBundles ? Colors.blue.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: hasBundles
                  ? Border.all(color: Colors.blue, width: 2)
                  : null,
            ),
            child: Center(
              child: Icon(
                hasBundles ? Icons.card_giftcard : Icons.shopping_bag,
                color: hasBundles ? Colors.blue : Colors.grey,
                size: 24,
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'Order #${order.shortId}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (hasBundles)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'BUNDLE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Text(
            '${order.totalProducts} items • ₹${order.totalPrice}',
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Navigate to order details
          },
        ),
      );
    },
  );
}
```

### 5. Admin Order Summary Widget

```dart
Future<Widget> buildAdminBundleStats(
  List<Order> orders,
  OrderService orderService,
) async {
  final bundleOrders =
      orders.where((o) => orderService.hasOrderBundleItems(o)).toList();

  double totalBundleRevenue = 0;
  double totalBundleSavings = 0;

  for (final order in bundleOrders) {
    final summary = await orderService.getOrderBundleSummary(order);
    totalBundleRevenue += summary.fold(
      0.0,
      (sum, b) => sum + (b['bundlePrice'] as num),
    );
    totalBundleSavings += summary.fold(
      0.0,
      (sum, b) =>
          sum +
          ((b['originalTotalPrice'] as num) - (b['bundlePrice'] as num)),
    );
  }

  return Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bundle Orders Analytics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    bundleOrders.length.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text('Bundle Orders'),
                ],
              ),
              Column(
                children: [
                  Text(
                    '₹${totalBundleRevenue.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text('Revenue'),
                ],
              ),
              Column(
                children: [
                  Text(
                    '₹${totalBundleSavings.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  Text('Saved by Customers'),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
```

## Styling Tips

- Use a **distinct color** (e.g., blue) for bundle items to differentiate from regular items
- Add a **bundle icon** (gift icon) consistently throughout the UI
- Show **original vs. bundle price** comparison clearly
- Highlight **savings amount** with an orange/green badge
- Add a **"Bundle Order" badge** on the order card
- Use **Product images** in bundle summary for visual clarity

## Constants for Bundled Orders UI

```dart
class BundleOrdersUIConstants {
  // Colors
  static const Color bundleHighlightColor = Color(0xFF2196F3); // Blue
  static const Color bundleSavingsColor = Color(0xFFFFA500); // Orange
  static const Color bundleSuccessColor = Color(0xFF4CAF50); // Green

  // Icons
  static const IconData bundleIcon = Icons.card_giftcard;
  static const IconData discountIcon = Icons.local_offer;

  // Text styles
  static final TextStyle bundleLabelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static final TextStyle bundleSavingsStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: bundleSavingsColor,
  );

  // Padding
  static const double bundleCardPadding = 12.0;
  static const double bundleItemSpacing = 8.0;
}
```

These widgets and patterns provide a complete UI implementation for displaying bundle orders!
