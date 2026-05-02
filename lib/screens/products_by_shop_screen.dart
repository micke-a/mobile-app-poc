import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/order_providers.dart';
import '../providers/product_providers.dart';
import '../providers/shop_providers.dart';
import '../widgets/app_top_bar.dart';

class ProductsByShopScreen extends ConsumerWidget {
  const ProductsByShopScreen({super.key, required this.shopId});

  final int shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productListProvider);
    final shops = ref.watch(shopListProvider);
    final currentOrder = ref.watch(currentOrderProvider);
    final shopName = shops.maybeWhen(
      data: (list) =>
          list.firstWhere((s) => s.id == shopId, orElse: () => list.first).name,
      orElse: () => 'Shop',
    );
    return Scaffold(
      appBar: AppTopBar(title: 'Products at $shopName'),
      body: products.when(
        data: (all) {
          final filtered = all.where((p) => p.shop.id == shopId).toList();
          if (filtered.isEmpty) {
            return Center(child: Text('No products at $shopName'));
          }
          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final product = filtered[i];
              final inOrder = currentOrder.maybeWhen(
                data: (order) =>
                    order?.products.any((p) => p.id == product.id) ?? false,
                orElse: () => false,
              );
              return ListTile(
                title: Text(product.name),
                subtitle: Text(product.shop.name),
                trailing: IconButton(
                  icon: Icon(inOrder
                      ? Icons.remove_shopping_cart
                      : Icons.add_shopping_cart),
                  tooltip: inOrder ? 'Remove from order' : 'Add to order',
                  onPressed: () => ref
                      .read(currentOrderProvider.notifier)
                      .toggleProduct(product),
                ),
                onTap: () => context.push('/product/${product.id}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
