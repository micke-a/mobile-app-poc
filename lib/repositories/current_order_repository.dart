import '../models/order.dart';
import '../services/local_storage_service.dart';

const _filename = 'current-order.json';

class CurrentOrderRepository {
  CurrentOrderRepository(this._storage);

  final LocalStorageService _storage;

  Future<Order?> load() async {
    final list = await _storage.readList(_filename, Order.fromJson);
    return list.isEmpty ? null : list.first;
  }

  Future<void> save(Order? order) => _storage.writeList(
        _filename,
        order == null ? <Order>[] : [order],
        (o) => o.toJson(),
      );
}
