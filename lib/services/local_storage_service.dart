import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalStorageService {
  Directory? _docsDir;

  Future<Directory> _docs() async =>
      _docsDir ??= await getApplicationDocumentsDirectory();

  Future<File> _file(String filename) async =>
      File('${(await _docs()).path}/$filename');

  Future<List<T>> readList<T>(
    String filename,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final file = await _file(filename);
    if (!await file.exists()) return <T>[];
    final raw = await file.readAsString();
    if (raw.trim().isEmpty) return <T>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> writeList<T>(
    String filename,
    List<T> items,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final file = await _file(filename);
    final encoded = const JsonEncoder.withIndent('  ')
        .convert(items.map(toJson).toList());
    await file.writeAsString(encoded);
  }
}
