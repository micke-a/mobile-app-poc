import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/product.dart';
import '../models/shop.dart';
import '../providers/order_providers.dart';
import '../providers/product_providers.dart';
import '../providers/shop_providers.dart';
import '../widgets/app_top_bar.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String _query = '';
  Shop? _shopFilter;

  @override
  void initState() {
    super.initState();
    _shopFilter = ref.read(currentShopProvider);
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productListProvider);
    final shops = ref.watch(shopListProvider);
    return Scaffold(
      appBar: const AppTopBar(title: 'Products'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/products/add'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Search',
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          shops.maybeWhen(
            data: (list) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: DropdownButton<Shop?>(
                value: _shopFilter,
                isExpanded: true,
                hint: const Text('All shops'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All shops')),
                  ...list.map(
                    (s) => DropdownMenuItem(value: s, child: Text(s.name)),
                  ),
                ],
                onChanged: (s) => setState(() => _shopFilter = s),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          Expanded(
            child: products.when(
              data: (list) => _ProductList(
                products: _filter(list, _query, _shopFilter),
              ),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  List<Product> _filter(List<Product> products, String query, Shop? shopFilter) {
    var result = products;
    if (shopFilter != null) {
      result = result.where((p) => p.shop.id == shopFilter.id).toList();
    }
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((p) => p.name.toLowerCase().contains(q)).toList();
    }
    return result;
  }
}

class _ProductList extends ConsumerWidget {
  const _ProductList({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (products.isEmpty) {
      return const Center(child: Text('No products yet'));
    }
    final currentOrder = ref.watch(currentOrderProvider);
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, i) {
        final product = products[i];
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
  }
}
