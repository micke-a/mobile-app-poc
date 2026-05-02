import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'shop.dart';

@immutable
class Product {
  Product({
    String? id,
    required this.name,
    required this.shop,
    this.favorite = false,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String name;
  final Shop shop;
  final bool favorite;

  Product copyWith({String? id, String? name, Shop? shop, bool? favorite}) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      shop: shop ?? this.shop,
      favorite: favorite ?? this.favorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'shop': shop.toJson(),
        'favorite': favorite,
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    final shopRaw = json['shop'];
    final Shop shop;
    if (shopRaw is String) {
      shop = Shop.seeds.firstWhere(
        (s) => s.name.toLowerCase() == shopRaw.toLowerCase(),
        orElse: () => Shop(id: 0, name: shopRaw),
      );
    } else {
      shop = Shop.fromJson(shopRaw as Map<String, dynamic>);
    }
    return Product(
      id: json['id'] as String?,
      name: json['name'] as String,
      shop: shop,
      favorite: json['favorite'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          other.id == id &&
          other.name == name &&
          other.shop == shop &&
          other.favorite == favorite;

  @override
  int get hashCode => Object.hash(id, name, shop, favorite);
}
