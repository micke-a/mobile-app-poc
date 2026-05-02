import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'product.dart';

@immutable
class Order {
  Order({
    String? id,
    DateTime? createdDate,
    required this.products,
  })  : id = id ?? const Uuid().v4(),
        createdDate = createdDate ?? DateTime.now();

  final String id;
  final DateTime createdDate;
  final List<Product> products;

  Order copyWith({String? id, DateTime? createdDate, List<Product>? products}) {
    return Order(
      id: id ?? this.id,
      createdDate: createdDate ?? this.createdDate,
      products: products ?? this.products,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdDate': createdDate.toIso8601String(),
        'products': products.map((p) => p.toJson()).toList(),
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        createdDate: DateTime.parse(json['createdDate'] as String),
        products: (json['products'] as List<dynamic>)
            .map((p) => Product.fromJson(p as Map<String, dynamic>))
            .toList(),
      );
}
