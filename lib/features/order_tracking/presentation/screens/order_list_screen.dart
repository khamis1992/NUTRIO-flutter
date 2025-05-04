import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrio_wellness/core/theme/app_colors.dart';
import 'package:nutrio_wellness/features/order_tracking/data/models/order_model.dart';
import 'package:nutrio_wellness/features/order_tracking/presentation/bloc/order_tracking_bloc.dart';
import 'package:nutrio_wellness/features/order_tracking/presentation/widgets/order_list_item.dart';
import 'package:nutrio_wellness/routes.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({Key? key}) : super(key: key);

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load active orders initially
    _loadActiveOrders();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _loadActiveOrders() {
    context.read<OrderTrackingBloc>().add(
      const LoadOrders(
        status: null, // Load all active orders (not delivered or cancelled)
      ),
    );
  }
  
  void _loadPastOrders() {
    context.read<OrderTrackingBloc>().add(
      const LoadOrders(
        status: OrderStatus.delivered,
      ),
    );
  }
  
  void _navigateToOrderDetails(String orderId) {
    Navigator.of(context).pushNamed(
      AppRoutes.orderTracking,
      arguments: {'orderId': orderId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            if (index == 0) {
              _loadActiveOrders();
            } else {
              _loadPastOrders();
            }
          },
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(isActive: true),
          _buildOrdersList(isActive: false),
        ],
      ),
    );
  }
  
  Widget _buildOrdersList({required bool isActive}) {
    return BlocBuilder<OrderTrackingBloc, OrderTrackingState>(
      builder: (context, state) {
        if (state is OrderTrackingLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is OrdersLoaded) {
          final orders = state.orders;
          
          // Filter orders based on tab
          final filteredOrders = isActive
              ? orders.where((order) => 
                  order.status != OrderStatus.delivered && 
                  order.status != OrderStatus.cancelled).toList()
              : orders.where((order) => 
                  order.status == OrderStatus.delivered || 
                  order.status == OrderStatus.cancelled).toList();
          
          if (filteredOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isActive
                        ? 'No active orders'
                        : 'No past orders',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isActive
                        ? 'Your active orders will appear here'
                        : 'Your order history will appear here',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              if (isActive) {
                _loadActiveOrders();
              } else {
                _loadPastOrders();
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return OrderListItem(
                  order: order,
                  onTap: () => _navigateToOrderDetails(order.id),
                );
              },
            ),
          );
        } else if (state is OrderTrackingError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${state.message}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (isActive) {
                      _loadActiveOrders();
                    } else {
                      _loadPastOrders();
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
