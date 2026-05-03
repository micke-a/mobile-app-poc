import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/order_providers.dart';
import '../widgets/app_top_bar.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderListProvider);
    final current = ref.watch(currentOrderProvider);
    final currentId = current.value?.id;

    return Scaffold(
      appBar: const AppTopBar(title: 'Orders'),
      body: orders.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final order = list[i];
              final isCurrent = order.id == currentId;
              return ListTile(
                title: Text('Order ${order.id.substring(0, 8)}'),
                subtitle: Text(
                  '${order.products.length} item(s) - '
                  '${order.createdDate.toLocal()}',
                ),
                trailing: isCurrent
                    ? Chip(
                        avatar: Icon(
                          Icons.shopping_cart,
                          size: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        label: Text(
                          'Current',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.primary,
                        padding: EdgeInsets.zero,
                      )
                    : TextButton.icon(
                        icon: const Icon(Icons.shopping_cart_checkout, size: 16),
                        label: const Text('Set current'),
                        onPressed: () async {
                          await ref
                              .read(currentOrderProvider.notifier)
                              .setFromList(order);
                          if (!context.mounted) return;
                          context.push('/order/${order.id}');
                        },
                      ),
                onTap: () => context.push('/order/${order.id}'),
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
