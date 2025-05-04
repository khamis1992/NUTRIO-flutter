import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nutrio_wellness/core/theme/app_colors.dart';
import 'package:nutrio_wellness/features/order_tracking/data/models/order_model.dart';
import 'package:nutrio_wellness/features/order_tracking/presentation/bloc/order_tracking_bloc.dart';
import 'package:nutrio_wellness/features/order_tracking/presentation/widgets/order_item_card.dart';
import 'package:nutrio_wellness/features/order_tracking/presentation/widgets/order_status_timeline.dart';
import 'package:nutrio_wellness/features/order_tracking/presentation/widgets/rider_info_card.dart';
import 'package:nutrio_wellness/routes.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng? _riderPosition;
  LatLng? _deliveryPosition;
  
  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }
  
  @override
  void dispose() {
    _mapController?.dispose();
    // Stop listening for updates
    context.read<OrderTrackingBloc>().add(StopOrderUpdates(widget.orderId));
    super.dispose();
  }
  
  void _loadOrderDetails() {
    context.read<OrderTrackingBloc>().add(LoadOrderDetails(widget.orderId));
  }
  
  void _openChat(OrderModel order) {
    if (order.rider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No rider assigned yet')),
      );
      return;
    }
    
    Navigator.of(context).pushNamed(
      AppRoutes.orderChat,
      arguments: {'orderId': order.id},
    );
  }
  
  void _cancelOrder(OrderModel order) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<OrderTrackingBloc>().add(CancelOrder(order.id));
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
  
  void _updateMapMarkers(OrderModel order) {
    final markers = <Marker>{};
    
    // Add delivery location marker
    if (order.deliveryAddress.latitude != null && order.deliveryAddress.longitude != null) {
      final deliveryPosition = LatLng(
        order.deliveryAddress.latitude!,
        order.deliveryAddress.longitude!,
      );
      
      _deliveryPosition = deliveryPosition;
      
      markers.add(
        Marker(
          markerId: const MarkerId('delivery'),
          position: deliveryPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Delivery Location'),
        ),
      );
    }
    
    // Add rider marker if available
    if (order.rider != null && 
        order.rider!.currentLatitude != null && 
        order.rider!.currentLongitude != null) {
      final riderPosition = LatLng(
        order.rider!.currentLatitude!,
        order.rider!.currentLongitude!,
      );
      
      _riderPosition = riderPosition;
      
      markers.add(
        Marker(
          markerId: const MarkerId('rider'),
          position: riderPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: 'Rider: ${order.rider!.name}'),
        ),
      );
    }
    
    setState(() {
      _markers = markers;
    });
    
    // Update camera position
    _updateCameraPosition();
  }
  
  void _updateCameraPosition() {
    if (_mapController == null) return;
    
    if (_riderPosition != null && _deliveryPosition != null) {
      // Calculate bounds that include both rider and delivery location
      final bounds = LatLngBounds(
        southwest: LatLng(
          _riderPosition!.latitude < _deliveryPosition!.latitude
              ? _riderPosition!.latitude
              : _deliveryPosition!.latitude,
          _riderPosition!.longitude < _deliveryPosition!.longitude
              ? _riderPosition!.longitude
              : _deliveryPosition!.longitude,
        ),
        northeast: LatLng(
          _riderPosition!.latitude > _deliveryPosition!.latitude
              ? _riderPosition!.latitude
              : _deliveryPosition!.latitude,
          _riderPosition!.longitude > _deliveryPosition!.longitude
              ? _riderPosition!.longitude
              : _deliveryPosition!.longitude,
        ),
      );
      
      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    } else if (_riderPosition != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_riderPosition!, 15));
    } else if (_deliveryPosition != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_deliveryPosition!, 15));
    }
  }
  
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _updateCameraPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
      ),
      body: BlocConsumer<OrderTrackingBloc, OrderTrackingState>(
        listener: (context, state) {
          if (state is OrderDetailsLoaded) {
            _updateMapMarkers(state.order);
          } else if (state is RiderLocationUpdating) {
            // Update rider marker
            if (_markers.isNotEmpty && _deliveryPosition != null) {
              final riderPosition = LatLng(
                state.rider.currentLatitude!,
                state.rider.currentLongitude!,
              );
              
              _riderPosition = riderPosition;
              
              setState(() {
                _markers = {
                  ..._markers.where((marker) => marker.markerId.value != 'rider'),
                  Marker(
                    markerId: const MarkerId('rider'),
                    position: riderPosition,
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                    infoWindow: InfoWindow(title: 'Rider: ${state.rider.name}'),
                  ),
                };
              });
              
              _updateCameraPosition();
            }
          } else if (state is OrderCancelled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Order cancelled successfully')),
            );
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          if (state is OrderTrackingLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrderDetailsLoaded || state is RiderLocationUpdating) {
            final OrderModel order = state is OrderDetailsLoaded
                ? state.order
                : (state as RiderLocationUpdating).rider.id == widget.orderId
                    ? (context.read<OrderTrackingBloc>().state as OrderDetailsLoaded).order
                    : (context.read<OrderTrackingBloc>().state as OrderDetailsLoaded).order;
            
            return _buildOrderDetails(order);
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
                    onPressed: _loadOrderDetails,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
  
  Widget _buildOrderDetails(OrderModel order) {
    final bool isActiveOrder = order.status != OrderStatus.delivered && 
                              order.status != OrderStatus.cancelled;
    
    return Column(
      children: [
        // Map section (only for active orders with delivery)
        if (isActiveOrder && order.status == OrderStatus.outForDelivery)
          SizedBox(
            height: 200,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.7749, -122.4194), // Default position
                zoom: 14,
              ),
              markers: _markers,
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: true,
            ),
          ),
        
        // Order details
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID and date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy • h:mm a').format(order.orderTime),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Order status
                OrderStatusTimeline(
                  statusUpdates: order.statusUpdates,
                  currentStatus: order.status,
                ),
                const SizedBox(height: 24),
                
                // Estimated delivery time
                if (order.status != OrderStatus.delivered && 
                    order.status != OrderStatus.cancelled && 
                    order.estimatedDeliveryTime != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Estimated Delivery',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                DateFormat('h:mm a').format(order.estimatedDeliveryTime!),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Actual delivery time
                if (order.status == OrderStatus.delivered && order.actualDeliveryTime != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Delivered At',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                DateFormat('h:mm a').format(order.actualDeliveryTime!),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                
                if (order.status == OrderStatus.cancelled)
                  const Card(
                    color: Color(0xFFFDEDED),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cancel,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Order Cancelled',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Rider information
                if (order.rider != null && order.status == OrderStatus.outForDelivery)
                  RiderInfoCard(
                    rider: order.rider!,
                    onChatPressed: () => _openChat(order),
                    onCallPressed: () {
                      // Implement call functionality
                    },
                  ),
                
                const SizedBox(height: 16),
                
                // Delivery address
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.location_on, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'Delivery Address',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${order.deliveryAddress.street}, ${order.deliveryAddress.city}, ${order.deliveryAddress.state} ${order.deliveryAddress.zipCode}',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        if (order.deliveryAddress.instructions != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Instructions: ${order.deliveryAddress.instructions}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Order items
                const Text(
                  'Order Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...order.items.map((item) => OrderItemCard(item: item)),
                
                const SizedBox(height: 16),
                
                // Order summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryRow('Subtotal', '\$${order.subtotal.toStringAsFixed(2)}'),
                        _buildSummaryRow('Tax', '\$${order.tax.toStringAsFixed(2)}'),
                        _buildSummaryRow('Delivery Fee', '\$${order.deliveryFee.toStringAsFixed(2)}'),
                        const Divider(),
                        _buildSummaryRow(
                          'Total',
                          '\$${order.total.toStringAsFixed(2)}',
                          isBold: true,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.payment,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Paid with ${_formatPaymentMethod(order.paymentInfo)}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Cancel button (only for pending or confirmed orders)
                if (order.status == OrderStatus.pending || order.status == OrderStatus.confirmed)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _cancelOrder(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel Order'),
                    ),
                  ),
                
                // Chat with rider button (only for active orders with rider)
                if (isActiveOrder && order.rider != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openChat(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.chat),
                      label: const Text('Chat with Rider'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatPaymentMethod(PaymentInfo paymentInfo) {
    if (paymentInfo.method == 'credit_card' && paymentInfo.cardType != null && paymentInfo.last4 != null) {
      return '${paymentInfo.cardType} ending in ${paymentInfo.last4}';
    } else if (paymentInfo.method == 'paypal') {
      return 'PayPal';
    } else if (paymentInfo.method == 'cash') {
      return 'Cash on Delivery';
    } else {
      return paymentInfo.method;
    }
  }
}
