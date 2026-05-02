import '../models/product.dart';
import '../services/local_storage_service.dart';

const _filename = 'products.json';

class ProductRepository {
  ProductRepository(this._storage);

  final LocalStorageService _storage;

  Future<List<Product>> loadAll() =>
      _storage.readList(_filename, Product.fromJson);

  Future<void> saveAll(List<Product> products) =>
      _storage.writeList(_filename, products, (p) => p.toJson());
}
