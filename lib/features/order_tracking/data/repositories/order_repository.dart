import 'package:nutrio_wellness/features/order_tracking/data/models/order_model.dart';
import 'package:nutrio_wellness/features/order_tracking/data/services/order_service.dart';

abstract class OrderRepository {
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

class OrderRepositoryImpl implements OrderRepository {
  final OrderService _orderService;

  OrderRepositoryImpl(this._orderService);

  @override
  Future<List<OrderModel>> getOrders({
    required String userId,
    OrderStatus? status,
  }) async {
    try {
      return await _orderService.getOrders(
        userId: userId,
        status: status,
      );
    } catch (e) {
      throw Exception('Failed to get orders: ${e.toString()}');
    }
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      return await _orderService.getOrderById(orderId);
    } catch (e) {
      throw Exception('Failed to get order: ${e.toString()}');
    }
  }

  @override
  Future<OrderModel> createOrder({
    required String userId,
    required List<OrderItem> items,
    required DeliveryAddress deliveryAddress,
    required PaymentInfo paymentInfo,
    String? notes,
  }) async {
    try {
      return await _orderService.createOrder(
        userId: userId,
        items: items,
        deliveryAddress: deliveryAddress,
        paymentInfo: paymentInfo,
        notes: notes,
      );
    } catch (e) {
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }

  @override
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? message,
  }) async {
    try {
      return await _orderService.updateOrderStatus(
        orderId: orderId,
        status: status,
        message: message,
      );
    } catch (e) {
      throw Exception('Failed to update order status: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    try {
      await _orderService.cancelOrder(orderId);
    } catch (e) {
      throw Exception('Failed to cancel order: ${e.toString()}');
    }
  }

  @override
  Future<List<OrderStatusUpdate>> getOrderStatusUpdates(String orderId) async {
    try {
      return await _orderService.getOrderStatusUpdates(orderId);
    } catch (e) {
      throw Exception('Failed to get order status updates: ${e.toString()}');
    }
  }

  @override
  Future<void> sendMessageToRider({
    required String orderId,
    required String message,
  }) async {
    try {
      await _orderService.sendMessageToRider(
        orderId: orderId,
        message: message,
      );
    } catch (e) {
      throw Exception('Failed to send message to rider: ${e.toString()}');
    }
  }

  @override
  Future<List<ChatMessage>> getOrderChat(String orderId) async {
    try {
      return await _orderService.getOrderChat(orderId);
    } catch (e) {
      throw Exception('Failed to get order chat: ${e.toString()}');
    }
  }

  @override
  Stream<OrderModel> getOrderUpdates(String orderId) {
    try {
      return _orderService.getOrderUpdates(orderId);
    } catch (e) {
      throw Exception('Failed to get order updates: ${e.toString()}');
    }
  }

  @override
  Stream<DeliveryRider> getRiderLocationUpdates(String riderId) {
    try {
      return _orderService.getRiderLocationUpdates(riderId);
    } catch (e) {
      throw Exception('Failed to get rider location updates: ${e.toString()}');
    }
  }
}
