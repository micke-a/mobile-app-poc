import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/product.dart';
import '../models/shop.dart';
import '../providers/order_providers.dart';
import '../providers/product_providers.dart';
import '../services/gemini_service.dart';

enum _State { listening, processing, preview, error }

class VoiceAddSheet extends ConsumerStatefulWidget {
  const VoiceAddSheet({super.key});

  @override
  ConsumerState<VoiceAddSheet> createState() => _VoiceAddSheetState();
}

class _VoiceAddSheetState extends ConsumerState<VoiceAddSheet> {
  final _speech = SpeechToText();
  _State _state = _State.listening;
  String _transcript = '';
  String _errorMessage = '';
  List<({ParsedProduct parsed, bool selected})> _items = [];

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  Future<void> _startListening() async {
    setState(() {
      _state = _State.listening;
      _transcript = '';
      _items = [];
    });
    final available = await _speech.initialize(
      onError: (error) => _setError(error.errorMsg),
    );
    if (!available) {
      _setError('Speech recognition is not available on this device.');
      return;
    }
    await _speech.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!result.finalResult) return;
    final words = result.recognizedWords.trim();
    if (words.isEmpty) {
      _setError('No speech detected. Please try again.');
      return;
    }
    setState(() {
      _transcript = words;
      _state = _State.processing;
    });
    _callGemini(words);
  }

  Future<void> _callGemini(String transcript) async {
    try {
      final allProducts = ref.read(productListProvider).value ?? [];
      final parsed =
          await GeminiService.parseShoppingRequest(transcript, allProducts);
      if (!mounted) return;
      if (parsed.isEmpty) {
        _setError('No items found. Please try again.');
        return;
      }
      setState(() {
        _items = parsed.map((p) => (parsed: p, selected: true)).toList();
        _state = _State.preview;
      });
    } catch (e) {
      _setError('Something went wrong: $e');
    }
  }

  void _setError(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      _state = _State.error;
    });
  }

  Future<void> _confirm() async {
    final selected = _items.where((i) => i.selected).toList();
    if (selected.isEmpty) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final allProducts = ref.read(productListProvider).value ?? [];
    final currentOrder = ref.read(currentOrderProvider).value;
    final alreadyInOrder = currentOrder?.products ?? const [];

    for (final item in selected) {
      final shop = Shop.seeds.firstWhere(
        (s) => s.id == item.parsed.shopId,
        orElse: () => Shop.seeds.first,
      );
      final name = item.parsed.name;

      // Prefer the id Gemini matched; fall back to name+shop search.
      final existing = item.parsed.existingId != null
          ? allProducts
              .where((p) => p.id == item.parsed.existingId)
              .firstOrNull
          : allProducts
              .where((p) =>
                  p.name.toLowerCase() == name.toLowerCase() &&
                  p.shop.id == shop.id)
              .firstOrNull;

      final product = existing ?? Product(name: name, shop: shop);

      if (existing == null) {
        await ref.read(productListProvider.notifier).add(product);
      }

      if (!alreadyInOrder.any((p) => p.id == product.id)) {
        await ref.read(currentOrderProvider.notifier).toggleProduct(product);
      }
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: switch (_state) {
          _State.listening => _buildListening(colorScheme, textTheme),
          _State.processing => _buildProcessing(textTheme),
          _State.preview => _buildPreview(colorScheme, textTheme),
          _State.error => _buildError(textTheme),
        },
      ),
    );
  }

  Widget _buildListening(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.mic, size: 40, color: colorScheme.primary),
        ),
        const SizedBox(height: 20),
        Text('Listening…', style: textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Say what you want to add, e.g.\n"milk and bread from Tesco"',
          style:
              textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildProcessing(TextTheme textTheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 20),
        Text('Understanding your request…', style: textTheme.titleMedium),
        if (_transcript.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '"$_transcript"',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPreview(ColorScheme colorScheme, TextTheme textTheme) {
    final selectedCount = _items.where((i) => i.selected).length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add to order', style: textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          '"$_transcript"',
          style: textTheme.bodySmall
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        ..._items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final shopName = Shop.seeds
              .firstWhere((s) => s.id == item.parsed.shopId,
                  orElse: () => Shop.seeds.first)
              .name;
          return CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: item.selected,
            onChanged: (v) => setState(() {
              _items[i] = (parsed: item.parsed, selected: v ?? true);
            }),
            title: Text(item.parsed.name),
            subtitle: Text(shopName),
          );
        }),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _startListening,
                child: const Text('Try again'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: selectedCount == 0 ? null : _confirm,
                child: Text(
                    'Add $selectedCount item${selectedCount == 1 ? '' : 's'}'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildError(TextTheme textTheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.red),
        const SizedBox(height: 16),
        Text(_errorMessage,
            textAlign: TextAlign.center, style: textTheme.bodyMedium),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _startListening,
                child: const Text('Try again'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
