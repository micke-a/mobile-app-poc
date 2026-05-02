import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/order_providers.dart';
import '../providers/product_providers.dart';
import '../widgets/app_top_bar.dart';

class FavouritesScreen extends ConsumerWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productListProvider);
    final currentOrder = ref.watch(currentOrderProvider);
    return Scaffold(
      appBar: const AppTopBar(title: 'Favourites'),
      body: products.when(
        data: (all) {
          final favs = all.where((p) => p.favorite).toList();
          if (favs.isEmpty) {
            return const Center(child: Text('No favourites yet'));
          }
          return ListView.builder(
            itemCount: favs.length,
            itemBuilder: (_, i) {
              final product = favs[i];
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
