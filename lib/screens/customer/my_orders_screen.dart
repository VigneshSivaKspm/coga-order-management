import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/order_card.dart';
import '../../widgets/loading_widget.dart';
import '../login_screen.dart';
import 'track_order_screen.dart';

/// Screen showing orders for the logged-in customer
class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserOrders();
  }

  void _loadUserOrders() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      if (authProvider.isAuthenticated && authProvider.userId != null) {
        orderProvider.loadUserOrders(authProvider.userId!);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) {
          return _buildLoginPrompt();
        }

        return Scaffold(
          backgroundColor: kBackgroundColor,
          appBar: AppBar(
            title: const Text(
              'My Orders',
              style: TextStyle(
                color: kTextPrimary,
                fontWeight: FontWeight.w600,
              ),
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
          body: Consumer<OrderProvider>(
            builder: (context, orderProvider, child) {
              if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
                return const OrderListLoading();
              }

              // Only show error if there are no orders AND there's an error
              // If orders were loaded previously, keep them visible even if there's a new error
              if (orderProvider.error != null &&
                  orderProvider.orders.isEmpty &&
                  !orderProvider.isLoading) {
                return _buildErrorState(orderProvider);
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  // Current Orders Tab
                  _buildOrdersList(
                    orders: orderProvider.currentOrders,
                    emptyMessage: 'No current orders',
                    emptyDescription: 'Your active orders will appear here',
                    onRefresh: () async {
                      final userId = authProvider.userId;
                      if (userId != null) {
                        orderProvider.loadUserOrders(userId);
                      }
                    },
                  ),

                  // Previous Orders Tab
                  _buildOrdersList(
                    orders: orderProvider.previousOrders,
                    emptyMessage: 'No previous orders',
                    emptyDescription: 'Your completed orders will appear here',
                    onRefresh: () async {
                      final userId = authProvider.userId;
                      if (userId != null) {
                        orderProvider.loadUserOrders(userId);
                      }
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoginPrompt() {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(kLargePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: kSurfaceColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 50,
                  color: kTextTertiary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Please Log In',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: kTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                kErrorLogin,
                style: TextStyle(fontSize: 14, color: kTextSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kDefaultRadius),
                  ),
                ),
                child: const Text(
                  'Log In',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList({
    required List<Order> orders,
    required String emptyMessage,
    required String emptyDescription,
    required Future<void> Function() onRefresh,
  }) {
    if (orders.isEmpty) {
      return _buildEmptyState(emptyMessage, emptyDescription);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(kDefaultPadding),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return CompactOrderCard(
            order: order,
            onTrackPressed: () => _navigateToTrackOrder(order),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message, String description) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kLargePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: kSurfaceColor,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 50,
                color: kTextTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: kTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(OrderProvider orderProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kLargePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: kErrorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 50,
                color: kErrorColor,
              ),
            ),
            const SizedBox(height: 24),
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
                _loadUserOrders();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kDefaultRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTrackOrder(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TrackOrderScreen(order: order)),
    );
  }
}
