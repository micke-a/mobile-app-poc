import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/product_seeds.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import 'storage_providers.dart';

class ProductListNotifier extends AsyncNotifier<List<Product>> {
  late final ProductRepository _repo;

  @override
  Future<List<Product>> build() async {
    _repo = ref.read(productRepositoryProvider);
    final existing = await _repo.loadAll();
    if (existing.isEmpty) {
      await _repo.saveAll(ProductSeeds.all);
      return ProductSeeds.all;
    }
    return existing;
  }

  Future<void> add(Product product) async {
    final current = await future;
    final updated = [...current, product];
    await _repo.saveAll(updated);
    state = AsyncData(updated);
  }

  Future<void> toggleFavorite(String id) async {
    final current = await future;
    final idx = current.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    final updated = [...current];
    updated[idx] = updated[idx].copyWith(favorite: !updated[idx].favorite);
    await _repo.saveAll(updated);
    state = AsyncData(updated);
  }
}

final productListProvider =
    AsyncNotifierProvider<ProductListNotifier, List<Product>>(
  ProductListNotifier.new,
);
