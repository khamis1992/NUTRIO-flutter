import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrio_wellness/features/meal_planner/data/models/meal_model.dart';

part 'order_model.g.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  readyForPickup,
  outForDelivery,
  delivered,
  cancelled
}

@JsonSerializable()
class OrderModel extends Equatable {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final DateTime orderTime;
  final DateTime? estimatedDeliveryTime;
  final DateTime? actualDeliveryTime;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final DeliveryAddress deliveryAddress;
  final PaymentInfo paymentInfo;
  final DeliveryRider? rider;
  final List<OrderStatusUpdate> statusUpdates;
  final String? notes;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.orderTime,
    this.estimatedDeliveryTime,
    this.actualDeliveryTime,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.deliveryAddress,
    required this.paymentInfo,
    this.rider,
    required this.statusUpdates,
    this.notes,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  OrderModel copyWith({
    String? id,
    String? userId,
    List<OrderItem>? items,
    DateTime? orderTime,
    DateTime? estimatedDeliveryTime,
    DateTime? actualDeliveryTime,
    double? subtotal,
    double? tax,
    double? deliveryFee,
    double? total,
    OrderStatus? status,
    DeliveryAddress? deliveryAddress,
    PaymentInfo? paymentInfo,
    DeliveryRider? rider,
    List<OrderStatusUpdate>? statusUpdates,
    String? notes,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      orderTime: orderTime ?? this.orderTime,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      actualDeliveryTime: actualDeliveryTime ?? this.actualDeliveryTime,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentInfo: paymentInfo ?? this.paymentInfo,
      rider: rider ?? this.rider,
      statusUpdates: statusUpdates ?? this.statusUpdates,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
        orderTime,
        estimatedDeliveryTime,
        actualDeliveryTime,
        subtotal,
        tax,
        deliveryFee,
        total,
        status,
        deliveryAddress,
        paymentInfo,
        rider,
        statusUpdates,
        notes,
      ];
}

@JsonSerializable()
class OrderItem extends Equatable {
  final String id;
  final MealModel meal;
  final int quantity;
  final double price;
  final List<String>? specialInstructions;

  const OrderItem({
    required this.id,
    required this.meal,
    required this.quantity,
    required this.price,
    this.specialInstructions,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemToJson(this);

  @override
  List<Object?> get props => [
        id,
        meal,
        quantity,
        price,
        specialInstructions,
      ];
}

@JsonSerializable()
class DeliveryAddress extends Equatable {
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final double? latitude;
  final double? longitude;
  final String? instructions;

  const DeliveryAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.latitude,
    this.longitude,
    this.instructions,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) => _$DeliveryAddressFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryAddressToJson(this);

  @override
  List<Object?> get props => [
        street,
        city,
        state,
        zipCode,
        country,
        latitude,
        longitude,
        instructions,
      ];
}

@JsonSerializable()
class PaymentInfo extends Equatable {
  final String method; // e.g., 'credit_card', 'paypal', 'cash'
  final String? cardType;
  final String? last4;
  final bool isPaid;

  const PaymentInfo({
    required this.method,
    this.cardType,
    this.last4,
    required this.isPaid,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) => _$PaymentInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentInfoToJson(this);

  @override
  List<Object?> get props => [
        method,
        cardType,
        last4,
        isPaid,
      ];
}

@JsonSerializable()
class DeliveryRider extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? photoUrl;
  final double? currentLatitude;
  final double? currentLongitude;
  final double? rating;

  const DeliveryRider({
    required this.id,
    required this.name,
    required this.phone,
    this.photoUrl,
    this.currentLatitude,
    this.currentLongitude,
    this.rating,
  });

  factory DeliveryRider.fromJson(Map<String, dynamic> json) => _$DeliveryRiderFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryRiderToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        photoUrl,
        currentLatitude,
        currentLongitude,
        rating,
      ];
}

@JsonSerializable()
class OrderStatusUpdate extends Equatable {
  final OrderStatus status;
  final DateTime timestamp;
  final String? message;

  const OrderStatusUpdate({
    required this.status,
    required this.timestamp,
    this.message,
  });

  factory OrderStatusUpdate.fromJson(Map<String, dynamic> json) => _$OrderStatusUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$OrderStatusUpdateToJson(this);

  @override
  List<Object?> get props => [
        status,
        timestamp,
        message,
      ];
}
