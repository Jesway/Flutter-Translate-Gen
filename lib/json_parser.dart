import 'dart:convert';

import 'package:build/build.dart';
import 'package:flutter_translate_gen/flutter_translate_gen.dart';
import 'package:glob/glob.dart';

import 'localized_item.dart';

class JsonParser {
  static const List<String> pluralsKeys = ["0", "1", "else"];

  final BuildStep step;
  final FlutterTranslate options;

  JsonParser(this.step, this.options);

  Future<LocalizedItemBranch> parse() async {
    final assets = step.findAssets(Glob(options.path, recursive: true));

    final root = LocalizedItemBranch(null, null);
    await for (final entity in assets) {
      final Map<String, dynamic> jsonMap = json.decode(
        await step.readAsString(entity),
      );

      final lang = entity.pathSegments.last.replaceAll(".json", "");
      _parseRecursive(lang, jsonMap, root);
    }

    return root;
  }

  void _parseRecursive(
    String lang,
    Map<String, dynamic> json,
    LocalizedItemBranch branch,
  ) {
    for (final key in json.keys) {
      if (pluralsKeys.contains(key)) {
        branch.isPlural = true;
        final translation = json[key];

        if (translation is String) {
          final leaf = branch.ensureLeaf(key);
          leaf.translations[lang] = translation;
        }
      } else {
        final translation = json[key];

        if (translation is String) {
          final leaf = branch.ensureLeaf(key);
          leaf.translations[lang] = translation;
        } else if (translation is Map<String, dynamic>) {
          final nextBranch = branch.ensureBranch(key);
          _parseRecursive(lang, translation, nextBranch);
        }
      }
    }
  }
}
