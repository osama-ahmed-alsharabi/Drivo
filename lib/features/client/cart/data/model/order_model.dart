// lib/features/client/orders/data/models/order_model.dart
import 'package:flutter/material.dart';

class Order {
  final String id;
  final String orderNumber;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final String? paymentStatus;
  final DeliveryAddress deliveryAddress;
  final List<OrderItem> items;
  final String? customerNotes;
  final String? deliveryId;
  final bool isFreeDelivery;

  const Order(
      {required this.id,
      required this.orderNumber,
      required this.status,
      required this.createdAt,
      this.updatedAt,
      required this.subtotal,
      required this.deliveryFee,
      required this.discount,
      required this.totalAmount,
      required this.paymentMethod,
      this.paymentStatus,
      required this.deliveryAddress,
      required this.items,
      this.customerNotes,
      this.deliveryId,
      required this.isFreeDelivery});

  get needsDeliveryFeeCalculation => null;

  Order copyWith({
    String? id,
    String? orderNumber,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? subtotal,
    double? deliveryFee,
    double? discount,
    double? totalAmount,
    PaymentMethod? paymentMethod,
    String? paymentStatus,
    DeliveryAddress? deliveryAddress,
    List<OrderItem>? items,
    String? customerNotes,
    String? deliveryId,
  }) {
    return Order(
        id: id ?? this.id,
        orderNumber: orderNumber ?? this.orderNumber,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        subtotal: subtotal ?? this.subtotal,
        deliveryFee: deliveryFee ?? this.deliveryFee,
        discount: discount ?? this.discount,
        totalAmount: totalAmount ?? this.totalAmount,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        deliveryAddress: deliveryAddress ?? this.deliveryAddress,
        items: items ?? List.from(this.items),
        customerNotes: customerNotes ?? this.customerNotes,
        isFreeDelivery: isFreeDelivery ?? isFreeDelivery,
        deliveryId: deliveryId ?? this.deliveryId);
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      status: OrderStatusX.fromString(json['order_status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      paymentMethod:
          PaymentMethodX.fromString(json['payment_method'] as String),
      paymentStatus: json['payment_status'] as String?,
      deliveryAddress: DeliveryAddress.fromJson(
          json['delivery_address'] as Map<String, dynamic>),
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      customerNotes: json['customer_notes'] as String?,
      isFreeDelivery: json['is_free_delivery'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'order_status': status.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'discount': discount,
      'total_amount': totalAmount,
      'payment_method': paymentMethod.value,
      'payment_status': paymentStatus,
      'delivery_address': deliveryAddress.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'customer_notes': customerNotes,
    };
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String restaurantId;
  final String? restaurantName;
  final int quantity;
  final double unitPrice;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.restaurantId,
    this.restaurantName,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] as String,
      productName: json['name'] as String,
      restaurantId: json['restaurant_id'] as String,
      restaurantName: json['restaurant_name'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }
}

class DeliveryAddress {
  final int id;
  final String title;
  final String address;
  final String? additionalInfo;
  final double latitude;
  final double longitude;

  const DeliveryAddress({
    required this.id,
    required this.title,
    required this.address,
    this.additionalInfo,
    required this.latitude,
    required this.longitude,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      id: json['id'] as int,
      title: json['title'] as String,
      address: json['address'] as String,
      additionalInfo: json['additional_info'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'additional_info': additionalInfo,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

enum OrderStatus {
  pending('pending'),
  confirmed('confirmed'),
  preparing('preparing'),
  readyForDelivery('ready_for_delivery'),
  shipped('shipped'),
  delivered('delivered'),
  cancelled('cancelled'),
  refunded('refunded');

  final String value;
  const OrderStatus(this.value);
}

enum PaymentMethod {
  cashOnDelivery('cash_on_delivery'),
  creditCard('credit_card'),
  wallet('wallet'),
  bankTransfer('bank_transfer');

  final String value;
  const PaymentMethod(this.value);
}

extension OrderStatusX on OrderStatus {
  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }

  String get displayText {
    switch (this) {
      case OrderStatus.pending:
        return 'قيد الانتظار';
      case OrderStatus.confirmed:
        return 'تم التأكيد';
      case OrderStatus.preparing:
        return 'قيد التجهيز';
      case OrderStatus.readyForDelivery:
        return 'جاهز للتوصيل';
      case OrderStatus.shipped:
        return 'قيد الشحن';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغى';
      case OrderStatus.refunded:
        return 'تم الاسترجاع';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.indigo;
      case OrderStatus.readyForDelivery:
        return Colors.teal;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.refunded:
        return Colors.grey;
    }
  }
}

extension PaymentMethodX on PaymentMethod {
  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.value == value,
      orElse: () => PaymentMethod.cashOnDelivery,
    );
  }

  String get displayText {
    switch (this) {
      case PaymentMethod.cashOnDelivery:
        return 'الدفع عند الاستلام';
      case PaymentMethod.creditCard:
        return 'بطاقة ائتمان';
      case PaymentMethod.wallet:
        return 'المحفظة الإلكترونية';
      case PaymentMethod.bankTransfer:
        return 'حوالة بنكية';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.cashOnDelivery:
        return Icons.money;
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
    }
  }
}
