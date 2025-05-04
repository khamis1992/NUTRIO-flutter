import 'dart:async';
import 'dart:math';

import 'package:nutrio_wellness/features/meal_planner/data/models/meal_model.dart';
import 'package:nutrio_wellness/features/order_tracking/data/models/order_model.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isFromRider;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isFromRider,
  });
}

abstract class OrderService {
  Future<List<OrderModel>> getOrders({
    required String userId,
    OrderStatus? status,
  });
  
  Future<OrderModel> getOrderById(String orderId);
  
  Future<OrderModel> createOrder({
    required String userId,
    required List<OrderItem> items,
    required DeliveryAddress deliveryAddress,
    required PaymentInfo paymentInfo,
    String? notes,
  });
  
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? message,
  });
  
  Future<void> cancelOrder(String orderId);
  
  Future<List<OrderStatusUpdate>> getOrderStatusUpdates(String orderId);
  
  Future<void> sendMessageToRider({
    required String orderId,
    required String message,
  });
  
  Future<List<ChatMessage>> getOrderChat(String orderId);
  
  Stream<OrderModel> getOrderUpdates(String orderId);
  
  Stream<DeliveryRider> getRiderLocationUpdates(String riderId);
}

class OrderServiceImpl implements OrderService {
  // This is a mock implementation for demonstration purposes
  // In a real app, you would use a real API service
  
  // Mock orders data
  final List<OrderModel> _mockOrders = [
    OrderModel(
      id: '1',
      userId: 'user1',
      items: [
        OrderItem(
          id: '1',
          meal: MealModel(
            id: '1',
            name: 'Avocado Toast with Poached Eggs',
            description: 'A nutritious breakfast with creamy avocado and perfectly poached eggs on whole grain toast.',
            imageUrl: 'https://example.com/avocado_toast.jpg',
            calories: 350,
            preparationTime: 15,
            ingredients: [
              '2 slices whole grain bread',
              '1 ripe avocado',
              '2 eggs',
              '1 tbsp lemon juice',
              'Salt and pepper to taste',
              'Red pepper flakes (optional)',
            ],
            instructions: [
              'Toast the bread until golden and firm.',
              'While the bread is toasting, halve the avocado and remove the pit.',
              'Scoop the avocado flesh into a bowl and mash with a fork. Add lemon juice, salt, and pepper to taste.',
              'Bring a pot of water to a simmer. Add a splash of vinegar. Create a gentle whirlpool and crack an egg into the center. Cook for 3-4 minutes. Repeat with second egg.',
              'Spread the mashed avocado on the toast and top each with a poached egg.',
              'Season with salt, pepper, and red pepper flakes if desired.',
            ],
            nutritionFacts: {
              'protein': 14.0,
              'carbs': 30.0,
              'fat': 22.0,
              'fiber': 8.0,
            },
            mealType: MealType.breakfast,
            dietaryTypes: [DietaryType.vegetarian],
            rating: 4.7,
            reviewCount: 128,
          ),
          quantity: 2,
          price: 12.99,
          specialInstructions: ['No red pepper flakes'],
        ),
      ],
      orderTime: DateTime.now().subtract(const Duration(hours: 1)),
      estimatedDeliveryTime: DateTime.now().add(const Duration(minutes: 30)),
      subtotal: 25.98,
      tax: 2.08,
      deliveryFee: 3.99,
      total: 32.05,
      status: OrderStatus.outForDelivery,
      deliveryAddress: const DeliveryAddress(
        street: '123 Main St',
        city: 'San Francisco',
        state: 'CA',
        zipCode: '94105',
        country: 'USA',
        latitude: 37.7749,
        longitude: -122.4194,
      ),
      paymentInfo: const PaymentInfo(
        method: 'credit_card',
        cardType: 'Visa',
        last4: '4242',
        isPaid: true,
      ),
      rider: const DeliveryRider(
        id: 'rider1',
        name: 'John Doe',
        phone: '+1234567890',
        photoUrl: 'https://example.com/rider1.jpg',
        currentLatitude: 37.7739,
        currentLongitude: -122.4312,
        rating: 4.8,
      ),
      statusUpdates: [
        OrderStatusUpdate(
          status: OrderStatus.pending,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        OrderStatusUpdate(
          status: OrderStatus.confirmed,
          timestamp: DateTime.now().subtract(const Duration(minutes: 55)),
          message: 'Your order has been confirmed.',
        ),
        OrderStatusUpdate(
          status: OrderStatus.preparing,
          timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
          message: 'Your order is being prepared.',
        ),
        OrderStatusUpdate(
          status: OrderStatus.readyForPickup,
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
          message: 'Your order is ready for pickup.',
        ),
        OrderStatusUpdate(
          status: OrderStatus.outForDelivery,
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
          message: 'Your order is on the way.',
        ),
      ],
    ),
    OrderModel(
      id: '2',
      userId: 'user1',
      items: [
        OrderItem(
          id: '2',
          meal: MealModel(
            id: '3',
            name: 'Vegan Buddha Bowl',
            description: 'A colorful and nutritious bowl filled with roasted vegetables, quinoa, and tahini dressing.',
            imageUrl: 'https://example.com/buddha_bowl.jpg',
            calories: 380,
            preparationTime: 35,
            ingredients: [
              '1 cup cooked quinoa',
              '1 sweet potato, diced and roasted',
              '1 cup chickpeas, roasted',
              '1 cup kale, massaged',
              '1/2 avocado, sliced',
              '1/4 cup red cabbage, shredded',
              '2 tbsp tahini',
              '1 tbsp lemon juice',
              '1 tbsp maple syrup',
              'Salt and pepper to taste',
            ],
            instructions: [
              'Preheat oven to 400°F (200°C).',
              'Toss diced sweet potato and chickpeas with olive oil, salt, and pepper. Roast for 25-30 minutes.',
              'Cook quinoa according to package instructions.',
              'Massage kale with a bit of olive oil and salt until softened.',
              'Whisk together tahini, lemon juice, maple syrup, and 2-3 tbsp water to make the dressing.',
              'Assemble the bowl with quinoa, roasted vegetables, kale, avocado, and cabbage.',
              'Drizzle with tahini dressing and serve.',
            ],
            nutritionFacts: {
              'protein': 15.0,
              'carbs': 55.0,
              'fat': 16.0,
              'fiber': 14.0,
            },
            mealType: MealType.dinner,
            dietaryTypes: [DietaryType.vegan, DietaryType.glutenFree],
            rating: 4.8,
            reviewCount: 112,
          ),
          quantity: 1,
          price: 14.99,
        ),
      ],
      orderTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      estimatedDeliveryTime: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 30)),
      actualDeliveryTime: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 25)),
      subtotal: 14.99,
      tax: 1.20,
      deliveryFee: 3.99,
      total: 20.18,
      status: OrderStatus.delivered,
      deliveryAddress: const DeliveryAddress(
        street: '123 Main St',
        city: 'San Francisco',
        state: 'CA',
        zipCode: '94105',
        country: 'USA',
        latitude: 37.7749,
        longitude: -122.4194,
      ),
      paymentInfo: const PaymentInfo(
        method: 'paypal',
        isPaid: true,
      ),
      rider: const DeliveryRider(
        id: 'rider2',
        name: 'Jane Smith',
        phone: '+1987654321',
        photoUrl: 'https://example.com/rider2.jpg',
        rating: 4.9,
      ),
      statusUpdates: [
        OrderStatusUpdate(
          status: OrderStatus.pending,
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        ),
        OrderStatusUpdate(
          status: OrderStatus.confirmed,
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 55)),
          message: 'Your order has been confirmed.',
        ),
        OrderStatusUpdate(
          status: OrderStatus.preparing,
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 40)),
          message: 'Your order is being prepared.',
        ),
        OrderStatusUpdate(
          status: OrderStatus.readyForPickup,
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 20)),
          message: 'Your order is ready for pickup.',
        ),
        OrderStatusUpdate(
          status: OrderStatus.outForDelivery,
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 10)),
          message: 'Your order is on the way.',
        ),
        OrderStatusUpdate(
          status: OrderStatus.delivered,
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 25)),
          message: 'Your order has been delivered.',
        ),
      ],
    ),
  ];
  
  // Mock chat messages
  final Map<String, List<ChatMessage>> _mockChats = {
    '1': [
      ChatMessage(
        id: '1',
        senderId: 'user1',
        senderName: 'You',
        message: 'Hi, are you close to my location?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        isFromRider: false,
      ),
      ChatMessage(
        id: '2',
        senderId: 'rider1',
        senderName: 'John Doe',
        message: 'Yes, I\'m about 5 minutes away.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 7)),
        isFromRider: true,
      ),
      ChatMessage(
        id: '3',
        senderId: 'user1',
        senderName: 'You',
        message: 'Great! Please call me when you arrive.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
        isFromRider: false,
      ),
      ChatMessage(
        id: '4',
        senderId: 'rider1',
        senderName: 'John Doe',
        message: 'Will do!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isFromRider: true,
      ),
    ],
  };
  
  // Streams for real-time updates
  final Map<String, StreamController<OrderModel>> _orderStreamControllers = {};
  final Map<String, StreamController<DeliveryRider>> _riderStreamControllers = {};

  @override
  Future<List<OrderModel>> getOrders({
    required String userId,
    OrderStatus? status,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Filter orders by user ID and status
    return _mockOrders.where((order) {
      bool matchesUserId = order.userId == userId;
      bool matchesStatus = status == null || order.status == status;
      return matchesUserId && matchesStatus;
    }).toList();
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Find order by ID
    final order = _mockOrders.firstWhere(
      (order) => order.id == orderId,
      orElse: () => throw Exception('Order not found'),
    );
    
    return order;
  }

  @override
  Future<OrderModel> createOrder({
    required String userId,
    required List<OrderItem> items,
    required DeliveryAddress deliveryAddress,
    required PaymentInfo paymentInfo,
    String? notes,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Calculate order totals
    double subtotal = items.fold(0, (sum, item) => sum + (item.price * item.quantity));
    double tax = subtotal * 0.08; // 8% tax
    double deliveryFee = 3.99;
    double total = subtotal + tax + deliveryFee;
    
    // Create new order
    final newOrder = OrderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      items: items,
      orderTime: DateTime.now(),
      estimatedDeliveryTime: DateTime.now().add(const Duration(minutes: 45)),
      subtotal: subtotal,
      tax: tax,
      deliveryFee: deliveryFee,
      total: total,
      status: OrderStatus.pending,
      deliveryAddress: deliveryAddress,
      paymentInfo: paymentInfo,
      statusUpdates: [
        OrderStatusUpdate(
          status: OrderStatus.pending,
          timestamp: DateTime.now(),
          message: 'Your order has been placed.',
        ),
      ],
      notes: notes,
    );
    
    // Add to mock orders
    _mockOrders.add(newOrder);
    
    // Create stream controller for this order if it doesn't exist
    if (!_orderStreamControllers.containsKey(newOrder.id)) {
      _orderStreamControllers[newOrder.id] = StreamController<OrderModel>.broadcast();
    }
    
    // Simulate order confirmation after a delay
    Future.delayed(const Duration(seconds: 5), () {
      final updatedOrder = newOrder.copyWith(
        status: OrderStatus.confirmed,
        statusUpdates: [
          ...newOrder.statusUpdates,
          OrderStatusUpdate(
            status: OrderStatus.confirmed,
            timestamp: DateTime.now(),
            message: 'Your order has been confirmed.',
          ),
        ],
      );
      
      // Update mock orders
      final index = _mockOrders.indexWhere((order) => order.id == newOrder.id);
      if (index != -1) {
        _mockOrders[index] = updatedOrder;
      }
      
      // Send update to stream
      _orderStreamControllers[newOrder.id]?.add(updatedOrder);
    });
    
    return newOrder;
  }

  @override
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? message,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Find order by ID
    final index = _mockOrders.indexWhere((order) => order.id == orderId);
    if (index == -1) {
      throw Exception('Order not found');
    }
    
    // Update order status
    final order = _mockOrders[index];
    final updatedOrder = order.copyWith(
      status: status,
      statusUpdates: [
        ...order.statusUpdates,
        OrderStatusUpdate(
          status: status,
          timestamp: DateTime.now(),
          message: message,
        ),
      ],
    );
    
    // Update mock orders
    _mockOrders[index] = updatedOrder;
    
    // Send update to stream
    _orderStreamControllers[orderId]?.add(updatedOrder);
    
    return updatedOrder;
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Find order by ID
    final index = _mockOrders.indexWhere((order) => order.id == orderId);
    if (index == -1) {
      throw Exception('Order not found');
    }
    
    // Update order status to cancelled
    final order = _mockOrders[index];
    final updatedOrder = order.copyWith(
      status: OrderStatus.cancelled,
      statusUpdates: [
        ...order.statusUpdates,
        OrderStatusUpdate(
          status: OrderStatus.cancelled,
          timestamp: DateTime.now(),
          message: 'Your order has been cancelled.',
        ),
      ],
    );
    
    // Update mock orders
    _mockOrders[index] = updatedOrder;
    
    // Send update to stream
    _orderStreamControllers[orderId]?.add(updatedOrder);
  }

  @override
  Future<List<OrderStatusUpdate>> getOrderStatusUpdates(String orderId) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Find order by ID
    final order = _mockOrders.firstWhere(
      (order) => order.id == orderId,
      orElse: () => throw Exception('Order not found'),
    );
    
    return order.statusUpdates;
  }

  @override
  Future<void> sendMessageToRider({
    required String orderId,
    required String message,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Find order by ID
    final order = _mockOrders.firstWhere(
      (order) => order.id == orderId,
      orElse: () => throw Exception('Order not found'),
    );
    
    if (order.rider == null) {
      throw Exception('No rider assigned to this order');
    }
    
    // Create new chat message
    final chatMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: order.userId,
      senderName: 'You',
      message: message,
      timestamp: DateTime.now(),
      isFromRider: false,
    );
    
    // Add to mock chats
    if (!_mockChats.containsKey(orderId)) {
      _mockChats[orderId] = [];
    }
    _mockChats[orderId]!.add(chatMessage);
    
    // Simulate rider response after a delay
    Future.delayed(const Duration(seconds: 2), () {
      final responses = [
        'I\'m on my way!',
        'Got it, thanks!',
        'I\'ll be there soon.',
        'No problem, I\'ll take care of it.',
        'Thanks for letting me know.',
      ];
      
      final riderResponse = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: order.rider!.id,
        senderName: order.rider!.name,
        message: responses[Random().nextInt(responses.length)],
        timestamp: DateTime.now(),
        isFromRider: true,
      );
      
      _mockChats[orderId]!.add(riderResponse);
    });
  }

  @override
  Future<List<ChatMessage>> getOrderChat(String orderId) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return chat messages for this order
    return _mockChats[orderId] ?? [];
  }

  @override
  Stream<OrderModel> getOrderUpdates(String orderId) {
    // Create stream controller if it doesn't exist
    if (!_orderStreamControllers.containsKey(orderId)) {
      _orderStreamControllers[orderId] = StreamController<OrderModel>.broadcast();
      
      // Find order by ID
      try {
        final order = _mockOrders.firstWhere((order) => order.id == orderId);
        
        // Add initial value
        _orderStreamControllers[orderId]!.add(order);
        
        // Simulate order status updates for active orders
        if (order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled) {
          _simulateOrderUpdates(order);
        }
      } catch (e) {
        _orderStreamControllers[orderId]!.addError('Order not found');
      }
    }
    
    return _orderStreamControllers[orderId]!.stream;
  }

  @override
  Stream<DeliveryRider> getRiderLocationUpdates(String riderId) {
    // Create stream controller if it doesn't exist
    if (!_riderStreamControllers.containsKey(riderId)) {
      _riderStreamControllers[riderId] = StreamController<DeliveryRider>.broadcast();
      
      // Find rider
      try {
        final order = _mockOrders.firstWhere((order) => order.rider?.id == riderId);
        final rider = order.rider!;
        
        // Add initial value
        _riderStreamControllers[riderId]!.add(rider);
        
        // Simulate rider location updates for active orders
        if (order.status == OrderStatus.outForDelivery) {
          _simulateRiderLocationUpdates(rider, order.deliveryAddress);
        }
      } catch (e) {
        _riderStreamControllers[riderId]!.addError('Rider not found');
      }
    }
    
    return _riderStreamControllers[riderId]!.stream;
  }

  // Helper method to simulate order status updates
  void _simulateOrderUpdates(OrderModel order) {
    // Only simulate updates for orders that are not delivered or cancelled
    if (order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled) {
      return;
    }
    
    // Determine next status
    OrderStatus nextStatus;
    switch (order.status) {
      case OrderStatus.pending:
        nextStatus = OrderStatus.confirmed;
        break;
      case OrderStatus.confirmed:
        nextStatus = OrderStatus.preparing;
        break;
      case OrderStatus.preparing:
        nextStatus = OrderStatus.readyForPickup;
        break;
      case OrderStatus.readyForPickup:
        nextStatus = OrderStatus.outForDelivery;
        break;
      case OrderStatus.outForDelivery:
        nextStatus = OrderStatus.delivered;
        break;
      default:
        return;
    }
    
    // Simulate delay before next update
    Future.delayed(Duration(seconds: 10 + Random().nextInt(20)), () {
      // Find order by ID (it might have been updated)
      final index = _mockOrders.indexWhere((o) => o.id == order.id);
      if (index == -1) return;
      
      final currentOrder = _mockOrders[index];
      
      // Only update if the status hasn't changed
      if (currentOrder.status == order.status) {
        // Update order status
        final updatedOrder = currentOrder.copyWith(
          status: nextStatus,
          statusUpdates: [
            ...currentOrder.statusUpdates,
            OrderStatusUpdate(
              status: nextStatus,
              timestamp: DateTime.now(),
              message: _getStatusMessage(nextStatus),
            ),
          ],
          // Add rider if the order is out for delivery
          rider: nextStatus == OrderStatus.outForDelivery && currentOrder.rider == null
              ? const DeliveryRider(
                  id: 'rider1',
                  name: 'John Doe',
                  phone: '+1234567890',
                  photoUrl: 'https://example.com/rider1.jpg',
                  currentLatitude: 37.7739,
                  currentLongitude: -122.4312,
                  rating: 4.8,
                )
              : currentOrder.rider,
          // Set actual delivery time if the order is delivered
          actualDeliveryTime: nextStatus == OrderStatus.delivered
              ? DateTime.now()
              : currentOrder.actualDeliveryTime,
        );
        
        // Update mock orders
        _mockOrders[index] = updatedOrder;
        
        // Send update to stream
        _orderStreamControllers[order.id]?.add(updatedOrder);
        
        // Continue simulation for next status
        _simulateOrderUpdates(updatedOrder);
      }
    });
  }

  // Helper method to simulate rider location updates
  void _simulateRiderLocationUpdates(DeliveryRider rider, DeliveryAddress deliveryAddress) {
    // Only simulate updates if we have both rider and delivery coordinates
    if (rider.currentLatitude == null || rider.currentLongitude == null ||
        deliveryAddress.latitude == null || deliveryAddress.longitude == null) {
      return;
    }
    
    // Calculate distance and direction
    final double startLat = rider.currentLatitude!;
    final double startLng = rider.currentLongitude!;
    final double endLat = deliveryAddress.latitude!;
    final double endLng = deliveryAddress.longitude!;
    
    // Simulate movement every few seconds
    Future.delayed(const Duration(seconds: 3), () {
      // Move rider closer to destination
      final double progress = Random().nextDouble() * 0.1; // Move 0-10% of remaining distance
      final double newLat = startLat + (endLat - startLat) * progress;
      final double newLng = startLng + (endLng - startLng) * progress;
      
      // Update rider location
      final updatedRider = DeliveryRider(
        id: rider.id,
        name: rider.name,
        phone: rider.phone,
        photoUrl: rider.photoUrl,
        currentLatitude: newLat,
        currentLongitude: newLng,
        rating: rider.rating,
      );
      
      // Send update to stream
      _riderStreamControllers[rider.id]?.add(updatedRider);
      
      // Continue simulation if not at destination
      final double remainingDistance = _calculateDistance(newLat, newLng, endLat, endLng);
      if (remainingDistance > 0.01) { // If more than 10 meters away
        _simulateRiderLocationUpdates(updatedRider, deliveryAddress);
      }
    });
  }

  // Helper method to calculate distance between coordinates
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295; // Math.PI / 180
    final double a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  // Helper method to get status message
  String _getStatusMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Your order has been placed.';
      case OrderStatus.confirmed:
        return 'Your order has been confirmed.';
      case OrderStatus.preparing:
        return 'Your order is being prepared.';
      case OrderStatus.readyForPickup:
        return 'Your order is ready for pickup.';
      case OrderStatus.outForDelivery:
        return 'Your order is on the way.';
      case OrderStatus.delivered:
        return 'Your order has been delivered.';
      case OrderStatus.cancelled:
        return 'Your order has been cancelled.';
    }
  }
}
