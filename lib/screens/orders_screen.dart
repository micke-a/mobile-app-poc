import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../models/order.dart';
import '../providers/order_providers.dart';
import '../widgets/app_top_bar.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  static String _formatDate(DateTime d) {
    final local = d.toLocal();
    final dd = local.day.toString().padLeft(2, '0');
    final mm = local.month.toString().padLeft(2, '0');
    return '$dd/$mm/${local.year}';
  }

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
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final order = list[i];
              final isCurrent = order.id == currentId;
              return _OrderCard(
                order: order,
                isCurrent: isCurrent,
                formattedDate: _formatDate(order.createdDate),
                onTap: () => context.push('/order/${order.id}'),
                onShare: () {
                  if (order.products.isEmpty) return;
                  final text = order.products.map((p) => p.name).join('\n');
                  SharePlus.instance.share(ShareParams(text: text));
                },
                onSetCurrent: isCurrent
                    ? null
                    : () async {
                        await ref
                            .read(currentOrderProvider.notifier)
                            .setFromList(order);
                        if (!context.mounted) return;
                        context.push('/order/${order.id}');
                      },
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

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.isCurrent,
    required this.formattedDate,
    required this.onTap,
    required this.onShare,
    required this.onSetCurrent,
  });

  final Order order;
  final bool isCurrent;
  final String formattedDate;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback? onSetCurrent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final cardColor =
        isCurrent ? colorScheme.primaryContainer : colorScheme.surface;
    final titleColor =
        isCurrent ? colorScheme.onPrimaryContainer : colorScheme.onSurface;
    final subtitleColor = isCurrent
        ? colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
        : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        color: cardColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          side: isCurrent
              ? BorderSide.none
              : BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isCurrent)
                  Container(width: 5, color: colorScheme.primary),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                'Order ${order.id.substring(0, 8).toUpperCase()}',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 18,
                                icon: Icon(Icons.share_outlined,
                                    color: subtitleColor),
                                tooltip: 'Share order',
                                onPressed:
                                    order.products.isEmpty ? null : onShare,
                              ),
                            ),
                            const SizedBox(width: 2),
                            if (isCurrent)
                              Tooltip(
                                message: 'Current order',
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(Icons.shopping_cart,
                                      size: 20,
                                      color: colorScheme.primary),
                                ),
                              )
                            else
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  iconSize: 18,
                                  icon: Icon(Icons.shopping_cart_checkout,
                                      color: subtitleColor),
                                  tooltip: 'Set as current',
                                  onPressed: onSetCurrent,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${order.products.length} item${order.products.length == 1 ? '' : 's'}',
                              style: textTheme.bodyMedium
                                  ?.copyWith(color: subtitleColor),
                            ),
                            const Spacer(),
                            Text(
                              formattedDate,
                              style: textTheme.bodySmall
                                  ?.copyWith(color: subtitleColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
