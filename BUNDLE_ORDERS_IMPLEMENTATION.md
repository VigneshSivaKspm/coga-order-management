# Bundle Orders Implementation Guide

## Overview

This implementation provides complete support for handling bundle orders in the COGA Order Management system. When a customer places a bundle order, the system now automatically:

1. **Checks the bundle ID** from order items
2. **Fetches bundle details** from the bundles collection
3. **Enriches order data** with complete product and bundle information
4. **Displays bundle details** correctly in order views

## Key Changes

### 1. **OrderItem Model** (`lib/models/order_item_model.dart`)

Added bundle-specific fields to track bundle information:

```dart
// Bundle-specific fields
final String? bundleId;           // Links to bundle document in bundles collection
final bool isBundleItem;          // Identifies this as a bundle item
final String? bundlePrice;        // The discounted bundle price
final String? bundleName;         // Name of the bundle
final String? originalIndividualPrice;  // Original product price before discount
```

#### New Helper Methods:
- `bundlePriceValue` - Get numeric bundle price
- `originalIndividualPriceValue` - Get numeric original price
- `bundleSavings` - Calculate total savings from bundle discount

### 2. **OrderService** (`lib/services/order_service.dart`)

Added comprehensive bundle handling methods:

#### **Bundle Data Fetching**
```dart
/// Fetch complete bundle details by ID
Future<Map<String, dynamic>?> getBundleDetails(String bundleId)

/// Get all products in a bundle
Future<List<Map<String, dynamic>>> getBundleProducts(String bundleId)
```

#### **Bundle Detection**
```dart
/// Check if order contains bundle items
bool hasOrderBundleItems(Order order)

/// Get all unique bundle IDs from order
List<String> getOrderBundleIds(Order order)

/// Get all bundle items from order
List<Map<String, dynamic>> getBundleItemsFromOrder(Order order)
```

#### **Bundle Enrichment**
```dart
/// Fetch bundle data and attach to order items
Future<Order> enrichOrderWithBundleDetails(Order order)

/// Get summary of all bundles in order
Future<List<Map<String, dynamic>>> getOrderBundleSummary(Order order)
```

#### **Enhanced Stream Methods**
- `getOrdersStream()` - Now enriches all orders with bundle details
- `getUserOrdersStream()` - Now enriches user orders with bundle details
- `getOrderById()` - Now enriches single order with bundle details
- `getOrderStream()` - Real-time order enrichment with bundle data

## How It Works

### When an Order is Placed

1. **Order Item Contains Bundle Metadata:**
```dart
OrderItem(
  productId: 'prod_001',
  title: 'Summer T-Shirt',
  bundleId: 'bundle_123',           // ✅ Links to bundles collection
  isBundleItem: true,               // ✅ Identified as bundle item
  bundlePrice: '1799',              // ✅ Discounted price
  bundleName: 'Premium Summer Bundle',
  originalIndividualPrice: '2499',  // ✅ Original price before discount
  // ... other fields
)
```

2. **Order is Fetched:**
```dart
final order = await orderService.getOrderById(orderId);
// System automatically:
// ✅ Detects bundle items
// ✅ Fetches bundles collection for each bundleId
// ✅ Enriches items with complete bundle details
// ✅ Returns enriched order with all data
```

3. **Bundle Details are Retrieved:**
```dart
final bundleDetails = await orderService.getBundleDetails('bundle_123');
// Returns:
{
  'name': 'Premium Summer Bundle',
  'description': 'Get 3 summer essentials at a special price',
  'products': [...],
  'bundlePrice': 1799,
  'originalTotalPrice': 2499,
  'discount': 28,
  'category': 'Summer',
  // ... other bundle data
}
```

## Usage Examples

### Example 1: Display Bundle Order Details

```dart
// Get enriched order
final order = await orderService.getOrderById(orderId);

// Check if order has bundles
if (orderService.hasOrderBundleItems(order)) {
  print('Order contains bundle items');
  
  // Get bundle IDs
  final bundleIds = orderService.getOrderBundleIds(order);
  print('Bundle IDs: $bundleIds');
  
  // Get all bundle items
  final bundleItems = orderService.getBundleItemsFromOrder(order);
  for (final item in bundleItems) {
    print('Bundle: ${item['bundleName']}');
    print('Product: ${item['title']}');
    print('Savings: ${item['savings']}');
  }
}
```

### Example 2: Show Bundle Summary

```dart
// Get comprehensive bundle summary
final bundleSummary = await orderService.getOrderBundleSummary(order);

for (final bundle in bundleSummary) {
  print('Bundle: ${bundle['name']}');
  print('Original Price: ${bundle['originalTotalPrice']}');
  print('Bundle Price: ${bundle['bundlePrice']}');
  print('Discount: ${bundle['discount']}%');
  print('Items: ${bundle['itemCount']}');
  
  // Get products in bundle
  final products = bundle['items'] as List;
  for (final product in products) {
    print('  - ${product['title']} (Qty: ${product['quantity']})');
  }
}
```

### Example 3: Stream Processing with Bundle Enrichment

```dart
// Get real-time orders with automatic bundle enrichment
orderService.getOrdersStream().listen((orders) {
  for (final order in orders) {
    // All bundle items are automatically enriched
    for (final item in order.items) {
      if (item.isBundleItem) {
        print('Bundle Item: ${item.title}');
        print('From Bundle: ${item.bundleName}');
        print('Bundle Price: ${item.bundlePrice}');
        print('Savings: ₹${item.bundleSavings}');
      }
    }
  }
});
```

### Example 4: Check Bundle Item Pricing

```dart
for (final item in order.items) {
  if (item.isBundleItem) {
    print('Product: ${item.title}');
    print('Individual Price: ${item.originalIndividualPrice}');
    print('Bundle Price: ${item.bundlePrice}');
    print('Per-Unit Savings: ₹${item.originalIndividualPriceValue - item.bundlePriceValue}');
    print('Total Savings (Qty ${item.quantity}): ₹${item.bundleSavings}');
  }
}
```

## Firebase Collections Integration

### Orders Collection
```
orders/
├── order_id_1/
│   ├── userId: "user_123"
│   ├── items: [
│   │   {
│   │     productId: "prod_001",
│   │     bundleId: "bundle_123",      ✅ Links to bundles collection
│   │     isBundleItem: true,
│   │     bundlePrice: "1799",
│   │     bundleName: "Premium Summer Bundle",
│   │     originalIndividualPrice: "2499"
│   │   }
│   │ ]
│   └── ...
```

### Bundles Collection
```
bundles/
├── bundle_123/
│   ├── name: "Premium Summer Bundle"
│   ├── description: "Get 3 summer essentials..."
│   ├── products: [
│   │   { productId: "prod_001", title: "Summer T-Shirt", quantity: 2, ... },
│   │   { productId: "prod_002", title: "Shorts", quantity: 1, ... }
│   │ ]
│   ├── bundlePrice: 1799
│   ├── originalTotalPrice: 2499
│   ├── discount: 28
│   └── ...
```

## Backend Integration Checklist

- ✅ **Order Creation**: Ensure order items include `bundleId` and `isBundleItem` when saving
- ✅ **Bundle Reference**: Store `bundleId` in each bundle item for cross-collection lookup
- ✅ **Price Tracking**: Include both `bundlePrice` and `originalIndividualPrice` in items
- ✅ **Bundle Details**: Maintain complete product list in bundles collection
- ✅ **Metadata**: Include `bundleName` in order items for offline display

## Error Handling

The implementation includes robust error handling:

```dart
// If bundle not found in collection, item keeps original data
final enrichedOrder = await orderService.enrichOrderWithBundleDetails(order);

// If enrichment fails, returns original order
if (order == enrichedOrder) {
  // No changes - either no bundles or error occurred
}

// Safe price conversions prevent crashes
double price = item.bundlePriceValue ?? 0.0;  // Returns 0.0 if null/invalid
```

## Display Recommendations

### For Bundle Orders in UI:

1. **Highlight Bundle Items:**
```
🎁 Bundle Order - Premium Summer Bundle
├── Summer T-Shirt (Qty: 2) - ₹799 → ₹599.5
├── Shorts (Qty: 1) - ₹699 → ₹699
└── Cap (Qty: 1) - ₹399 → ₹499.5
💰 Bundle Total: ₹2,499 → ₹1,799 (Save ₹700)
```

2. **Show Savings:**
```
Original Price: ₹2,499
Bundle Price: ₹1,799
You Saved: ₹700 (28% off)
```

3. **Product Details:**
```
Bundle: Premium Summer Bundle
├── Product 1: Summer T-Shirt
│   └── Individual Price: ₹499 | Bundle: ₹399.5
├── Product 2: Shorts
│   └── Individual Price: ₹699 | Bundle: ₹699
└── Product 3: Cap
│   └── Individual Price: ₹399 | Bundle: ₹499.5
```

## Performance Optimization

- **Lazy Loading**: Bundle details are fetched only when `enrichOrderWithBundleDetails()` is called
- **Caching**: Consider implementing solution-level caching for frequently accessed bundles
- **Batch Processing**: Use parallel futures for multiple bundle fetches

```dart
// Batch fetch multiple bundles
final bundleIds = ['bundle_1', 'bundle_2', 'bundle_3'];
final bundles = await Future.wait(
  bundleIds.map((id) => orderService.getBundleDetails(id))
);
```

## Testing

```dart
// Test bundle detection
expect(orderService.hasOrderBundleItems(bundleOrder), true);
expect(orderService.hasOrderBundleItems(regularOrder), false);

// Test bundle enrichment
final enriched = await orderService.enrichOrderWithBundleDetails(order);
expect(enriched.items.where((i) => i.bundleName != null).isNotEmpty, true);

// Test bundle summary
final summary = await orderService.getOrderBundleSummary(order);
expect(summary.isNotEmpty, true);
expect(summary.first['name'], isNotNull);
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Bundle details showing as null | Ensure `bundleId` exists in bundles collection |
| Empty product list in bundle | Check bundles > documents > products array |
| Price showing as 0 | Verify `bundlePrice` field format in order items |
| Enrichment not working | Confirm bundles collection exists with correct name |
| Stream not updating | Ensure Firestore rules allow reads on bundles collection |

## Future Enhancements

1. **Bundle Item Grouping**: Automatically group order items by bundle
2. **Bundle Analytics**: Track bundle popularity and savings
3. **Refund Handling**: Proper refund calculations for partial bundle returns
4. **Bundle Recommendations**: Show related or complementary bundles
5. **Bundle Expiry**: Track and display bundle availability status
