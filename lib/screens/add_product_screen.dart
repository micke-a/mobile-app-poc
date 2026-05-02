import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/product.dart';
import '../models/shop.dart';
import '../providers/product_providers.dart';
import '../providers/shop_providers.dart';
import '../widgets/app_top_bar.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _name = TextEditingController();
  Shop? _selectedShop;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    if (name.isEmpty || _selectedShop == null) return;
    await ref
        .read(productListProvider.notifier)
        .add(Product(name: name, shop: _selectedShop!));
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final shops = ref.watch(shopListProvider);
    return Scaffold(
      appBar: const AppTopBar(title: 'Add product'),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            shops.when(
              data: (list) => InputDecorator(
                decoration: const InputDecoration(labelText: 'Shop'),
                child: DropdownButton<Shop>(
                  value: _selectedShop,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  hint: const Text('Select a shop'),
                  items: list
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text(s.name)))
                      .toList(),
                  onChanged: (s) => setState(() => _selectedShop = s),
                ),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error loading shops: $e'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
