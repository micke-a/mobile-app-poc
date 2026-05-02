import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../models/product.dart';
import '../repositories/current_order_repository.dart';
import '../repositories/order_repository.dart';
import 'storage_providers.dart';

class OrderListNotifier extends AsyncNotifier<List<Order>> {
  late final OrderRepository _repo;

  @override
  Future<List<Order>> build() async {
    _repo = ref.read(orderRepositoryProvider);
    final orders = await _repo.loadAll();
    orders.sort((a, b) => b.createdDate.compareTo(a.createdDate));
    return orders;
  }

  Future<void> addCompleted(Order order) async {
    final current = await future;
    final updated = [order, ...current];
    await _repo.saveAll(updated);
    state = AsyncData(updated);
  }

  Future<void> remove(String orderId) async {
    final current = await future;
    final updated = current.where((o) => o.id != orderId).toList();
    await _repo.saveAll(updated);
    state = AsyncData(updated);
  }
}

final orderListProvider =
    AsyncNotifierProvider<OrderListNotifier, List<Order>>(
  OrderListNotifier.new,
);

class CurrentOrderNotifier extends AsyncNotifier<Order?> {
  late final CurrentOrderRepository _repo;

  @override
  Future<Order?> build() async {
    _repo = ref.read(currentOrderRepositoryProvider);
    return _repo.load();
  }

  Future<void> toggleProduct(Product product) async {
    final current = await future ?? Order(products: const []);
    final already = current.products.any((p) => p.id == product.id);
    final products = already
        ? current.products.where((p) => p.id != product.id).toList()
        : [...current.products, product];
    final updated = current.copyWith(products: products);
    await _repo.save(updated);
    state = AsyncData(updated);
  }

  Future<void> markCompleted() async {
    final current = await future;
    if (current != null && current.products.isNotEmpty) {
      await ref.read(orderListProvider.notifier).addCompleted(current);
    }
    final fresh = Order(products: const []);
    await _repo.save(fresh);
    state = AsyncData(fresh);
  }

  Future<void> setFromList(Order order) async {
    final previous = await future;
    if (previous != null &&
        previous.products.isNotEmpty &&
        previous.id != order.id) {
      await ref.read(orderListProvider.notifier).addCompleted(previous);
    }
    await ref.read(orderListProvider.notifier).remove(order.id);
    await _repo.save(order);
    state = AsyncData(order);
  }
}

final currentOrderProvider =
    AsyncNotifierProvider<CurrentOrderNotifier, Order?>(
  CurrentOrderNotifier.new,
);
