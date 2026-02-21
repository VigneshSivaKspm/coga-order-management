# 📏 Bundle Product Sizes - Display Guide

## Overview

Bundle orders now include size details for each product in the bundle. This guide shows how to correctly display and manage bundle product sizes throughout your application.

## Data Structure

### OrderItem with Bundle Sizes

```dart
OrderItem {
  // Regular fields
  productId: "prod_001",
  title: "Summer T-Shirt",
  quantity: 2,
  price: "399",
  
  // Bundle fields
  bundleId: "bundle_123",
  isBundleItem: true,
  bundleName: "Premium Summer Bundle",
  bundlePrice: "1799",
  
  // ✅ NEW: Bundle product sizes
  bundleProductSizes: {
    "prod_001": "XL",      // Product ID -> Size
    "prod_002": "M",
    "prod_003": "L"
  }
}
```

## Firestore Structure

```
orders/
└── {orderId}/
    └── items[0]
        ├── productId: "prod_001"
        ├── bundleId: "bundle_123"
        ├── isBundleItem: true
        └── bundleProductSizes: {
            "prod_001": "XL",
            "prod_002": "M",
            "prod_003": "L"
          }
```

## Available Methods

### OrderItem Methods

```dart
// Get size for a specific product in bundle
String size = bundleItem.getProductSizeInBundle("prod_001");
// Returns: "XL"

// Get all sizes as Map
Map<String, String> sizes = bundleItem.getAllBundleProductSizes();
// Returns: {"prod_001": "XL", "prod_002": "M", "prod_003": "L"}

// Get formatted string
String formatted = bundleItem.formatBundleProductSizes();
// Returns: "prod_001: XL, prod_002: M, prod_003: L"
```

### OrderService Methods

```dart
// Get sizes from a bundle item
Map<String, String> sizes = orderService.getBundleProductSizes(bundleItem);

// Get size of specific product
String size = orderService.getProductSizeInBundle(bundleItem, "prod_001");

// Get all bundle items with sizes
List<Map> bundleItems = orderService.getBundleItemsWithSizes(order);

// Format sizes as string
String formatted = orderService.formatBundleProductSizes(bundleItem);

// Get all sizes info in order
Map<String, dynamic> info = orderService.getOrderSizesInfo(order);
```

## UI Display Examples

### 1. Simple Bundle Item Card with Sizes

```dart
Widget buildBundleItemWithSizes(OrderItem item) {
  if (!item.isBundleItem) return SizedBox.shrink();

  final sizes = item.getAllBundleProductSizes();

  return Card(
    color: Colors.blue.shade50,
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      item.bundleName ?? 'Bundle',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Product details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    item.image!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(width: 12),
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
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // ✅ SIZE DETAILS
          if (sizes.isNotEmpty)
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Sizes:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  ...sizes.entries.map(
                    (e) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.key, // Product ID
                            style: TextStyle(fontSize: 10),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              e.value, // Size
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
                    'Bundle: ₹${item.bundlePrice}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Save ₹${item.bundleSavings.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 10,
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
```

### 2. Detailed Bundle Breakdown Widget

```dart
Widget buildBundleWithDetailedSizes(
  MutableList<Map<String, dynamic>> bundleSummary,
  OrderService orderService,
  Order order,
) {
  final itemsWithSizes = orderService.getBundleItemsWithSizes(order);

  return Column(
    children: itemsWithSizes.map((bundleItem) {
      final sizes = bundleItem['productSizes'] as Map<String, String>;

      return Container(
        margin: EdgeInsets.all(12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bundle header
            Text(
              bundleItem['bundleName'] ?? 'Bundle',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),

            // ✅ Detailed size breakdown
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Products & Sizes:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 8),
                  ...sizes.entries.map(
                    (entry) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Product ID:',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Size:',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  entry.value,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
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
            ),
            SizedBox(height: 12),

            // Pricing
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bundle Price:',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      '₹${bundleItem['bundlePrice']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Savings:',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      '₹${bundleItem['savings']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }).toList(),
  );
}
```

### 3. Order Summary with Sizes

```dart
Widget buildOrderSummaryWithSizes(Order order, OrderService orderService) {
  final sizesInfo = orderService.getOrderSizesInfo(order);
  final bundleItems = sizesInfo['bundleItems'] as List<Map<String, dynamic>>;
  final regularItems =
      sizesInfo['regularItems'] as List<Map<String, dynamic>>;

  return Column(
    children: [
      // Bundle items with sizes
      if (bundleItems.isNotEmpty) ...[
        Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.card_giftcard, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Bundle Orders',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              ...bundleItems.map((item) {
                final sizes = item['productSizes'] as Map<String, String>;
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['bundleName'] ?? 'Bundle',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Sizes: ${sizes.values.join(", ")}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        Divider(),
      ],

      // Regular items with sizes
      if (regularItems.isNotEmpty) ...[
        Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sized Items',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              ...regularItems.map((item) {
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'],
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                'Qty: ${item['quantity']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Size: ${item['size']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    ],
  );
}
```

### 4. Delivery Note/Invoice View

```dart
Widget buildDeliveryNoteWithSizes(Order order, OrderService orderService) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'ORDER DETAILS',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
      SizedBox(height: 12),
      ...order.items.map((item) {
        if (item.isBundleItem) {
          final sizes = item.getAllBundleProductSizes();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.title),
                  Text('₹${item.bundlePrice}'),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Bundle: ${item.bundleName}',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      'Sizes: ${sizes.values.join(", ")}',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.blue[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(height: 12),
            ],
          );
        }

        // Regular item
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.title),
                Text('₹${item.price}'),
              ],
            ),
            Row(
              children: [
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                if (item.size != null && item.size!.isNotEmpty) ...[
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      'Size: ${item.size}',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.blue[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Divider(height: 12),
          ],
        );
      }),
    ],
  );
}
```

## Usage in Order Details Screen

```dart
class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Details')),
      body: StreamBuilder<Order?>(
        stream: _orderService.getOrderStream(orderId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
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
                        Text(
                          'Order #${order.shortId}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          order.orderDate.toString(),
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // ✅ Order summary with sizes
                buildOrderSummaryWithSizes(order, _orderService),
                SizedBox(height: 16),

                // ✅ Detailed bundle breakdown if applicable
                if (_orderService.hasOrderBundleItems(order))
                  buildBundleWithDetailedSizes([], _orderService, order),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

## Data Saving Example

When creating an order with bundles, include the `bundleProductSizes`:

```dart
final orderItem = OrderItem(
  productId: 'prod_001',
  title: 'Summer T-Shirt',
  bundleId: 'bundle_123',
  isBundleItem: true,
  bundleName: 'Premium Summer Bundle',
  bundlePrice: '1799',
  bundleProductSizes: {
    'prod_001': 'XL',
    'prod_002': 'M',
    'prod_003': 'L',
  },
  // ... other fields
);

// Save to Firestore
final order = Order(
  items: [orderItem],
  // ... other fields
);

await orderService.createOrder(order);
```

## Key Features

✅ **Automatic Parsing**: Bundle sizes parsed from Firestore automatically  
✅ **Type-Safe**: Full Dart type support  
✅ **Easy Access**: Multiple helper methods for retrieving sizes  
✅ **Flexible Display**: Multiple UI patterns provided  
✅ **Serialization**: Sizes automatically saved/loaded from Firestore  
✅ **Performance**: Sizes included in order items, no extra queries needed  

## Summary

Bundle product sizes are now:
- ✅ Stored in `bundleProductSizes` field
- ✅ Automatically parsed from Firestore
- ✅ Available through helper methods
- ✅ Ready to display in UI
- ✅ Included in order data

Use the provided UI examples to display sizes correctly in your order views!
