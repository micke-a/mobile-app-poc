import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../models/order.dart';
import '../providers/order_providers.dart';
import '../widgets/app_top_bar.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(orderListProvider);
    final current = ref.watch(currentOrderProvider);

    final Order? order =
        list.value?.where((o) => o.id == orderId).firstOrNull ??
            (current.value?.id == orderId ? current.value : null);
    final isCurrent = current.value?.id == orderId;

    void shareOrder() {
      if (order == null || order.products.isEmpty) return;
      final text = order.products.map((p) => p.name).join('\n');
      SharePlus.instance.share(ShareParams(text: text));
    }

    return Scaffold(
      appBar: AppTopBar(
        title: 'Order',
        extraActions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share order',
            onPressed: order != null && order.products.isNotEmpty ? shareOrder : null,
          ),
        ],
      ),
      body: list.isLoading || current.isLoading
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? const Center(child: Text('Order not found'))
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${order.id}'),
                      const SizedBox(height: 4),
                      Text('Created: ${order.createdDate.toLocal()}'),
                      if (isCurrent) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Current order',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Divider(),
                      Expanded(
                        child: order.products.isEmpty
                            ? const Center(
                                child: Text('No products in this order yet'),
                              )
                            : ListView.builder(
                                itemCount: order.products.length,
                                itemBuilder: (_, i) {
                                  final p = order.products[i];
                                  return ListTile(
                                    title: Text(p.name),
                                    subtitle: Text(p.shop.name),
                                    trailing: isCurrent
                                        ? IconButton(
                                            icon: const Icon(Icons.remove_shopping_cart),
                                            tooltip: 'Remove from order',
                                            onPressed: () => ref
                                                .read(currentOrderProvider.notifier)
                                                .toggleProduct(p),
                                          )
                                        : null,
                                  );
                                },
                              ),
                      ),
                      if (isCurrent && order.products.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () async {
                                await ref
                                    .read(currentOrderProvider.notifier)
                                    .markCompleted();
                                if (!context.mounted) return;
                                context.pop();
                              },
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Mark as completed'),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}
