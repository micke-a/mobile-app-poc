import '../models/shop.dart';
import '../services/local_storage_service.dart';

const _filename = 'shops.json';

class ShopRepository {
  ShopRepository(this._storage);

  final LocalStorageService _storage;

  Future<List<Shop>> loadAll() =>
      _storage.readList(_filename, Shop.fromJson);

  Future<void> saveAll(List<Shop> shops) =>
      _storage.writeList(_filename, shops, (s) => s.toJson());
}
