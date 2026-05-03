import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/order_providers.dart';

class AppTopBar extends ConsumerWidget implements PreferredSizeWidget {
  const AppTopBar({super.key, required this.title, this.extraActions});

  final String title;
  final List<Widget>? extraActions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentOrder = ref.watch(currentOrderProvider).value;
    final canPop = context.canPop();
    return AppBar(
      automaticallyImplyLeading: false,
      leading: canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back',
              onPressed: () => context.pop(),
            )
          : null,
      title: Text(title),
      centerTitle: true,
      actions: [
        ...?extraActions,
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Search products',
          onPressed: () => context.push('/products'),
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          tooltip: 'Current order',
          onPressed: () {
            if (currentOrder != null) {
              context.push('/order/${currentOrder.id}');
            } else {
              context.push('/orders');
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.home_outlined),
          tooltip: 'Home',
          onPressed: () => context.go('/home'),
        ),
      ],
    );
  }
}
