import '../models/order.dart';
import '../services/local_storage_service.dart';

const _filename = 'orders.json';

class OrderRepository {
  OrderRepository(this._storage);

  final LocalStorageService _storage;

  Future<List<Order>> loadAll() =>
      _storage.readList(_filename, Order.fromJson);

  Future<void> saveAll(List<Order> orders) =>
      _storage.writeList(_filename, orders, (o) => o.toJson());
}
