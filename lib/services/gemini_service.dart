import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/product.dart';

class ParsedProduct {
  const ParsedProduct({
    this.existingId,
    required this.name,
    required this.shopId,
  });

  // Non-null when Gemini matched this to an existing product by id.
  final String? existingId;
  final String name;
  final int shopId;
}

class GeminiService {
  static Future<List<ParsedProduct>> parseShoppingRequest(
    String transcription,
    List<Product> existingProducts,
  ) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

    final productList = existingProducts
        .map((p) => '{"id":"${p.id}","name":"${p.name}","shopId":${p.shop.id}}')
        .join(',');

    final prompt = '''
You are a shopping list parser.
The user said: "$transcription"
Available shops: Tesco (id:1), Ocado (id:2), Sainsbury's (id:3), M&S (id:4), Aldi (id:5).

Existing products — prefer these over inventing new ones if there is a reasonable match:
[$productList]

Rules:
- If a close match exists, include its "id" and use its exact "name" and "shopId".
- If no good match exists, omit the "id" field entirely.
- If the user does not mention a shop, use shopId 1 (Tesco).

Return ONLY a valid JSON array, no other text.
Example: [{"id":"abc-123","name":"Whole Milk","shopId":1},{"name":"New Item","shopId":2}]
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final raw = (response.text ?? '').trim();

    // Strip markdown code fences Gemini sometimes wraps responses in
    final json = raw
        .replaceAll(RegExp(r'^```[a-z]*\n?', multiLine: false), '')
        .replaceAll('```', '');

    final list = jsonDecode(json.trim()) as List<dynamic>;
    return list
        .map((e) => ParsedProduct(
              existingId: e['id'] as String?,
              name: e['name'] as String,
              shopId: e['shopId'] as int,
            ))
        .toList();
  }
}
