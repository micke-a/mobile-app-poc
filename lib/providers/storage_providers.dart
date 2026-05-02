import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/current_order_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/shop_repository.dart';
import '../services/local_storage_service.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(localStorageServiceProvider));
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(localStorageServiceProvider));
});

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ShopRepository(ref.watch(localStorageServiceProvider));
});

final currentOrderRepositoryProvider = Provider<CurrentOrderRepository>((ref) {
  return CurrentOrderRepository(ref.watch(localStorageServiceProvider));
});
