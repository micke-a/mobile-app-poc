import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/order_providers.dart';
import '../providers/product_providers.dart';
import '../widgets/app_top_bar.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productListProvider);
    final currentOrder = ref.watch(currentOrderProvider);
    return Scaffold(
      appBar: const AppTopBar(title: 'Product'),
      body: products.when(
        data: (all) {
          final product = all.where((p) => p.id == productId).firstOrNull;
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }
          final inOrder = currentOrder.maybeWhen(
            data: (order) =>
                order?.products.any((p) => p.id == product.id) ?? false,
            orElse: () => false,
          );
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Shop: ${product.shop.name}'),
                const SizedBox(height: 8),
                Row(children: [
                  Icon(product.favorite
                      ? Icons.favorite
                      : Icons.favorite_border),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => ref
                        .read(productListProvider.notifier)
                        .toggleFavorite(product.id),
                    child: Text(product.favorite
                        ? 'Remove favourite'
                        : 'Mark favourite'),
                  ),
                ]),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => ref
                      .read(currentOrderProvider.notifier)
                      .toggleProduct(product),
                  icon: Icon(inOrder
                      ? Icons.remove_shopping_cart
                      : Icons.add_shopping_cart),
                  label: Text(
                      inOrder ? 'Remove from order' : 'Add to order'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
