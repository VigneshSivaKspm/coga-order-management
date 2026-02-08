import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/order_card.dart';
import '../../widgets/order_filters.dart';
import '../../widgets/loading_widget.dart';
import 'order_detail_screen.dart';

/// Screen showing list of all orders with search and filter capabilities
class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _currentOrdersScrollController = ScrollController();
  final ScrollController _previousOrdersScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _setupScrollListeners();
  }

  void _setupScrollListeners() {
    _currentOrdersScrollController.addListener(() {
      if (_currentOrdersScrollController.position.pixels >=
          _currentOrdersScrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });

    _previousOrdersScrollController.addListener(() {
      if (_previousOrdersScrollController.position.pixels >=
          _previousOrdersScrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  void _loadMore() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    if (orderProvider.hasMore && !orderProvider.isLoading) {
      orderProvider.loadMore();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _currentOrdersScrollController.dispose();
    _previousOrdersScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Orders',
          style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              Container(height: 1, color: kBorderColor),
              TabBar(
                controller: _tabController,
                labelColor: kPrimaryColor,
                unselectedLabelColor: kTextSecondary,
                indicatorColor: kPrimaryColor,
                indicatorWeight: 2,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Current Orders'),
                  Tab(text: 'Previous Orders'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Filters
          Consumer<OrderProvider>(
            builder: (context, orderProvider, child) {
              return OrderFilters(
                initialSearchQuery: orderProvider.searchQuery,
                initialStatusFilter: orderProvider.statusFilter,
                onSearchChanged: (query) {
                  orderProvider.setSearchQuery(query);
                },
                onStatusChanged: (status) {
                  orderProvider.setStatusFilter(status);
                },
              );
            },
          ),

          // Orders List
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
                  return const OrderListLoading();
                }

                if (orderProvider.error != null &&
                    orderProvider.orders.isEmpty) {
                  return _buildErrorState(orderProvider);
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // Current Orders Tab
                    _buildOrdersList(
                      orders: orderProvider.currentOrders,
                      scrollController: _currentOrdersScrollController,
                      hasMore: orderProvider.hasMoreCurrentOrders(),
                      isLoading: orderProvider.isLoading,
                      emptyMessage: 'No current orders',
                      onRefresh: () async {
                        orderProvider.refresh();
                      },
                    ),

                    // Previous Orders Tab
                    _buildOrdersList(
                      orders: orderProvider.previousOrders,
                      scrollController: _previousOrdersScrollController,
                      hasMore: orderProvider.hasMorePreviousOrders(),
                      isLoading: orderProvider.isLoading,
                      emptyMessage: 'No previous orders',
                      onRefresh: () async {
                        orderProvider.refresh();
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList({
    required List<Order> orders,
    required ScrollController scrollController,
    required bool hasMore,
    required bool isLoading,
    required String emptyMessage,
    required Future<void> Function() onRefresh,
  }) {
    if (orders.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(kDefaultPadding),
        itemCount: orders.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == orders.length) {
            // Load more indicator
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kPrimaryColor,
                        ),
                      )
                    : TextButton(
                        onPressed: _loadMore,
                        child: const Text('Load More'),
                      ),
              ),
            );
          }

          final order = orders[index];
          return OrderCard(
            order: order,
            serialNumber: index + 1,
            onTap: () => _navigateToOrderDetail(order),
            onViewPressed: () => _navigateToOrderDetail(order),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: kSurfaceColor,
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 40,
              color: kTextTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Orders matching your filters will appear here',
            style: TextStyle(fontSize: 14, color: kTextTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(OrderProvider orderProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: kErrorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 40,
              color: kErrorColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            orderProvider.error ?? kErrorLoadOrders,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              orderProvider.clearError();
              orderProvider.loadOrders();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kDefaultRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToOrderDetail(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
    );
  }
}
