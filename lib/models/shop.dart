import 'package:flutter/foundation.dart';

@immutable
class Shop {
  const Shop({required this.id, required this.name});

  final int id;
  final String name;

  Shop copyWith({int? id, String? name}) =>
      Shop(id: id ?? this.id, name: name ?? this.name);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory Shop.fromJson(Map<String, dynamic> json) =>
      Shop(id: json['id'] as int, name: json['name'] as String);

  static const List<Shop> seeds = [
    Shop(id: 1, name: 'Tesco'),
    Shop(id: 2, name: 'Ocado'),
    Shop(id: 3, name: "Sainsbury's"),
    Shop(id: 4, name: 'M&S'),
    Shop(id: 5, name: 'Aldi'),
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Shop && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
