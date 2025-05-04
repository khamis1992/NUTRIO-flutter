import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrio_wellness/core/services/service_locator.dart';
import 'package:nutrio_wellness/features/auth/data/repositories/auth_repository.dart';
import 'package:nutrio_wellness/features/order_tracking/data/models/order_model.dart';
import 'package:nutrio_wellness/features/order_tracking/data/repositories/order_repository.dart';
import 'package:nutrio_wellness/features/order_tracking/data/services/order_service.dart';

// Events
abstract class OrderTrackingEvent extends Equatable {
  const OrderTrackingEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrderTrackingEvent {
  final OrderStatus? status;

  const LoadOrders({this.status});

  @override
  List<Object?> get props => [status];
}

class LoadOrderDetails extends OrderTrackingEvent {
  final String orderId;

  const LoadOrderDetails(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class CreateOrder extends OrderTrackingEvent {
  final List<OrderItem> items;
  final DeliveryAddress deliveryAddress;
  final PaymentInfo paymentInfo;
  final String? notes;

  const CreateOrder({
    required this.items,
    required this.deliveryAddress,
    required this.paymentInfo,
    this.notes,
  });

  @override
  List<Object?> get props => [items, deliveryAddress, paymentInfo, notes];
}

class CancelOrder extends OrderTrackingEvent {
  final String orderId;

  const CancelOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class LoadOrderChat extends OrderTrackingEvent {
  final String orderId;

  const LoadOrderChat(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class SendMessageToRider extends OrderTrackingEvent {
  final String orderId;
  final String message;

  const SendMessageToRider({
    required this.orderId,
    required this.message,
  });

  @override
  List<Object?> get props => [orderId, message];
}

class StartOrderUpdates extends OrderTrackingEvent {
  final String orderId;

  const StartOrderUpdates(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class StopOrderUpdates extends OrderTrackingEvent {
  final String orderId;

  const StopOrderUpdates(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class StartRiderLocationUpdates extends OrderTrackingEvent {
  final String riderId;

  const StartRiderLocationUpdates(this.riderId);

  @override
  List<Object?> get props => [riderId];
}

class StopRiderLocationUpdates extends OrderTrackingEvent {
  final String riderId;

  const StopRiderLocationUpdates(this.riderId);

  @override
  List<Object?> get props => [riderId];
}

class OrderUpdated extends OrderTrackingEvent {
  final OrderModel order;

  const OrderUpdated(this.order);

  @override
  List<Object?> get props => [order];
}

class RiderLocationUpdated extends OrderTrackingEvent {
  final DeliveryRider rider;

  const RiderLocationUpdated(this.rider);

  @override
  List<Object?> get props => [rider];
}

// States
abstract class OrderTrackingState extends Equatable {
  const OrderTrackingState();

  @override
  List<Object?> get props => [];
}

class OrderTrackingInitial extends OrderTrackingState {}

class OrderTrackingLoading extends OrderTrackingState {}

class OrderTrackingError extends OrderTrackingState {
  final String message;

  const OrderTrackingError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrdersLoaded extends OrderTrackingState {
  final List<OrderModel> orders;

  const OrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderDetailsLoaded extends OrderTrackingState {
  final OrderModel order;

  const OrderDetailsLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderCreated extends OrderTrackingState {
  final OrderModel order;

  const OrderCreated(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderCancelled extends OrderTrackingState {
  final String orderId;

  const OrderCancelled(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class OrderChatLoaded extends OrderTrackingState {
  final List<ChatMessage> messages;
  final String orderId;

  const OrderChatLoaded({
    required this.messages,
    required this.orderId,
  });

  @override
  List<Object?> get props => [messages, orderId];
}

class MessageSent extends OrderTrackingState {
  final String orderId;

  const MessageSent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class RiderLocationUpdating extends OrderTrackingState {
  final DeliveryRider rider;

  const RiderLocationUpdating(this.rider);

  @override
  List<Object?> get props => [rider];
}

// Bloc
class OrderTrackingBloc extends Bloc<OrderTrackingEvent, OrderTrackingState> {
  final OrderRepository _orderRepository = getIt<OrderRepository>();
  final AuthRepository _authRepository = getIt<AuthRepository>();
  
  // Subscriptions for streams
  final Map<String, StreamSubscription<OrderModel>> _orderSubscriptions = {};
  final Map<String, StreamSubscription<DeliveryRider>> _riderSubscriptions = {};

  OrderTrackingBloc() : super(OrderTrackingInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<LoadOrderDetails>(_onLoadOrderDetails);
    on<CreateOrder>(_onCreateOrder);
    on<CancelOrder>(_onCancelOrder);
    on<LoadOrderChat>(_onLoadOrderChat);
    on<SendMessageToRider>(_onSendMessageToRider);
    on<StartOrderUpdates>(_onStartOrderUpdates);
    on<StopOrderUpdates>(_onStopOrderUpdates);
    on<StartRiderLocationUpdates>(_onStartRiderLocationUpdates);
    on<StopRiderLocationUpdates>(_onStopRiderLocationUpdates);
    on<OrderUpdated>(_onOrderUpdated);
    on<RiderLocationUpdated>(_onRiderLocationUpdated);
  }

  @override
  Future<void> close() {
    // Cancel all subscriptions
    for (final subscription in _orderSubscriptions.values) {
      subscription.cancel();
    }
    for (final subscription in _riderSubscriptions.values) {
      subscription.cancel();
    }
    return super.close();
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<OrderTrackingState> emit,
  ) async {
    emit(OrderTrackingLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      
      if (user == null) {
        emit(const OrderTrackingError('User not authenticated'));
        return;
      }
      
      final orders = await _orderRepository.getOrders(
        userId: user.id,
        status: event.status,
      );
      
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrderTrackingError(e.toString()));
    }
  }

  Future<void> _onLoadOrderDetails(
    LoadOrderDetails event,
    Emitter<OrderTrackingState> emit,
  ) async {
    emit(OrderTrackingLoading());
    try {
      final order = await _orderRepository.getOrderById(event.orderId);
      emit(OrderDetailsLoaded(order));
      
      // Start listening for updates
      add(StartOrderUpdates(event.orderId));
      
      // Start listening for rider location updates if applicable
      if (order.rider != null && order.status == OrderStatus.outForDelivery) {
        add(StartRiderLocationUpdates(order.rider!.id));
      }
    } catch (e) {
      emit(OrderTrackingError(e.toString()));
    }
  }

  Future<void> _onCreateOrder(
    CreateOrder event,
    Emitter<OrderTrackingState> emit,
  ) async {
    emit(OrderTrackingLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      
      if (user == null) {
        emit(const OrderTrackingError('User not authenticated'));
        return;
      }
      
      final order = await _orderRepository.createOrder(
        userId: user.id,
        items: event.items,
        deliveryAddress: event.deliveryAddress,
        paymentInfo: event.paymentInfo,
        notes: event.notes,
      );
      
      emit(OrderCreated(order));
      
      // Start listening for updates
      add(StartOrderUpdates(order.id));
    } catch (e) {
      emit(OrderTrackingError(e.toString()));
    }
  }

  Future<void> _onCancelOrder(
    CancelOrder event,
    Emitter<OrderTrackingState> emit,
  ) async {
    emit(OrderTrackingLoading());
    try {
      await _orderRepository.cancelOrder(event.orderId);
      emit(OrderCancelled(event.orderId));
    } catch (e) {
      emit(OrderTrackingError(e.toString()));
    }
  }

  Future<void> _onLoadOrderChat(
    LoadOrderChat event,
    Emitter<OrderTrackingState> emit,
  ) async {
    emit(OrderTrackingLoading());
    try {
      final messages = await _orderRepository.getOrderChat(event.orderId);
      emit(OrderChatLoaded(messages: messages, orderId: event.orderId));
    } catch (e) {
      emit(OrderTrackingError(e.toString()));
    }
  }

  Future<void> _onSendMessageToRider(
    SendMessageToRider event,
    Emitter<OrderTrackingState> emit,
  ) async {
    try {
      await _orderRepository.sendMessageToRider(
        orderId: event.orderId,
        message: event.message,
      );
      
      emit(MessageSent(event.orderId));
      
      // Reload chat messages
      add(LoadOrderChat(event.orderId));
    } catch (e) {
      emit(OrderTrackingError(e.toString()));
    }
  }

  Future<void> _onStartOrderUpdates(
    StartOrderUpdates event,
    Emitter<OrderTrackingState> emit,
  ) async {
    try {
      // Cancel existing subscription if any
      await _orderSubscriptions[event.orderId]?.cancel();
      
      // Subscribe to order updates
      final stream = _orderRepository.getOrderUpdates(event.orderId);
      _orderSubscriptions[event.orderId] = stream.listen(
        (order) => add(OrderUpdated(order)),
        onError: (error) => add(OrderTrackingEvent()),
      );
    } catch (e) {
      emit(OrderTrackingError(e.toString()));
    }
  }

  Future<void> _onStopOrderUpdates(
    StopOrderUpdates event,
    Emitter<OrderTrackingState> emit,
  ) async {
    await _orderSubscriptions[event.orderId]?.cancel();
    _orderSubscriptions.remove(event.orderId);
  }

  Future<void> _onStartRiderLocationUpdates(
    StartRiderLocationUpdates event,
    Emitter<OrderTrackingState> emit,
  ) async {
    try {
      // Cancel existing subscription if any
      await _riderSubscriptions[event.riderId]?.cancel();
      
      // Subscribe to rider location updates
      final stream = _orderRepository.getRiderLocationUpdates(event.riderId);
      _riderSubscriptions[event.riderId] = stream.listen(
        (rider) => add(RiderLocationUpdated(rider)),
        onError: (error) => add(OrderTrackingEvent()),
      );
    } catch (e) {
      emit(OrderTrackingError(e.toString()));
    }
  }

  Future<void> _onStopRiderLocationUpdates(
    StopRiderLocationUpdates event,
    Emitter<OrderTrackingState> emit,
  ) async {
    await _riderSubscriptions[event.riderId]?.cancel();
    _riderSubscriptions.remove(event.riderId);
  }

  void _onOrderUpdated(
    OrderUpdated event,
    Emitter<OrderTrackingState> emit,
  ) {
    emit(OrderDetailsLoaded(event.order));
    
    // Start rider location updates if the order has a rider and is out for delivery
    if (event.order.rider != null && 
        event.order.status == OrderStatus.outForDelivery &&
        !_riderSubscriptions.containsKey(event.order.rider!.id)) {
      add(StartRiderLocationUpdates(event.order.rider!.id));
    }
    
    // Stop rider location updates if the order is delivered or cancelled
    if (event.order.rider != null && 
        (event.order.status == OrderStatus.delivered || 
         event.order.status == OrderStatus.cancelled)) {
      add(StopRiderLocationUpdates(event.order.rider!.id));
    }
  }

  void _onRiderLocationUpdated(
    RiderLocationUpdated event,
    Emitter<OrderTrackingState> emit,
  ) {
    emit(RiderLocationUpdating(event.rider));
  }
}
