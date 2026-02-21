# 📦 Display Bundle Products and Sizes - Complete Guide

## Overview

Bundle orders now properly store and display all products within the bundle along with their individual sizes, prices, and quantities.

## Data Structure

### New Field: `bundleProducts`

```dart
final List<Map<String, dynamic>>? bundleProducts;
```

**Structure of each product in bundle:**
```
{
  "productId": "prod_001",
  "title": "Summer T-Shirt",
  "quantity": 2,
  "price": "399",
  "image": "image_url.jpg",
  "size": "XL"
}
```

### Complete Bundle Item Example

```dart
OrderItem {
  bundleId: "bundle_123",
  bundleName: "Premium Summer Bundle",
  bundlePrice: "1799",
  bundleProductSizes: {
    "prod_001": "XL",
    "prod_002": "M",
    "prod_003": "L"
  },
  bundleProducts: [
    {
      "productId": "prod_001",
      "title": "Summer T-Shirt",
      "quantity": 2,
      "price": "399",
      "image": "url1.jpg",
      "size": "XL"
    },
    {
      "productId": "prod_002",
      "title": "Shorts",
      "quantity": 1,
      "price": "699",
      "image": "url2.jpg",
      "size": "M"
    },
    {
      "productId": "prod_003",
      "title": "Cap",
      "quantity": 1,
      "price": "299",
      "image": "url3.jpg",
      "size": "L"
    }
  ]
}
```

## Firestore Structure

```
orders/
└── {orderId}
    └── items[0]
        ├── bundleId: "bundle_123"
        ├── bundleName: "Premium Summer Bundle"
        ├── bundlePrice: 1799
        ├── bundleProductSizes: {
        │   "prod_001": "XL",
        │   "prod_002": "M",
        │   "prod_003": "L"
        │ }
        └── bundleProducts: [
            {
              "productId": "prod_001",
              "title": "Summer T-Shirt",
              "quantity": 2,
              "price": "399",
              "image": "url1.jpg",
              "size": "XL"
            },
            {
              "productId": "prod_002",
              "title": "Shorts",
              "quantity": 1,
              "price": "699",
              "image": "url2.jpg",
              "size": "M"
            },
            ...
          ]
```

## New Methods

### OrderItem Methods

```dart
// Get all products in bundle
List<Map<String, dynamic>> getBundleProducts()

// Get number of products in bundle
int getBundleProductCount()
// Returns: 3

// Get specific product from bundle
Map<String, dynamic>? getBundleProduct(String productId)
// Returns: {"productId": "prod_001", "title": "Summer T-Shirt", ...}

// Get formatted list of products
String formatBundleProductsList()
// Returns: "Summer T-Shirt (XL), Shorts (M), Cap (L)"
```

### OrderService Methods

```dart
// Get bundle products with complete details
List<Map<String, dynamic>> getBundleProductsWithDetails(OrderItem bundleItem)

// Get summary of all bundle products in order
List<Map<String, dynamic>> getOrderBundleProductsSummary(Order order)
```

## Simple Usage Examples

### Example 1: Display All Products

```dart
if (item.isBundleItem) {
  final products = item.getBundleProducts();
  
  print('Bundle: ${item.bundleName}');
  print('Products (${products.length}):');
  
  for (final product in products) {
    print('  - ${product['title']}');
    print('    Size: ${product['size']}');
    print('    Price: ₹${product['price']}');
    print('    Quantity: ${product['quantity']}');
  }
}
```

**Output:**
```
Bundle: Premium Summer Bundle
Products (3):
  - Summer T-Shirt
    Size: XL
    Price: ₹399
    Quantity: 2
  - Shorts
    Size: M
    Price: ₹699
    Quantity: 1
  - Cap
    Size: L
    Price: ₹299
    Quantity: 1
```

### Example 2: Get Formatted Product List

```dart
if (item.isBundleItem) {
  final formatted = item.formatBundleProductsList();
  print(formatted);
  // Output: "Summer T-Shirt (XL), Shorts (M), Cap (L)"
}
```

### Example 3: Get Specific Product

```dart
if (item.isBundleItem) {
  final product = item.getBundleProduct("prod_001");
  if (product != null) {
    print('${product['title']} - Size ${product['size']}');
  }
}
```

### Example 4: Service-Level Access

```dart
final order = await orderService.getOrderById(orderId);
final bundleSummary = orderService.getOrderBundleProductsSummary(order);

for (final bundle in bundleSummary) {
  print('Bundle: ${bundle['bundleName']}');
  for (final product in bundle['products'] as List) {
    print('  ${product['displayText']}');
    // Output: "Summer T-Shirt (Qty: 2) Size: XL • ₹399"
  }
}
```

## UI Display Examples

### Example 1: Simple Product List

```dart
Widget displayBundleProducts(OrderItem item) {
  if (!item.isBundleItem) return SizedBox.shrink();

  final products = item.getBundleProducts();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Bundle Products (${products.length})',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
      SizedBox(height: 8),
      ...products.map(
        (product) => Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product name and price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product['title'] ?? 'Unknown',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    '₹${product['price']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              // Size and quantity
              Row(
                children: [
                  if (product['size'] != null && product['size'].isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        'Size: ${product['size']}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  SizedBox(width: 8),
                  Text(
                    'Qty: ${product['quantity']}',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
```

### Example 2: Product Cards with Images

```dart
Widget displayBundleProductsWithImages(OrderItem item) {
  if (!item.isBundleItem) return SizedBox.shrink();

  final products = item.getBundleProducts();

  return Column(
    children: products.map(
      (product) => Card(
        margin: EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              if (product['image'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    product['image'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(width: 12),
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['title'] ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        if (product['size'] != null &&
                            product['size'].isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'Size: ${product['size']}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        SizedBox(width: 8),
                        Text(
                          'Qty: ${product['quantity']}',
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₹${product['price']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).toList(),
  );
}
```

### Example 3: Detailed Order View

```dart
class BundleOrderDetailWidget extends StatelessWidget {
  final Order order;
  final OrderService orderService;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...order.items.map((item) {
          if (!item.isBundleItem) return SizedBox.shrink();

          return Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 1),
              borderRadius: BorderRadius.circular(8),
              color: Colors.blue.shade50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bundle header
                Text(
                  item.bundleName ?? 'Bundle',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                SizedBox(height: 12),
                
                // Products
                Text(
                  'Bundle Products:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                ...item.getBundleProducts().map(
                  (product) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['title'] ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Qty: ${product['quantity']}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (product['size'] != null &&
                            product['size'].isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'Size: ${product['size']}',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        SizedBox(width: 8),
                        Text(
                          '₹${product['price']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12),
                
                // Bundle pricing
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Original: ₹${item.originalIndividualPrice}',
                          style: TextStyle(
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Bundle: ₹${item.bundlePrice}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
          );
        }),
      ],
    );
  }
}
```

### Example 4: Invoice/Receipt View

```dart
Widget buildBundleInvoiceDetails(Order order, OrderService orderService) {
  final bundleSummary = orderService.getOrderBundleProductsSummary(order);

  return Column(
    children: [
      Text(
        'Order Items',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
      SizedBox(height: 8),
      ...bundleSummary.map((bundle) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bundle name
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bundle['bundleName'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${bundle['bundlePrice']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 4),
            
            // Products in bundle
            ...(bundle['products'] as List).map(
              (product) => Padding(
                padding: EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product['displayText'] ?? '',
                        style: TextStyle(fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 12),
          ],
        );
      }),
    ],
  );
}
```

## Data Flow When Creating Order

When placing a bundle order, ensure `bundleProducts` is populated:

```dart
final bundleProducts = [
  {
    "productId": "prod_001",
    "title": "Summer T-Shirt",
    "quantity": 2,
    "price": "399",
    "image": "url1.jpg",
    "size": "XL"
  },
  {
    "productId": "prod_002",
    "title": "Shorts",
    "quantity": 1,
    "price": "699",
    "image": "url2.jpg",
    "size": "M"
  },
  {
    "productId": "prod_003",
    "title": "Cap",
    "quantity": 1,
    "price": "299",
    "image": "url3.jpg",
    "size": "L"
  }
];

final orderItem = OrderItem(
  bundleId: "bundle_123",
  bundleName: "Premium Summer Bundle",
  bundlePrice: "1799",
  bundleProductSizes: {
    "prod_001": "XL",
    "prod_002": "M",
    "prod_003": "L"
  },
  bundleProducts: bundleProducts,  // ✅ Include this
  // ... other fields
);
```

## Key Features

✅ **Complete Product Info**: Title, price, quantity, image, size all visible
✅ **Multiple Access Methods**: Get all products, specific product, or formatted list
✅ **Size Display**: Sizes shown at product level
✅ **UI Ready**: 4 complete UI examples provided
✅ **Invoice Friendly**: Display in receipts/invoices
✅ **Type-Safe**: Full Dart typing
✅ **No Breaking Changes**: Backward compatible

## Files Updated

1. `lib/models/order_item_model.dart` - Added bundleProducts field + 4 helper methods
2. `lib/services/order_service.dart` - Added 2 service methods + helper

## Summary

Bundle products are now:
- ✅ Stored with complete details (title, price, image, size, quantity)
- ✅ Automatically parsed from Firestore
- ✅ Accessible through simple helper methods
- ✅ Ready to display in UI
- ✅ Included in invoices and receipts

**All bundle products and sizes are now fully visible and displayable!** 🎉
