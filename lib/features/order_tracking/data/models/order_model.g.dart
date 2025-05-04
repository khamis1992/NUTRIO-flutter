// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      orderTime: DateTime.parse(json['orderTime'] as String),
      estimatedDeliveryTime: json['estimatedDeliveryTime'] == null
          ? null
          : DateTime.parse(json['estimatedDeliveryTime'] as String),
      actualDeliveryTime: json['actualDeliveryTime'] == null
          ? null
          : DateTime.parse(json['actualDeliveryTime'] as String),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      deliveryAddress:
          DeliveryAddress.fromJson(json['deliveryAddress'] as Map<String, dynamic>),
      paymentInfo:
          PaymentInfo.fromJson(json['paymentInfo'] as Map<String, dynamic>),
      rider: json['rider'] == null
          ? null
          : DeliveryRider.fromJson(json['rider'] as Map<String, dynamic>),
      statusUpdates: (json['statusUpdates'] as List<dynamic>)
          .map((e) => OrderStatusUpdate.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'items': instance.items,
      'orderTime': instance.orderTime.toIso8601String(),
      'estimatedDeliveryTime': instance.estimatedDeliveryTime?.toIso8601String(),
      'actualDeliveryTime': instance.actualDeliveryTime?.toIso8601String(),
      'subtotal': instance.subtotal,
      'tax': instance.tax,
      'deliveryFee': instance.deliveryFee,
      'total': instance.total,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'deliveryAddress': instance.deliveryAddress,
      'paymentInfo': instance.paymentInfo,
      'rider': instance.rider,
      'statusUpdates': instance.statusUpdates,
      'notes': instance.notes,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.preparing: 'preparing',
  OrderStatus.readyForPickup: 'readyForPickup',
  OrderStatus.outForDelivery: 'outForDelivery',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
};

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
      id: json['id'] as String,
      meal: MealModel.fromJson(json['meal'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      specialInstructions: (json['specialInstructions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
      'id': instance.id,
      'meal': instance.meal,
      'quantity': instance.quantity,
      'price': instance.price,
      'specialInstructions': instance.specialInstructions,
    };

DeliveryAddress _$DeliveryAddressFromJson(Map<String, dynamic> json) =>
    DeliveryAddress(
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zipCode'] as String,
      country: json['country'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      instructions: json['instructions'] as String?,
    );

Map<String, dynamic> _$DeliveryAddressToJson(DeliveryAddress instance) =>
    <String, dynamic>{
      'street': instance.street,
      'city': instance.city,
      'state': instance.state,
      'zipCode': instance.zipCode,
      'country': instance.country,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'instructions': instance.instructions,
    };

PaymentInfo _$PaymentInfoFromJson(Map<String, dynamic> json) => PaymentInfo(
      method: json['method'] as String,
      cardType: json['cardType'] as String?,
      last4: json['last4'] as String?,
      isPaid: json['isPaid'] as bool,
    );

Map<String, dynamic> _$PaymentInfoToJson(PaymentInfo instance) =>
    <String, dynamic>{
      'method': instance.method,
      'cardType': instance.cardType,
      'last4': instance.last4,
      'isPaid': instance.isPaid,
    };

DeliveryRider _$DeliveryRiderFromJson(Map<String, dynamic> json) =>
    DeliveryRider(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      photoUrl: json['photoUrl'] as String?,
      currentLatitude: (json['currentLatitude'] as num?)?.toDouble(),
      currentLongitude: (json['currentLongitude'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$DeliveryRiderToJson(DeliveryRider instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'photoUrl': instance.photoUrl,
      'currentLatitude': instance.currentLatitude,
      'currentLongitude': instance.currentLongitude,
      'rating': instance.rating,
    };

OrderStatusUpdate _$OrderStatusUpdateFromJson(Map<String, dynamic> json) =>
    OrderStatusUpdate(
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$OrderStatusUpdateToJson(OrderStatusUpdate instance) =>
    <String, dynamic>{
      'status': _$OrderStatusEnumMap[instance.status]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'message': instance.message,
    };
