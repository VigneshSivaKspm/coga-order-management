# Bundle Order Display - Complete Usage Guide

## Overview

This guide shows how to correctly fetch and display bundle products with sizes in order details, using the Firestore data structure provided.

## Sample Firestore Data Structure

Based on the provided Firestore setup:

```
orders/
└── 1le6xkZsQLrn2Dr2se6y
    ├── items[0]
    │   ├── bundleId: "UnRF2RpqGNDSn3oAl5bY"
    │   ├── bundleName: "Summer Sale"
    │   ├── bundlePrice: 1299
    │   ├── quantity: 2
    │   ├── isBundleItem: true
    │   ├── originalIndividualPrice: 3597
    │   └── bundleProductSizes: {
    │       "cklBLhWbXozOGgFh3ywY": "S",
    │       "psnkeySizwt2eHNiWHAs": "M",
    │       "qeNlqBqGMPWwWGd9y5Ev": "L"
    │   }
    ├── customerName: "Vignesh Siva"
    ├── amount: 2638
    ├── status: "pending"
    └── ...

bundles/
└── UnRF2RpqGNDSn3oAl5bY
    ├── name: "Summer Sale"
    ├── bundlePrice: 1299
    ├── originalTotalPrice: 3597
    ├── products: [
    │   {
    │       "productId": "cklBLhWbXozOGgFh3ywY",
    │       "title": "Summer T-Shirt",
    │       "price": "399",
    │       "quantity": 1,
    │       "image": "url1.jpg"
    │   },
    │   {
    │       "productId": "psnkeySizwt2eHNiWHAs",
    │       "title": "Shorts",
    │       "price": "699",
    │       "quantity": 1,
    │       "image": "url2.jpg"
    │   },
    │   {
    │       "productId": "qeNlqBqGMPWwWGd9y5Ev",
    │       "title": "Cap",
    │       "price": "299",
    │       "quantity": 1,
    │       "image": "url3.jpg"
    │   }
    │ ]
    └── ...
```

## Enhanced Methods

### 1. Fetch and Enrich Order

The `enrichOrderWithBundleDetails()` method now automatically:
- Fetches bundle details from the bundles collection
- Retrieves products list from the bundle
- Matches product IDs with sizes from `bundleProductSizes`
- Enriches items with complete product information

```dart
// Automatically enriches bundle data when fetching order
final order = await orderService.getOrderById(orderId);
// Order items now have complete bundleProducts with sizes!
```

### 2. Get Bundle Products with Details

```dart
// Get enriched bundle products for an order item
final products = orderService.getBundleProductsWithDetails(bundleItem);

// Returns:
[
  {
    "productId": "cklBLhWbXozOGgFh3ywY",
    "title": "Summer T-Shirt",
    "price": "399",
    "quantity": 1,
    "image": "url1.jpg",
    "size": "S",  // ✅ Size from bundleProductSizes
    "displayText": "Summer T-Shirt • Size: S • ₹399"
  },
  {
    "productId": "psnkeySizwt2eHNiWHAs",
    "title": "Shorts",
    "price": "699",
    "quantity": 1,
    "image": "url2.jpg",
    "size": "M",  // ✅ Size from bundleProductSizes
    "displayText": "Shorts • Size: M • ₹699"
  },
  {
    "productId": "qeNlqBqGMPWwWGd9y5Ev",
    "title": "Cap",
    "price": "299",
    "quantity": 1,
    "image": "url3.jpg",
    "size": "L",  // ✅ Size from bundleProductSizes
    "displayText": "Cap • Size: L • ₹299"
  }
]
```

### 3. Get Bundle Products Enriched (Service Method)

```dart
final productos = await orderService.getBundleProductsEnriched(
  bundleId: "UnRF2RpqGNDSn3oAl5bY",
  productSizes: {
    "cklBLhWbXozOGgFh3ywY": "S",
    "psnkeySizwt2eHNiWHAs": "M",
    "qeNlqBqGMPWwWGd9y5Ev": "L"
  }
);
// Returns products with sizes automatically matched
```

## Display Examples

### Example 1: Display Complete Order Details

```dart
// In your order details screen
final order = await orderService.getOrderById(orderId);

if (orderService.hasOrderBundleItems(order)) {
  for (final item in order.items) {
    if (item.isBundleItem) {
      print('═══ Bundle: ${item.bundleName} ═══');
      print('Bundle Price: ₹${item.bundlePrice}');
      print('Original Price: ₹${item.originalIndividualPrice}');
      print('Your Savings: ₹${item.bundleSavings}');
      print('');

      final products = orderService.getBundleProductsWithDetails(item);
      print('Products in Bundle:');
      for (final product in products) {
        print(product['displayText']);
        // Output:
        // Summer T-Shirt • Size: S • ₹399
        // Shorts • Size: M • ₹699
        // Cap • Size: L • ₹299
      }
    }
  }
}
```

### Example 2: Display Order Summary

```dart
// Format complete order details
final orderDetails = orderService.formatOrderDetailsForDisplay(order);
print(orderDetails);

/*
Output:
Order ID: 1le6xkZsQLrn2Dr2se6y
Customer: Vignesh Siva
Email: www.7339596165@gmail.com
Phone: 7339596165
Status: Pending
Payment: Pending
Amount: ₹2638
---
Bundle: Summer Sale
  Price: ₹1299
  Original: ₹3597
  Savings: ₹2298
  Products:
    - Summer T-Shirt (S) - ₹399
    - Shorts (M) - ₹699
    - Cap (L) - ₹299
*/
```

### Example 3: Get Bundle Items with Sizes

```dart
// Get all bundle items with size information
final bundleItems = orderService.getBundleItemsWithSizes(order);

for (final item in bundleItems) {
  print('Bundle: ${item['bundleName']}');
  print('Price: ₹${item['bundlePrice']}');
  print('Product Sizes: ${item['productSizes']}');
  // Output:
  // Bundle: Summer Sale
  // Price: ₹1299
  // Product Sizes: {cklBLhWbXozOGgFh3ywY: S, psnkeySizwt2eHNiWHAs: M, qeNlqBqGMPWwWGd9y5Ev: L}
}
```

### Example 4: Display in Flutter Widget

```dart
Widget buildBundleOrderDetails(Order order, OrderService orderService) {
  if (!orderService.hasOrderBundleItems(order)) {
    return Text('No bundle items');
  }

  return Column(
    children: order.items
        .where((item) => item.isBundleItem)
        .map((bundleItem) {
          final products = orderService.getBundleProductsWithDetails(bundleItem);

          return Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bundle Header
                  Text(
                    bundleItem.bundleName ?? 'Bundle',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),

                  // Price Information
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Bundle Price: ₹${bundleItem.bundlePrice}'),
                      Text('Savings: ₹${bundleItem.bundleSavings.toStringAsFixed(2)}'),
                    ],
                  ),
                  Divider(),

                  // Products List
                  Text(
                    'Products (${products.length}):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ...products.map((product) => Padding(
                    padding: EdgeInsets.only(left: 16, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product['title'] ?? 'Unknown'),
                              if (product['size'] != null && 
                                  (product['size'] as String).isNotEmpty)
                                Text(
                                  'Size: ${product['size']}',
                                  style: TextStyle(color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                        Text('₹${product['price']}'),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          );
        })
        .toList(),
  );
}
```

## Key Points

✅ **Automatic Enrichment**: Bundle details are automatically fetched and enriched when you call `getOrderById()`, `getOrdersStream()`, or `getUserOrdersStream()`

✅ **Size Matching**: Sizes from `bundleProductSizes` map are automatically matched with products from the bundle

✅ **Complete Product Data**: Bundle products now include:
- Product ID and Title
- Price and Quantity
- Size information
- Product Image
- Display-ready text

✅ **Methods for Display**:
- `getBundleProductsWithDetails(item)` - Get products with formatted display
- `formatOrderDetailsForDisplay(order)` - Get complete formatted order text
- `getBundleItemsWithSizes(order)` - Get sizes for all bundle items
- `getOrderBundleProductsSummary(order)` - Get bundle summary

## Summary

With these improvements, displaying bundle orders correctly is now straightforward:

1. **Fetch the order** - Automatic enrichment happens
2. **Check for bundle items** - `hasOrderBundleItems(order)`
3. **Display products** - Use `getBundleProductsWithDetails()` or access `item.getBundleProducts()`
4. **Show sizes** - Sizes are automatically populated from `bundleProductSizes`

The Firestore data structure is leveraged correctly to provide a seamless experience!
