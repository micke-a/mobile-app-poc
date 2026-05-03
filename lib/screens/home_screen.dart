import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/product.dart';
import '../models/shop.dart';
import '../providers/order_providers.dart';
import '../providers/product_providers.dart';
import '../providers/shop_providers.dart';
import '../widgets/app_top_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);
    final shopsAsync = ref.watch(shopListProvider);
    final ordersAsync = ref.watch(orderListProvider);
    final currentOrderAsync = ref.watch(currentOrderProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const AppTopBar(title: 'MyApp'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StatCard(
              label: 'Current order',
              count: currentOrderAsync.isLoading
                  ? null
                  : '${currentOrderAsync.value?.products.length ?? 0}',
              icon: Icons.shopping_cart_outlined,
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
              onTap: () {
                final order = currentOrderAsync.value;
                if (order != null) {
                  context.push('/order/${order.id}');
                } else {
                  context.push('/orders');
                }
              },
            ),
            const SizedBox(height: 12),
            _StatCard(
              label: 'Orders',
              count: ordersAsync.isLoading
                  ? null
                  : '${ordersAsync.value?.length ?? 0}',
              icon: Icons.receipt_long_outlined,
              onTap: () => context.push('/orders'),
            ),
            const SizedBox(height: 24),
            Text('Products by shop', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            _buildShopGrid(context, productsAsync, shopsAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildShopGrid(
    BuildContext context,
    AsyncValue<List<Product>> productsAsync,
    AsyncValue<List<Shop>> shopsAsync,
  ) {
    if (productsAsync.isLoading || shopsAsync.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final products = productsAsync.value ?? [];
    final shops = shopsAsync.value ?? [];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
      ),
      itemCount: shops.length,
      itemBuilder: (context, i) {
        final shop = shops[i];
        final count = products.where((p) => p.shop.id == shop.id).length;
        return _ShopCard(
          name: shop.name,
          count: count,
          onTap: () => context.push('/products/shop/${shop.id}'),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final String? count;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bg = backgroundColor ?? colorScheme.surfaceContainerHighest;
    final fg = foregroundColor ?? colorScheme.onSurface;

    return Card(
      color: bg,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Icon(icon, color: fg, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (count == null)
                      SizedBox(
                        height: 32,
                        width: 32,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: fg),
                      )
                    else
                      Text(
                        count!,
                        style: textTheme.headlineMedium?.copyWith(
                          color: fg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    Text(
                      label,
                      style: textTheme.bodyMedium?.copyWith(color: fg),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: fg.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({
    required this.name,
    required this.count,
    required this.onTap,
  });

  final String name;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$count',
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
