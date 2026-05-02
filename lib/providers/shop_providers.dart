import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/shop.dart';
import '../repositories/shop_repository.dart';
import 'storage_providers.dart';

class ShopListNotifier extends AsyncNotifier<List<Shop>> {
  late final ShopRepository _repo;

  @override
  Future<List<Shop>> build() async {
    _repo = ref.read(shopRepositoryProvider);
    final existing = await _repo.loadAll();
    if (existing.isEmpty) {
      await _repo.saveAll(Shop.seeds);
      return Shop.seeds;
    }
    return existing;
  }
}

final shopListProvider =
    AsyncNotifierProvider<ShopListNotifier, List<Shop>>(ShopListNotifier.new);

class CurrentShopNotifier extends Notifier<Shop?> {
  @override
  Shop? build() => null;

  void set(Shop? shop) => state = shop;
  void clear() => state = null;
}

final currentShopProvider =
    NotifierProvider<CurrentShopNotifier, Shop?>(CurrentShopNotifier.new);
